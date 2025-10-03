program DBTest;

{
  Database Library Test Program

  Comprehensive test suite for the DB library.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  BBSTypes, DB, SysUtils;

var
  TestsPassed: Integer;
  TestsFailed: Integer;

procedure PrintTestHeader(testName: String);
begin
  WriteLn;
  WriteLn('===== ', testName, ' =====');
end;

procedure PrintTestResult(testName: String; passed: Boolean);
begin
  if passed then
  begin
    WriteLn('[PASS] ', testName);
    Inc(TestsPassed);
  end
  else
  begin
    WriteLn('[FAIL] ', testName);
    Inc(TestsFailed);
  end;
end;

procedure TestCreateDatabase;
var
  result: Boolean;
begin
  PrintTestHeader('Test: Create Database');

  result := CreateDatabase('tests/db/testdb', 128);
  PrintTestResult('CreateDatabase with 128-byte records', result);

  result := CreateDatabase('tests/db/testdb2', 1024);
  PrintTestResult('CreateDatabase with 1024-byte records (multi-page)', result);

  result := not CreateDatabase('tests/db/testdb3', 0);
  PrintTestResult('CreateDatabase rejects 0-byte records', result);
end;

procedure TestOpenCloseDatabase;
var
  db: TDatabase;
  result: Boolean;
begin
  PrintTestHeader('Test: Open/Close Database');

  result := OpenDatabase('tests/db/testdb', db);
  PrintTestResult('OpenDatabase existing database', result);

  if result then
  begin
    CloseDatabase(db);
    PrintTestResult('CloseDatabase', True);
  end;

  result := not OpenDatabase('nonexistent', db);
  PrintTestResult('OpenDatabase rejects non-existent database', result);
end;

procedure TestAddRecord;
var
  db: TDatabase;
  data: array[0..127] of Byte;
  recordID: LongInt;
  result: Boolean;
  i: Integer;
begin
  PrintTestHeader('Test: Add Record');

  if not OpenDatabase('tests/db/testdb', db) then
  begin
    PrintTestResult('Failed to open database', False);
    Exit;
  end;

  { Fill data with test pattern }
  for i := 0 to 127 do
    data[i] := i mod 256;

  result := AddRecord(db, data, recordID);
  PrintTestResult('AddRecord (single page)', result);

  if result then
    PrintTestResult('Record ID assigned correctly', recordID = 1);

  CloseDatabase(db);
end;

procedure TestAddMultipleRecords;
var
  db: TDatabase;
  data: array[0..127] of Byte;
  recordID: LongInt;
  result: Boolean;
  i, j: Integer;
  allPassed: Boolean;
begin
  PrintTestHeader('Test: Add Multiple Records');

  if not OpenDatabase('tests/db/testdb', db) then
  begin
    PrintTestResult('Failed to open database', False);
    Exit;
  end;

  allPassed := True;
  for i := 1 to 10 do
  begin
    { Fill with unique pattern }
    for j := 0 to 127 do
      data[j] := (i * 10 + j) mod 256;

    result := AddRecord(db, data, recordID);
    if not result then
      allPassed := False;
  end;

  PrintTestResult('Add 10 records', allPassed);
  PrintTestResult('Record count is correct', db.Header.RecordCount = 11); { 1 from previous test + 10 }

  CloseDatabase(db);
end;

procedure TestFindRecordByID;
var
  db: TDatabase;
  writeData, readData: array[0..127] of Byte;
  recordID: LongInt;
  result: Boolean;
  i: Integer;
  match: Boolean;
begin
  PrintTestHeader('Test: Find Record by ID');

  if not OpenDatabase('tests/db/testdb', db) then
  begin
    PrintTestResult('Failed to open database', False);
    Exit;
  end;

  { Create a new record with known data }
  for i := 0 to 127 do
    writeData[i] := 42;

  result := AddRecord(db, writeData, recordID);
  if not result then
  begin
    PrintTestResult('Failed to add record', False);
    CloseDatabase(db);
    Exit;
  end;

  { Find the record }
  FillChar(readData, SizeOf(readData), 0);
  result := FindRecordByID(db, recordID, readData);
  PrintTestResult('FindRecordByID found record', result);

  { Verify data matches }
  match := True;
  for i := 0 to 127 do
  begin
    if readData[i] <> writeData[i] then
    begin
      match := False;
      Break;
    end;
  end;

  PrintTestResult('FindRecordByID data matches', match);

  { Try to find non-existent record }
  result := not FindRecordByID(db, 99999, readData);
  PrintTestResult('FindRecordByID returns false for non-existent record', result);

  CloseDatabase(db);
end;

procedure TestUpdateRecord;
var
  db: TDatabase;
  writeData, updateData, readData: array[0..127] of Byte;
  recordID: LongInt;
  result: Boolean;
  i: Integer;
  match: Boolean;
begin
  PrintTestHeader('Test: Update Record');

  if not OpenDatabase('tests/db/testdb', db) then
  begin
    PrintTestResult('Failed to open database', False);
    Exit;
  end;

  { Create a record }
  for i := 0 to 127 do
    writeData[i] := 100;

  result := AddRecord(db, writeData, recordID);
  if not result then
  begin
    PrintTestResult('Failed to add record', False);
    CloseDatabase(db);
    Exit;
  end;

  { Update the record }
  for i := 0 to 127 do
    updateData[i] := 200;

  result := UpdateRecord(db, recordID, updateData);
  PrintTestResult('UpdateRecord succeeded', result);

  { Verify update }
  FillChar(readData, SizeOf(readData), 0);
  result := FindRecordByID(db, recordID, readData);

  match := True;
  for i := 0 to 127 do
  begin
    if readData[i] <> updateData[i] then
    begin
      match := False;
      Break;
    end;
  end;

  PrintTestResult('UpdateRecord data matches', match);

  CloseDatabase(db);
end;

procedure TestDeleteRecord;
var
  db: TDatabase;
  data: array[0..127] of Byte;
  recordID: LongInt;
  result: Boolean;
  i: Integer;
  initialCount: LongInt;
begin
  PrintTestHeader('Test: Delete Record');

  if not OpenDatabase('tests/db/testdb', db) then
  begin
    PrintTestResult('Failed to open database', False);
    Exit;
  end;

  initialCount := db.Header.RecordCount;

  { Create a record }
  for i := 0 to 127 do
    data[i] := 123;

  result := AddRecord(db, data, recordID);
  if not result then
  begin
    PrintTestResult('Failed to add record', False);
    CloseDatabase(db);
    Exit;
  end;

  { Delete the record }
  result := DeleteRecord(db, recordID);
  PrintTestResult('DeleteRecord succeeded', result);

  { Verify record is gone }
  FillChar(data, SizeOf(data), 0);
  result := not FindRecordByID(db, recordID, data);
  PrintTestResult('DeleteRecord removed record', result);

  { Verify record count decreased }
  PrintTestResult('Record count decreased', db.Header.RecordCount = initialCount);

  CloseDatabase(db);
end;

procedure TestMultiPageRecords;
var
  db: TDatabase;
  writeData, readData: array[0..1023] of Byte;
  recordID: LongInt;
  result: Boolean;
  i: Integer;
  match: Boolean;
begin
  PrintTestHeader('Test: Multi-Page Records');

  if not OpenDatabase('tests/db/testdb2', db) then
  begin
    PrintTestResult('Failed to open database', False);
    Exit;
  end;

  { Create record with pattern }
  for i := 0 to 1023 do
    writeData[i] := (i * 7) mod 256;

  result := AddRecord(db, writeData, recordID);
  PrintTestResult('Add multi-page record', result);

  { Read it back }
  FillChar(readData, SizeOf(readData), 0);
  result := FindRecordByID(db, recordID, readData);
  PrintTestResult('Find multi-page record', result);

  { Verify all data }
  match := True;
  for i := 0 to 1023 do
  begin
    if readData[i] <> writeData[i] then
    begin
      match := False;
      WriteLn('Mismatch at byte ', i, ': expected ', writeData[i], ', got ', readData[i]);
      Break;
    end;
  end;

  PrintTestResult('Multi-page record data integrity', match);

  CloseDatabase(db);
end;

procedure TestPersistence;
var
  db: TDatabase;
  data: array[0..127] of Byte;
  recordID: LongInt;
  result: Boolean;
  i: Integer;
begin
  PrintTestHeader('Test: Persistence (Close and Reopen)');

  { Create database, add record, close }
  if not CreateDatabase('tests/db/testpers', 128) then
  begin
    PrintTestResult('Failed to create database', False);
    Exit;
  end;

  if not OpenDatabase('tests/db/testpers', db) then
  begin
    PrintTestResult('Failed to open database', False);
    Exit;
  end;

  for i := 0 to 127 do
    data[i] := 88;

  result := AddRecord(db, data, recordID);
  CloseDatabase(db);

  { Reopen and verify }
  if not OpenDatabase('tests/db/testpers', db) then
  begin
    PrintTestResult('Failed to reopen database', False);
    Exit;
  end;

  FillChar(data, SizeOf(data), 0);
  result := FindRecordByID(db, recordID, data);
  PrintTestResult('Persistence: record found after reopen', result);

  PrintTestResult('Persistence: data correct after reopen', data[0] = 88);

  CloseDatabase(db);
end;

procedure TestFreeSpaceReclamation;
var
  db: TDatabase;
  data: array[0..127] of Byte;
  recordID1, recordID2: LongInt;
  result: Boolean;
  i: Integer;
  freeCountBeforeDelete: Word;
begin
  PrintTestHeader('Test: Free Space Reclamation');

  if not OpenDatabase('tests/db/testdb', db) then
  begin
    PrintTestResult('Failed to open database', False);
    Exit;
  end;

  { Add a record }
  for i := 0 to 127 do
    data[i] := 55;

  AddRecord(db, data, recordID1);

  { Save free count before delete }
  freeCountBeforeDelete := db.FreeList.FreePageCount;

  { Delete it }
  result := DeleteRecord(db, recordID1);
  PrintTestResult('Delete record for free space test', result);

  { Check free count increased }
  PrintTestResult('Free page count increased', db.FreeList.FreePageCount > freeCountBeforeDelete);

  { Add another record - should reuse freed space }
  for i := 0 to 127 do
    data[i] := 66;

  result := AddRecord(db, data, recordID2);
  PrintTestResult('Add record after delete', result);

  CloseDatabase(db);
end;

procedure TestValidation;
var
  db: TDatabase;
  result: Boolean;
begin
  PrintTestHeader('Test: Database Validation');

  if not OpenDatabase('tests/db/testdb', db) then
  begin
    PrintTestResult('Failed to open database', False);
    Exit;
  end;

  result := ValidateDatabase(db);
  PrintTestResult('ValidateDatabase on healthy database', result);

  CloseDatabase(db);
end;

procedure PrintSummary;
begin
  WriteLn;
  WriteLn('========================================');
  WriteLn('Test Summary');
  WriteLn('========================================');
  WriteLn('Tests Passed: ', TestsPassed);
  WriteLn('Tests Failed: ', TestsFailed);
  WriteLn('Total Tests:  ', TestsPassed + TestsFailed);

  if TestsFailed = 0 then
    WriteLn('ALL TESTS PASSED!')
  else
    WriteLn('SOME TESTS FAILED');

  WriteLn('========================================');
end;

procedure CleanUp;
begin
  {$I-}
  DeleteFile('tests/db/testdb.dat');
  DeleteFile('tests/db/testdb.idx');
  DeleteFile('tests/db/testdb.jnl');
  DeleteFile('tests/db/testdb2.dat');
  DeleteFile('tests/db/testdb2.idx');
  DeleteFile('tests/db/testdb2.jnl');
  DeleteFile('tests/db/testpers.dat');
  DeleteFile('tests/db/testpers.idx');
  DeleteFile('tests/db/testpers.jnl');
  {$I+}
end;

begin
  TestsPassed := 0;
  TestsFailed := 0;

  WriteLn('Database Library Test Suite');
  WriteLn('===========================');

  { Clean up old test files }
  CleanUp;

  { Run tests }
  TestCreateDatabase;
  TestOpenCloseDatabase;
  TestAddRecord;
  TestAddMultipleRecords;
  TestFindRecordByID;
  TestUpdateRecord;
  TestDeleteRecord;
  TestMultiPageRecords;
  TestPersistence;
  TestFreeSpaceReclamation;
  TestValidation;

  PrintSummary;

  { Clean up test files }
  CleanUp;

  if TestsFailed > 0 then
    Halt(1);
end.
