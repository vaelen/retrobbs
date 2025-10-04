program UserTest;

{
  User Management Unit Test

  Tests the User unit functions.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  BBSTypes, User, SysUtils;

var
  passed: Integer;
  failed: Integer;

procedure TestPasswordHashing;
var
  hash1, hash2: SHA1Hash;
begin
  Write('Password hashing with salt: ');

  { Set custom salt }
  Salt := 'testsalt';

  hash1 := HashPassword('password123');
  hash2 := HashPassword('password123');

  { Same password should produce same hash }
  if hash1 = hash2 then
  begin
    WriteLn('PASS (', hash1, ')');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (hashes don''t match)');
    Inc(failed);
  end;

  Write('Different passwords produce different hashes: ');
  hash2 := HashPassword('differentpass');

  if hash1 <> hash2 then
  begin
    WriteLn('PASS');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (hashes should be different)');
    Inc(failed);
  end;
end;

procedure TestUserCreation;
var
  userID: TUserID;
  user: TUser;
begin
  Write('Add new user: ');

  userID := AddUser('testuser', 'password123', 'Test User',
                    'test@example.com', 'Test Location');

  if userID > 0 then
  begin
    WriteLn('PASS (ID=', userID, ')');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (ID should be > 0)');
    Inc(failed);
  end;

  Write('Find user by ID: ');
  if FindUserByID(userID, user) then
  begin
    if (user.Name = 'testuser') and (user.FullName = 'Test User') then
    begin
      WriteLn('PASS (', user.Name, ')');
      Inc(passed);
    end
    else
    begin
      WriteLn('FAIL (user data mismatch)');
      Inc(failed);
    end;
  end
  else
  begin
    WriteLn('FAIL (user not found)');
    Inc(failed);
  end;

  Write('Find user by name: ');
  if FindUserByName('testuser', user) then
  begin
    if user.ID = userID then
    begin
      WriteLn('PASS (ID=', user.ID, ')');
      Inc(passed);
    end
    else
    begin
      WriteLn('FAIL (ID mismatch)');
      Inc(failed);
    end;
  end
  else
  begin
    WriteLn('FAIL (user not found)');
    Inc(failed);
  end;

  Write('Find user by name (case insensitive): ');
  if FindUserByName('TESTUSER', user) then
  begin
    if user.ID = userID then
    begin
      WriteLn('PASS');
      Inc(passed);
    end
    else
    begin
      WriteLn('FAIL (ID mismatch)');
      Inc(failed);
    end;
  end
  else
  begin
    WriteLn('FAIL (user not found)');
    Inc(failed);
  end;
end;

procedure TestAuthentication;
var
  user: TUser;
begin
  Write('Authenticate valid user: ');
  if AuthenticateUser('testuser', 'password123') then
  begin
    WriteLn('PASS');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (authentication should succeed)');
    Inc(failed);
  end;

  Write('Reject invalid password: ');
  if not AuthenticateUser('testuser', 'wrongpassword') then
  begin
    WriteLn('PASS');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (authentication should fail)');
    Inc(failed);
  end;

  Write('Reject non-existent user: ');
  if not AuthenticateUser('nonexistent', 'password') then
  begin
    WriteLn('PASS');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (authentication should fail)');
    Inc(failed);
  end;

  Write('Change user password: ');
  if FindUserByName('testuser', user) then
  begin
    if SetUserPasswordByID(user.ID, 'newpassword') then
    begin
      if AuthenticateUser('testuser', 'newpassword') then
      begin
        WriteLn('PASS');
        Inc(passed);
      end
      else
      begin
        WriteLn('FAIL (new password doesn''t work)');
        Inc(failed);
      end;
    end
    else
    begin
      WriteLn('FAIL (password change failed)');
      Inc(failed);
    end;
  end
  else
  begin
    WriteLn('FAIL (user not found)');
    Inc(failed);
  end;
end;

procedure TestAccessControl;
var
  user: TUser;
begin
  Write('User access control (no access): ');
  if FindUserByName('testuser', user) then
  begin
    if not HasAccess(user, ACCESS_SYSOP) then
    begin
      WriteLn('PASS');
      Inc(passed);
    end
    else
    begin
      WriteLn('FAIL (should not have sysop access)');
      Inc(failed);
    end;
  end
  else
  begin
    WriteLn('FAIL (user not found)');
    Inc(failed);
  end;

  Write('Grant sysop access: ');
  if FindUserByName('testuser', user) then
  begin
    user.Access := user.Access or ACCESS_SYSOP;
    if UpdateUserByID(user.ID, user) then
    begin
      { Re-load user to verify }
      if FindUserByID(user.ID, user) then
      begin
        if IsSysop(user) then
        begin
          WriteLn('PASS');
          Inc(passed);
        end
        else
        begin
          WriteLn('FAIL (sysop access not saved)');
          Inc(failed);
        end;
      end
      else
      begin
        WriteLn('FAIL (user not found after save)');
        Inc(failed);
      end;
    end
    else
    begin
      WriteLn('FAIL (save failed)');
      Inc(failed);
    end;
  end
  else
  begin
    WriteLn('FAIL (user not found)');
    Inc(failed);
  end;
end;

procedure TestFilePersistence;
var
  userID: TUserID;
  user: TUser;
begin
  Write('File persistence (data persists): ');

  { File-based storage persists automatically }
  { Just verify user still exists by reading from file }
  if FindUserByName('testuser', user) then
  begin
    if (user.FullName = 'Test User') and IsSysop(user) then
    begin
      WriteLn('PASS');
      Inc(passed);
    end
    else
    begin
      WriteLn('FAIL (user data lost)');
      Inc(failed);
    end;
  end
  else
  begin
    WriteLn('FAIL (user not found)');
    Inc(failed);
  end;
end;

procedure TestUserDeletion;
var
  user: TUser;
begin
  Write('Delete user: ');

  if FindUserByName('testuser', user) then
  begin
    if DeleteUserByID(user.ID) then
    begin
      if not FindUserByID(user.ID, user) then
      begin
        WriteLn('PASS');
        Inc(passed);
      end
      else
      begin
        WriteLn('FAIL (user still exists)');
        Inc(failed);
      end;
    end
    else
    begin
      WriteLn('FAIL (delete failed)');
      Inc(failed);
    end;
  end
  else
  begin
    WriteLn('FAIL (user not found)');
    Inc(failed);
  end;
end;

procedure Cleanup;
var
  f: File;
begin
  { Close database }
  CloseUserDatabase;

  { Remove test database files }
  Assign(f, 'users.dat');
  {$I-}
  Erase(f);
  {$I+}

  Assign(f, 'users.jnl');
  {$I-}
  Erase(f);
  {$I+}

  Assign(f, 'users.idx');
  {$I-}
  Erase(f);
  {$I+}

  Assign(f, 'users.i00');
  {$I-}
  Erase(f);
  {$I+}
end;

begin
  passed := 0;
  failed := 0;

  WriteLn('User Management Unit Test Suite');
  WriteLn('================================');
  WriteLn;

  { Set custom salt for testing }
  Salt := 'testsalt';

  { Test password hashing }
  WriteLn('Password Hashing:');
  TestPasswordHashing;
  WriteLn;

  { Test user creation }
  WriteLn('User Creation:');
  TestUserCreation;
  WriteLn;

  { Test authentication }
  WriteLn('Authentication:');
  TestAuthentication;
  WriteLn;

  { Test access control }
  WriteLn('Access Control:');
  TestAccessControl;
  WriteLn;

  { Test file persistence }
  WriteLn('File Persistence:');
  TestFilePersistence;
  WriteLn;

  { Test user deletion }
  WriteLn('User Deletion:');
  TestUserDeletion;
  WriteLn;

  { Summary }
  WriteLn('================================');
  WriteLn('Tests passed: ', passed);
  WriteLn('Tests failed: ', failed);

  { Cleanup }
  Cleanup;

  if failed > 0 then
    Halt(1);
end.
