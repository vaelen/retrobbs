unit User;

{
  User Management Library

  Manages user accounts and authentication for RetroBBS.
  Users are stored in a database file using the DB unit.

  This implementation uses database lookups to minimize memory usage.
  User records are read from and written to the database as needed.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

interface

uses
  BBSTypes, Hash, DB;

const
  USER_DB = 'users';
  DEFAULT_SALT = 'retro';
  USER_RECORD_SIZE = 304;  { Fixed size for database storage: 2+64+42+64+64+64+2+2(padding) }

  { Access Control Bits }
  ACCESS_SYSOP = $8000;  { Bit 15: System Operator }

type
  TUser = record
    ID: TUserID;         { Unique User Identifier }
    Name: Str63;         { Login Name or "Handle" }
    Password: SHA1Hash;  { SHA-1 Hash of Password }
    FullName: Str63;     { Real Name }
    Email: Str63;        { Email Address }
    Location: Str63;     { Physical Location }
    Access: TWord;        { Access Control Bitmask }
  end;

var
  Salt: Str63;           { Password salt string }
  UserDatabase: TDatabase;  { User database }

{ Database Management Functions }

{ Initialize the user database (creates if doesn't exist) }
function InitUserDatabase: Boolean;

{ Close the user database }
procedure CloseUserDatabase;

{ User Lookup Functions }

{ Find user by ID, returns true if found }
function FindUserByID(id: TUserID; var user: TUser): Boolean;

{ Find user by name (case insensitive), returns true if found }
function FindUserByName(name: Str63; var user: TUser): Boolean;

{ User Management Functions }

{ Add a new user, returns the new user ID (0 on failure) }
function AddUser(name: Str63; password: Str63; fullName: Str63;
                 email: Str63; location: Str63): TUserID;

{ Update an existing user by ID }
function UpdateUserByID(id: TUserID; user: TUser): Boolean;

{ Update an existing user by name }
function UpdateUserByName(name: Str63; user: TUser): Boolean;

{ Delete a user by ID }
function DeleteUserByID(id: TUserID): Boolean;

{ Delete a user by name }
function DeleteUserByName(name: Str63): Boolean;

{ Authentication Functions }

{ Authenticate user with name and password, returns true if valid }
function AuthenticateUser(name: Str63; password: Str63): Boolean;

{ Set user password by ID (re-hashes with salt) }
function SetUserPasswordByID(id: TUserID; password: Str63): Boolean;

{ Set user password by name (re-hashes with salt) }
function SetUserPasswordByName(name: Str63; password: Str63): Boolean;

{ Hash password with salt }
function HashPassword(password: Str63): SHA1Hash;

{ Access Control Functions }

{ Check if user has specific access bit set }
function HasAccess(user: TUser; accessBit: TWord): Boolean;

{ Check if user is a sysop }
function IsSysop(user: TUser): Boolean;

implementation

uses
  SysUtils;

{ Helper function to serialize a user record into a byte array }
procedure UserToBytes(const user: TUser; var data: array of Byte);
var
  i: TInt;
  offset: TInt;
  len: Byte;
begin
  FillChar(data, USER_RECORD_SIZE, 0);
  offset := 0;

  { ID - 2 bytes }
  Move(user.ID, data[offset], 2);
  Inc(offset, 2);

  { Name - Pascal string (length + data) }
  len := Length(user.Name);
  data[offset] := len;
  Inc(offset);
  for i := 1 to len do
  begin
    data[offset] := Ord(user.Name[i]);
    Inc(offset);
  end;
  Inc(offset, 63 - len);  { Skip to next field }

  { Password - Pascal string }
  len := Length(user.Password);
  data[offset] := len;
  Inc(offset);
  for i := 1 to len do
  begin
    data[offset] := Ord(user.Password[i]);
    Inc(offset);
  end;
  Inc(offset, 41 - len);  { Skip to next field }

  { FullName - Pascal string }
  len := Length(user.FullName);
  data[offset] := len;
  Inc(offset);
  for i := 1 to len do
  begin
    data[offset] := Ord(user.FullName[i]);
    Inc(offset);
  end;
  Inc(offset, 63 - len);

  { Email - Pascal string }
  len := Length(user.Email);
  data[offset] := len;
  Inc(offset);
  for i := 1 to len do
  begin
    data[offset] := Ord(user.Email[i]);
    Inc(offset);
  end;
  Inc(offset, 63 - len);

  { Location - Pascal string }
  len := Length(user.Location);
  data[offset] := len;
  Inc(offset);
  for i := 1 to len do
  begin
    data[offset] := Ord(user.Location[i]);
    Inc(offset);
  end;
  Inc(offset, 63 - len);

  { Access - 2 bytes }
  Move(user.Access, data[offset], 2);
end;

{ Helper function to deserialize a byte array into a user record }
procedure BytesToUser(const data: array of Byte; var user: TUser);
var
  i: TInt;
  offset: TInt;
  len: Byte;
begin
  offset := 0;

  { ID - 2 bytes }
  Move(data[offset], user.ID, 2);
  Inc(offset, 2);

  { Name - Pascal string }
  len := data[offset];
  Inc(offset);
  user.Name := '';
  for i := 1 to len do
  begin
    user.Name := user.Name + Chr(data[offset]);
    Inc(offset);
  end;
  Inc(offset, 63 - len);

  { Password - Pascal string }
  len := data[offset];
  Inc(offset);
  user.Password := '';
  for i := 1 to len do
  begin
    user.Password := user.Password + Chr(data[offset]);
    Inc(offset);
  end;
  Inc(offset, 41 - len);

  { FullName - Pascal string }
  len := data[offset];
  Inc(offset);
  user.FullName := '';
  for i := 1 to len do
  begin
    user.FullName := user.FullName + Chr(data[offset]);
    Inc(offset);
  end;
  Inc(offset, 63 - len);

  { Email - Pascal string }
  len := data[offset];
  Inc(offset);
  user.Email := '';
  for i := 1 to len do
  begin
    user.Email := user.Email + Chr(data[offset]);
    Inc(offset);
  end;
  Inc(offset, 63 - len);

  { Location - Pascal string }
  len := data[offset];
  Inc(offset);
  user.Location := '';
  for i := 1 to len do
  begin
    user.Location := user.Location + Chr(data[offset]);
    Inc(offset);
  end;
  Inc(offset, 63 - len);

  { Access - 2 bytes }
  Move(data[offset], user.Access, 2);
end;

{ Database Management Functions }

function InitUserDatabase: Boolean;
var
  dbExists: Boolean;
  f: File;
begin
  InitUserDatabase := False;

  { Check if database exists }
  Assign(f, USER_DB + '.dat');
  {$I-}
  Reset(f, 1);
  {$I+}
  dbExists := (IOResult = 0);
  if dbExists then
    Close(f);

  if not dbExists then
  begin
    { Create new database }
    if not CreateDatabase(USER_DB, USER_RECORD_SIZE) then
      Exit;
  end;

  { Open database }
  if not OpenDatabase(USER_DB, UserDatabase) then
    Exit;

  { Add secondary index for name lookups if creating new database }
  if not dbExists then
  begin
    if not AddIndex(UserDatabase, 'Name', itString) then
    begin
      CloseDatabase(UserDatabase);
      Exit;
    end;
  end;

  InitUserDatabase := True;
end;

procedure CloseUserDatabase;
begin
  if UserDatabase.IsOpen then
    CloseDatabase(UserDatabase);
end;

{ User Lookup Functions }

function FindUserByID(id: TUserID; var user: TUser): Boolean;
var
  data: array[0..303] of Byte;
begin
  FindUserByID := False;

  if not UserDatabase.IsOpen then
    if not InitUserDatabase then
      Exit;

  if FindRecordByID(UserDatabase, id, data) then
  begin
    BytesToUser(data, user);
    FindUserByID := True;
  end;
end;

function FindUserByName(name: Str63; var user: TUser): Boolean;
var
  data: array[0..303] of Byte;
  recordID: TLong;
  tempUser: TUser;
  i: TLong;
begin
  FindUserByName := False;

  if not UserDatabase.IsOpen then
    if not InitUserDatabase then
      Exit;

  { Scan through all records to find user by name }
  { TODO: Use secondary index when FindRecordByString is implemented }
  for i := 1 to UserDatabase.Header.NextRecordID - 1 do
  begin
    if FindRecordByID(UserDatabase, i, data) then
    begin
      BytesToUser(data, tempUser);
      if LowerCase(tempUser.Name) = LowerCase(name) then
      begin
        user := tempUser;
        FindUserByName := True;
        Exit;
      end;
    end;
  end;
end;

{ User Management Functions }

function AddUser(name: Str63; password: Str63; fullName: Str63;
                 email: Str63; location: Str63): TUserID;
var
  user: TUser;
  data: array[0..303] of Byte;
  recordID: TLong;
begin
  AddUser := 0;

  if not UserDatabase.IsOpen then
    if not InitUserDatabase then
      Exit;

  { Check if user already exists }
  if FindUserByName(name, user) then
    Exit;

  { Create new user }
  user.ID := UserDatabase.Header.NextRecordID;
  user.Name := name;
  user.Password := HashPassword(password);
  user.FullName := fullName;
  user.Email := email;
  user.Location := location;
  user.Access := 0;

  { Convert to bytes }
  UserToBytes(user, data);

  { Add to database }
  if AddRecord(UserDatabase, data, recordID) then
    AddUser := user.ID;
end;

function UpdateUserByID(id: TUserID; user: TUser): Boolean;
var
  data: array[0..303] of Byte;
begin
  UpdateUserByID := False;

  if not UserDatabase.IsOpen then
    if not InitUserDatabase then
      Exit;

  { Ensure ID matches }
  user.ID := id;

  { Convert to bytes }
  UserToBytes(user, data);

  { Update in database }
  UpdateUserByID := UpdateRecord(UserDatabase, id, data);
end;

function UpdateUserByName(name: Str63; user: TUser): Boolean;
var
  existingUser: TUser;
begin
  UpdateUserByName := False;

  if not UserDatabase.IsOpen then
    if not InitUserDatabase then
      Exit;

  { Find user by name to get ID }
  if not FindUserByName(name, existingUser) then
    Exit;

  { Update using ID }
  UpdateUserByName := UpdateUserByID(existingUser.ID, user);
end;

function DeleteUserByID(id: TUserID): Boolean;
begin
  DeleteUserByID := False;

  if not UserDatabase.IsOpen then
    if not InitUserDatabase then
      Exit;

  DeleteUserByID := DeleteRecord(UserDatabase, id);
end;

function DeleteUserByName(name: Str63): Boolean;
var
  user: TUser;
begin
  DeleteUserByName := False;

  if not UserDatabase.IsOpen then
    if not InitUserDatabase then
      Exit;

  { Find user by name to get ID }
  if not FindUserByName(name, user) then
    Exit;

  { Delete using ID }
  DeleteUserByName := DeleteUserByID(user.ID);
end;

{ Authentication Functions }

function HashPassword(password: Str63): SHA1Hash;
var
  saltedPassword: Str255;
  data: array[0..254] of Byte;
  digest: TSHA1Digest;
  i: TInt;
  hexStr: String;
begin
  { Concatenate password with salt }
  saltedPassword := password + Salt;

  { Convert to byte array }
  for i := 1 to Length(saltedPassword) do
    data[i - 1] := Ord(saltedPassword[i]);

  { Hash with SHA-1 }
  digest := SHA1(data, Length(saltedPassword));

  { Convert to hex string }
  hexStr := '';
  for i := 0 to 19 do
    hexStr := hexStr + LowerCase(IntToHex(digest[i], 2));
  HashPassword := hexStr;
end;

function AuthenticateUser(name: Str63; password: Str63): Boolean;
var
  user: TUser;
  passwordHash: SHA1Hash;
begin
  AuthenticateUser := False;

  if not FindUserByName(name, user) then
    Exit;

  passwordHash := HashPassword(password);

  if user.Password = passwordHash then
    AuthenticateUser := True;
end;

function SetUserPasswordByID(id: TUserID; password: Str63): Boolean;
var
  user: TUser;
begin
  SetUserPasswordByID := False;

  if not FindUserByID(id, user) then
    Exit;

  user.Password := HashPassword(password);
  SetUserPasswordByID := UpdateUserByID(id, user);
end;

function SetUserPasswordByName(name: Str63; password: Str63): Boolean;
var
  user: TUser;
begin
  SetUserPasswordByName := False;

  if not FindUserByName(name, user) then
    Exit;

  user.Password := HashPassword(password);
  SetUserPasswordByName := UpdateUserByName(name, user);
end;

{ Access Control Functions }

function HasAccess(user: TUser; accessBit: TWord): Boolean;
begin
  HasAccess := (user.Access and accessBit) <> 0;
end;

function IsSysop(user: TUser): Boolean;
begin
  IsSysop := HasAccess(user, ACCESS_SYSOP);
end;

{ Module initialization }
begin
  Salt := DEFAULT_SALT;
  UserDatabase.IsOpen := False;
end.
