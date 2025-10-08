program MakeUsers;

{
  Create Test Users

  Creates sample users in the user database for testing the useradm utility.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  BBSTypes, User, SysUtils;

var
  id: TUserID;

begin
  WriteLn('Creating test users...');

  { Initialize user database }
  if not InitUserDatabase then
  begin
    WriteLn('Error: Could not initialize user database');
    Halt(1);
  end;

  { Create sample users }
  id := AddUser('sysop', 'password', 'System Operator', 'sysop@retrobbs.local', 'Console');
  if id > 0 then
    WriteLn('Created user: sysop (ID: ', id, ')')
  else
    WriteLn('User sysop already exists or error occurred');

  id := AddUser('alice', 'password', 'Alice Johnson', 'alice@example.com', 'New York');
  if id > 0 then
    WriteLn('Created user: alice (ID: ', id, ')')
  else
    WriteLn('User alice already exists or error occurred');

  id := AddUser('bob', 'password', 'Bob Smith', 'bob@example.com', 'Los Angeles');
  if id > 0 then
    WriteLn('Created user: bob (ID: ', id, ')')
  else
    WriteLn('User bob already exists or error occurred');

  id := AddUser('charlie', 'password', 'Charlie Brown', 'charlie@example.com', 'Chicago');
  if id > 0 then
    WriteLn('Created user: charlie (ID: ', id, ')')
  else
    WriteLn('User charlie already exists or error occurred');

  id := AddUser('diana', 'password', 'Diana Prince', 'diana@example.com', 'Seattle');
  if id > 0 then
    WriteLn('Created user: diana (ID: ', id, ')')
  else
    WriteLn('User diana already exists or error occurred');

  id := AddUser('eve', 'password', 'Eve Anderson', 'eve@example.com', 'Boston');
  if id > 0 then
    WriteLn('Created user: eve (ID: ', id, ')')
  else
    WriteLn('User eve already exists or error occurred');

  id := AddUser('frank', 'password', 'Frank Miller', 'frank@example.com', 'Austin');
  if id > 0 then
    WriteLn('Created user: frank (ID: ', id, ')')
  else
    WriteLn('User frank already exists or error occurred');

  id := AddUser('grace', 'password', 'Grace Hopper', 'grace@example.com', 'San Diego');
  if id > 0 then
    WriteLn('Created user: grace (ID: ', id, ')')
  else
    WriteLn('User grace already exists or error occurred');

  id := AddUser('henry', 'password', 'Henry Ford', 'henry@example.com', 'Detroit');
  if id > 0 then
    WriteLn('Created user: henry (ID: ', id, ')')
  else
    WriteLn('User henry already exists or error occurred');

  id := AddUser('iris', 'password', 'Iris West', 'iris@example.com', 'Portland');
  if id > 0 then
    WriteLn('Created user: iris (ID: ', id, ')')
  else
    WriteLn('User iris already exists or error occurred');

  { Close database }
  CloseUserDatabase;

  WriteLn;
  WriteLn('Done! Created test users.');
  WriteLn('Run bin/utils/useradm to manage users.');
end.
