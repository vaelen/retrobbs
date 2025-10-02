unit User;

{
  User Management Library

  Manages user accounts and authentication for RetroBBS.
  Users are stored in a text-based data file (users.dat).

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

interface

uses
  BBSTypes, Hash;

const
  USER_FILE = 'users.dat';
  DEFAULT_SALT = 'retro';

  { Access Control Bits }
  ACCESS_SYSOP = $8000;  { Bit 15: System Operator }

type
  TUser = record
    ID: TUserID;          { Unique User Identifier }
    Name: Str64;         { Login Name or "Handle" }
    Password: SHA1Hash;  { SHA-1 Hash of Password }
    FullName: Str64;     { Real Name }
    Email: Str64;        { Email Address }
    Location: Str64;     { Physical Location }
    Access: Word;        { Access Control Bitmask }
  end;

var
  Salt: Str64;           { Password salt string }

{ User File Functions }

{ Load all users from file into memory }
procedure LoadUsers;

{ Save all users from memory to file }
procedure SaveUsers;

{ User Lookup Functions }

{ Find user by ID, returns true if found }
function FindUserByID(id: TUserID; var user: TUser): Boolean;

{ Find user by name (case insensitive), returns true if found }
function FindUserByName(name: Str64; var user: TUser): Boolean;

{ User Management Functions }

{ Add a new user, returns the new user ID }
function AddUser(name: Str64; password: Str64; fullName: Str64;
                 email: Str64; location: Str64): TUserID;

{ Update an existing user }
function SaveUser(user: TUser): Boolean;

{ Delete a user by ID }
function DeleteUser(id: TUserID): Boolean;

{ Authentication Functions }

{ Authenticate user with name and password, returns true if valid }
function AuthenticateUser(name: Str64; password: Str64): Boolean;

{ Set user password (re-hashes with salt) }
function SetUserPassword(id: TUserID; password: Str64): Boolean;

{ Hash password with salt }
function HashPassword(password: Str64): SHA1Hash;

{ Access Control Functions }

{ Check if user has specific access bit set }
function HasAccess(user: TUser; accessBit: Word): Boolean;

{ Check if user is a sysop }
function IsSysop(user: TUser): Boolean;

implementation

uses
  SysUtils;

const
  MAX_USERS = 1000;

var
  Users: array[0..MAX_USERS-1] of TUser;
  UserCount: Integer;
  NextUserID: TUserID;

{ Initialize module }
procedure InitModule;
begin
  UserCount := 0;
  NextUserID := 1;
  Salt := DEFAULT_SALT;
end;

{ User File Functions }

procedure LoadUsers;
var
  f: Text;
  line: Str255;
  user: TUser;
  parts: array[0..6] of Str64;
  i, partCount: Integer;
  currentPart: Str64;
  ch: Char;
begin
  UserCount := 0;

  Assign(f, USER_FILE);
  {$I-}
  Reset(f);
  {$I+}

  if IOResult <> 0 then
    Exit; { File doesn't exist yet }

  while not EOF(f) do
  begin
    ReadLn(f, line);

    { Skip empty lines }
    if Length(line) = 0 then
      Continue;

    { Parse tab-delimited line }
    partCount := 0;
    currentPart := '';

    for i := 1 to Length(line) do
    begin
      ch := line[i];
      if ch = #9 then  { Tab character }
      begin
        if partCount < 7 then
        begin
          parts[partCount] := currentPart;
          Inc(partCount);
          currentPart := '';
        end;
      end
      else
        currentPart := currentPart + ch;
    end;

    { Add last part }
    if partCount < 7 then
    begin
      parts[partCount] := currentPart;
      Inc(partCount);
    end;

    { Parse user record if we have all fields }
    if partCount = 7 then
    begin
      user.ID := StrToInt(parts[0]);
      user.Name := parts[1];
      user.Password := parts[2];
      user.FullName := parts[3];
      user.Email := parts[4];
      user.Location := parts[5];
      user.Access := StrToInt(parts[6]);

      { Store user }
      if UserCount < MAX_USERS then
      begin
        Users[UserCount] := user;
        Inc(UserCount);

        { Track highest user ID }
        if user.ID >= NextUserID then
          NextUserID := user.ID + 1;
      end;
    end;
  end;

  Close(f);
end;

procedure SaveUsers;
var
  f: Text;
  i: Integer;
  user: TUser;
begin
  Assign(f, USER_FILE);
  {$I-}
  Rewrite(f);
  {$I+}

  if IOResult <> 0 then
    Exit;

  for i := 0 to UserCount - 1 do
  begin
    user := Users[i];
    WriteLn(f, user.ID, #9, user.Name, #9, user.Password, #9,
            user.FullName, #9, user.Email, #9, user.Location, #9,
            user.Access);
  end;

  Close(f);
end;

{ User Lookup Functions }

function FindUserByID(id: TUserID; var user: TUser): Boolean;
var
  i: Integer;
begin
  FindUserByID := False;

  for i := 0 to UserCount - 1 do
  begin
    if Users[i].ID = id then
    begin
      user := Users[i];
      FindUserByID := True;
      Exit;
    end;
  end;
end;

function FindUserByName(name: Str64; var user: TUser): Boolean;
var
  i: Integer;
begin
  FindUserByName := False;

  for i := 0 to UserCount - 1 do
  begin
    if LowerCase(Users[i].Name) = LowerCase(name) then
    begin
      user := Users[i];
      FindUserByName := True;
      Exit;
    end;
  end;
end;

{ User Management Functions }

function AddUser(name: Str64; password: Str64; fullName: Str64;
                 email: Str64; location: Str64): TUserID;
var
  user: TUser;
begin
  AddUser := 0;

  if UserCount >= MAX_USERS then
    Exit;

  { Check if user already exists }
  if FindUserByName(name, user) then
    Exit;

  { Create new user }
  user.ID := NextUserID;
  user.Name := name;
  user.Password := HashPassword(password);
  user.FullName := fullName;
  user.Email := email;
  user.Location := location;
  user.Access := 0;

  { Store user }
  Users[UserCount] := user;
  Inc(UserCount);
  Inc(NextUserID);

  { Save to file }
  SaveUsers;

  AddUser := user.ID;
end;

function SaveUser(user: TUser): Boolean;
var
  i: Integer;
begin
  SaveUser := False;

  for i := 0 to UserCount - 1 do
  begin
    if Users[i].ID = user.ID then
    begin
      Users[i] := user;
      SaveUsers;
      SaveUser := True;
      Exit;
    end;
  end;
end;

function DeleteUser(id: TUserID): Boolean;
var
  i, j: Integer;
begin
  DeleteUser := False;

  for i := 0 to UserCount - 1 do
  begin
    if Users[i].ID = id then
    begin
      { Shift all users after this one down }
      for j := i to UserCount - 2 do
        Users[j] := Users[j + 1];

      Dec(UserCount);
      SaveUsers;
      DeleteUser := True;
      Exit;
    end;
  end;
end;

{ Authentication Functions }

function HashPassword(password: Str64): SHA1Hash;
var
  saltedPassword: Str255;
  data: array[0..254] of Byte;
  digest: TSHA1Digest;
  i: Integer;
begin
  { Concatenate password with salt }
  saltedPassword := password + Salt;

  { Convert to byte array }
  for i := 1 to Length(saltedPassword) do
    data[i - 1] := Ord(saltedPassword[i]);

  { Hash with SHA-1 }
  digest := SHA1(data, Length(saltedPassword));

  { Convert to hex string }
  HashPassword := '';
  for i := 0 to 19 do
    HashPassword := HashPassword + LowerCase(IntToHex(digest[i], 2));
end;

function AuthenticateUser(name: Str64; password: Str64): Boolean;
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

function SetUserPassword(id: TUserID; password: Str64): Boolean;
var
  user: TUser;
begin
  SetUserPassword := False;

  if not FindUserByID(id, user) then
    Exit;

  user.Password := HashPassword(password);
  SetUserPassword := SaveUser(user);
end;

{ Access Control Functions }

function HasAccess(user: TUser; accessBit: Word): Boolean;
begin
  HasAccess := (user.Access and accessBit) <> 0;
end;

function IsSysop(user: TUser): Boolean;
begin
  IsSysop := HasAccess(user, ACCESS_SYSOP);
end;

{ Module initialization }
begin
  InitModule;
end.
