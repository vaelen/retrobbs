program Minimal;

uses
  BBSTypes, DB, SysUtils;

procedure CleanUp;
begin
  {$I-}
  DeleteFile('tests/db/test.dat');
  DeleteFile('tests/db/test.idx');
  DeleteFile('tests/db/test.jnl');
  {$I+}
end;

var
  database: TDatabase;
  recID: LongInt;
  i: Integer;
  data: array[0..127] of Byte;

begin
  WriteLn('Test 1');
  database.IsOpen := False;
  WriteLn('Test 2');

  CleanUp;

  WriteLn('Test 3: CreateDatabase');
  if CreateDatabase('tests/db/test', 128) then
    WriteLn('SUCCESS')
  else
    WriteLn('FAILED');

  WriteLn('Test 4: OpenDatabase');
  if OpenDatabase('tests/db/test', database) then
  begin
    WriteLn('SUCCESS');

    WriteLn('Test 5: AddRecord');
    for i := 0 to 127 do
      data[i] := 42;

    if AddRecord(database, data, recID) then
      WriteLn('SUCCESS - Record ID: ', recID)
    else
      WriteLn('FAILED');

    CloseDatabase(database);
  end
  else
    WriteLn('FAILED');
    
  CleanUp;
end.
