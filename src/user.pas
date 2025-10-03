unit User;

{
  User Management Library

  Manages user accounts and authentication for RetroBBS.
  Users are stored in a text-based data file (users.dat).

  This implementation uses file-based lookups to minimize memory usage.
  User records are read from and written to the file as needed.

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
    ID: TUserID;         { Unique User Identifier }
    Name: Str64;         { Login Name or "Handle" }
    Password: SHA1Hash;  { SHA-1 Hash of Password }
    FullName: Str64;     { Real Name }
    Email: Str64;        { Email Address }
    Location: Str64;     { Physical Location }
    Access: Word;        { Access Control Bitmask }
  end;

var
  Salt: Str64;           { Password salt string }

{ User Lookup Functions }

{ Find user by ID, returns true if found }
function FindUserByID(id: TUserID; var user: TUser): Boolean;

{ Find user by name (case insensitive), returns true if found }
function FindUserByName(name: Str64; var user: TUser): Boolean;

{ User Management Functions }

{ Add a new user, returns the new user ID (0 on failure) }
function AddUser(name: Str64; password: Str64; fullName: Str64;
                 email: Str64; location: Str64): TUserID;

{ Update an existing user by ID }
function UpdateUserByID(id: TUserID; user: TUser): Boolean;

{ Update an existing user by name }
function UpdateUserByName(name: Str64; user: TUser): Boolean;

{ Delete a user by ID }
function DeleteUserByID(id: TUserID): Boolean;

{ Delete a user by name }
function DeleteUserByName(name: Str64): Boolean;

{ Get the next available user ID }
function GetNextUserID: TUserID;

{ Authentication Functions }

{ Authenticate user with name and password, returns true if valid }
function AuthenticateUser(name: Str64; password: Str64): Boolean;

{ Set user password by ID (re-hashes with salt) }
function SetUserPasswordByID(id: TUserID; password: Str64): Boolean;

{ Set user password by name (re-hashes with salt) }
function SetUserPasswordByName(name: Str64; password: Str64): Boolean;

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

{ Helper function to parse a tab-delimited line into a user record }
function ParseUserLine(line: Str255; var user: TUser): Boolean;
var
  parts: array[0..6] of Str64;
  partCount: Integer;
  currentPart: Str64;
  ch: Char;
  i: Integer;
begin
  ParseUserLine := False;

  { Skip empty lines }
  if Length(line) = 0 then
    Exit;

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
    ParseUserLine := True;
  end;
end;

{ Helper function to format a user record as a tab-delimited line }
function FormatUserLine(user: TUser): Str255;
begin
  FormatUserLine := IntToStr(user.ID) + #9 +
                   user.Name + #9 +
                   user.Password + #9 +
                   user.FullName + #9 +
                   user.Email + #9 +
                   user.Location + #9 +
                   IntToStr(user.Access);
end;

{ User Lookup Functions }

function FindUserByID(id: TUserID; var user: TUser): Boolean;
var
  f: Text;
  line: Str255;
  tempUser: TUser;
begin
  FindUserByID := False;

  Assign(f, USER_FILE);
  {$I-}
  Reset(f);
  {$I+}

  if IOResult <> 0 then
    Exit; { File doesn't exist }

  while not EOF(f) do
  begin
    ReadLn(f, line);
    if ParseUserLine(line, tempUser) then
    begin
      if tempUser.ID = id then
      begin
        user := tempUser;
        FindUserByID := True;
        Close(f);
        Exit;
      end;
    end;
  end;

  Close(f);
end;

function FindUserByName(name: Str64; var user: TUser): Boolean;
var
  f: Text;
  line: Str255;
  tempUser: TUser;
begin
  FindUserByName := False;

  Assign(f, USER_FILE);
  {$I-}
  Reset(f);
  {$I+}

  if IOResult <> 0 then
    Exit; { File doesn't exist }

  while not EOF(f) do
  begin
    ReadLn(f, line);
    if ParseUserLine(line, tempUser) then
    begin
      if LowerCase(tempUser.Name) = LowerCase(name) then
      begin
        user := tempUser;
        FindUserByName := True;
        Close(f);
        Exit;
      end;
    end;
  end;

  Close(f);
end;

{ User Management Functions }

function GetNextUserID: TUserID;
var
  f: Text;
  line: Str255;
  user: TUser;
  maxID: TUserID;
begin
  maxID := 0;

  Assign(f, USER_FILE);
  {$I-}
  Reset(f);
  {$I+}

  if IOResult <> 0 then
  begin
    GetNextUserID := 1; { File doesn't exist, start at 1 }
    Exit;
  end;

  while not EOF(f) do
  begin
    ReadLn(f, line);
    if ParseUserLine(line, user) then
    begin
      if user.ID > maxID then
        maxID := user.ID;
    end;
  end;

  Close(f);
  GetNextUserID := maxID + 1;
end;

function AddUser(name: Str64; password: Str64; fullName: Str64;
                 email: Str64; location: Str64): TUserID;
var
  f: Text;
  user: TUser;
begin
  AddUser := 0;

  { Check if user already exists }
  if FindUserByName(name, user) then
    Exit;

  { Create new user }
  user.ID := GetNextUserID;
  user.Name := name;
  user.Password := HashPassword(password);
  user.FullName := fullName;
  user.Email := email;
  user.Location := location;
  user.Access := 0;

  { Append to file }
  Assign(f, USER_FILE);
  {$I-}
  Append(f);
  {$I+}

  if IOResult <> 0 then
  begin
    { File doesn't exist, create it }
    {$I-}
    Rewrite(f);
    {$I+}
    if IOResult <> 0 then
      Exit;
  end;

  WriteLn(f, FormatUserLine(user));
  Close(f);

  AddUser := user.ID;
end;

function UpdateUserByID(id: TUserID; user: TUser): Boolean;
var
  oldFile, newFile: Text;
  line: Str255;
  tempUser: TUser;
  found: Boolean;
begin
  UpdateUserByID := False;
  found := False;

  Assign(oldFile, USER_FILE);
  {$I-}
  Reset(oldFile);
  {$I+}

  if IOResult <> 0 then
    Exit; { File doesn't exist }

  Assign(newFile, USER_FILE + '.tmp');
  {$I-}
  Rewrite(newFile);
  {$I+}

  if IOResult <> 0 then
  begin
    Close(oldFile);
    Exit;
  end;

  { Copy all records, replacing the matching one }
  while not EOF(oldFile) do
  begin
    ReadLn(oldFile, line);
    if ParseUserLine(line, tempUser) then
    begin
      if tempUser.ID = id then
      begin
        WriteLn(newFile, FormatUserLine(user));
        found := True;
      end
      else
        WriteLn(newFile, line);
    end;
  end;

  Close(oldFile);
  Close(newFile);

  if found then
  begin
    { Replace old file with new file }
    {$I-}
    Erase(oldFile);
    Rename(newFile, USER_FILE);
    {$I+}
    UpdateUserByID := IOResult = 0;
  end
  else
  begin
    { Not found, remove temp file }
    {$I-}
    Erase(newFile);
    {$I+}
  end;
end;

function UpdateUserByName(name: Str64; user: TUser): Boolean;
var
  oldFile, newFile: Text;
  line: Str255;
  tempUser: TUser;
  found: Boolean;
begin
  UpdateUserByName := False;
  found := False;

  Assign(oldFile, USER_FILE);
  {$I-}
  Reset(oldFile);
  {$I+}

  if IOResult <> 0 then
    Exit; { File doesn't exist }

  Assign(newFile, USER_FILE + '.tmp');
  {$I-}
  Rewrite(newFile);
  {$I+}

  if IOResult <> 0 then
  begin
    Close(oldFile);
    Exit;
  end;

  { Copy all records, replacing the matching one }
  while not EOF(oldFile) do
  begin
    ReadLn(oldFile, line);
    if ParseUserLine(line, tempUser) then
    begin
      if LowerCase(tempUser.Name) = LowerCase(name) then
      begin
        WriteLn(newFile, FormatUserLine(user));
        found := True;
      end
      else
        WriteLn(newFile, line);
    end;
  end;

  Close(oldFile);
  Close(newFile);

  if found then
  begin
    { Replace old file with new file }
    {$I-}
    Erase(oldFile);
    Rename(newFile, USER_FILE);
    {$I+}
    UpdateUserByName := IOResult = 0;
  end
  else
  begin
    { Not found, remove temp file }
    {$I-}
    Erase(newFile);
    {$I+}
  end;
end;

function DeleteUserByID(id: TUserID): Boolean;
var
  oldFile, newFile: Text;
  line: Str255;
  user: TUser;
  found: Boolean;
begin
  DeleteUserByID := False;
  found := False;

  Assign(oldFile, USER_FILE);
  {$I-}
  Reset(oldFile);
  {$I+}

  if IOResult <> 0 then
    Exit; { File doesn't exist }

  Assign(newFile, USER_FILE + '.tmp');
  {$I-}
  Rewrite(newFile);
  {$I+}

  if IOResult <> 0 then
  begin
    Close(oldFile);
    Exit;
  end;

  { Copy all records except the one to delete }
  while not EOF(oldFile) do
  begin
    ReadLn(oldFile, line);
    if ParseUserLine(line, user) then
    begin
      if user.ID = id then
        found := True
      else
        WriteLn(newFile, line);
    end;
  end;

  Close(oldFile);
  Close(newFile);

  if found then
  begin
    { Replace old file with new file }
    {$I-}
    Erase(oldFile);
    Rename(newFile, USER_FILE);
    {$I+}
    DeleteUserByID := IOResult = 0;
  end
  else
  begin
    { Not found, remove temp file }
    {$I-}
    Erase(newFile);
    {$I+}
  end;
end;

function DeleteUserByName(name: Str64): Boolean;
var
  oldFile, newFile: Text;
  line: Str255;
  user: TUser;
  found: Boolean;
begin
  DeleteUserByName := False;
  found := False;

  Assign(oldFile, USER_FILE);
  {$I-}
  Reset(oldFile);
  {$I+}

  if IOResult <> 0 then
    Exit; { File doesn't exist }

  Assign(newFile, USER_FILE + '.tmp');
  {$I-}
  Rewrite(newFile);
  {$I+}

  if IOResult <> 0 then
  begin
    Close(oldFile);
    Exit;
  end;

  { Copy all records except the one to delete }
  while not EOF(oldFile) do
  begin
    ReadLn(oldFile, line);
    if ParseUserLine(line, user) then
    begin
      if LowerCase(user.Name) = LowerCase(name) then
        found := True
      else
        WriteLn(newFile, line);
    end;
  end;

  Close(oldFile);
  Close(newFile);

  if found then
  begin
    { Replace old file with new file }
    {$I-}
    Erase(oldFile);
    Rename(newFile, USER_FILE);
    {$I+}
    DeleteUserByName := IOResult = 0;
  end
  else
  begin
    { Not found, remove temp file }
    {$I-}
    Erase(newFile);
    {$I+}
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

function SetUserPasswordByID(id: TUserID; password: Str64): Boolean;
var
  user: TUser;
begin
  SetUserPasswordByID := False;

  if not FindUserByID(id, user) then
    Exit;

  user.Password := HashPassword(password);
  SetUserPasswordByID := UpdateUserByID(id, user);
end;

function SetUserPasswordByName(name: Str64; password: Str64): Boolean;
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
  Salt := DEFAULT_SALT;
end.
