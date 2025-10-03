program DBSimpleTest;

{
  Simple DB Test - Minimal test to isolate issue

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  BBSTypes, DB, SysUtils;

procedure CleanUp;
begin
  {$I-}
  DeleteFile('tests/db/simple.dat');
  DeleteFile('tests/db/simple.idx');
  DeleteFile('tests/db/simple.jnl');
  {$I+}
end;

var
  database: TDatabase;
  data: array[0..127] of Byte;
  recordID: LongInt;
  i: Integer;

begin
  WriteLn('Simple DB Test');
  WriteLn('==============');

  { Clean up }
  CleanUp;

  WriteLn('Creating database...');
  if not CreateDatabase('tests/db/simple', 128) then
  begin
    WriteLn('FAILED to create database');
    Halt(1);
  end;
  WriteLn('OK');

  WriteLn('Opening database...');
  if not OpenDatabase('tests/db/simple', database) then
  begin
    WriteLn('FAILED to open database');
    Halt(1);
  end;
  WriteLn('OK');

  WriteLn('Preparing data...');
  for i := 0 to 127 do
    data[i] := 42;
  WriteLn('OK');

  WriteLn('Adding record...');
  if not AddRecord(database, data, recordID) then
  begin
    WriteLn('FAILED to add record');
    CloseDatabase(database);
    Halt(1);
  end;
  WriteLn('OK - Record ID: ', recordID);

  WriteLn('Closing database...');
  CloseDatabase(database);
  WriteLn('OK');

  { Clean up }
  CleanUp;

  WriteLn;
  WriteLn('All tests PASSED!');
end.
