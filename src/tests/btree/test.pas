program BTreeTest;

{
  B-Tree Unit Test

  Tests the file-based B-Tree implementation.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  BTree, SysUtils;

const
  TEST_FILE = 'tests/btree/test.btree';

var
  passed: Integer;
  failed: Integer;

procedure TestCreateAndOpen;
var
  tree: TBTree;
begin
  Write('Create B-Tree file: ');
  if CreateBTree(TEST_FILE) then
  begin
    WriteLn('PASS');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL');
    Inc(failed);
  end;

  Write('Open B-Tree file: ');
  if OpenBTree(tree, TEST_FILE) then
  begin
    WriteLn('PASS');
    Inc(passed);
    CloseBTree(tree);
  end
  else
  begin
    WriteLn('FAIL');
    Inc(failed);
  end;
end;

procedure TestInsertAndFind;
var
  tree: TBTree;
  values: array[0..99] of LongInt;
  count: Integer;
begin
  if not OpenBTree(tree, TEST_FILE) then
  begin
    WriteLn('FAIL: Could not open tree');
    Inc(failed);
    Exit;
  end;

  Write('Insert single key-value: ');
  if Insert(tree, 100, 200) then
  begin
    WriteLn('PASS');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL');
    Inc(failed);
  end;

  Write('Find inserted value: ');
  if Find(tree, 100, values, count) and (count = 1) and (values[0] = 200) then
  begin
    WriteLn('PASS (value=', values[0], ')');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (count=', count, ')');
    Inc(failed);
  end;

  Write('Find non-existent key: ');
  if not Find(tree, 999, values, count) then
  begin
    WriteLn('PASS');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (should not find)');
    Inc(failed);
  end;

  CloseBTree(tree);
end;

procedure TestMultipleValues;
var
  tree: TBTree;
  values: array[0..99] of LongInt;
  count: Integer;
  i: Integer;
  allMatch: Boolean;
begin
  if not OpenBTree(tree, TEST_FILE) then
  begin
    WriteLn('FAIL: Could not open tree');
    Inc(failed);
    Exit;
  end;

  Write('Insert multiple values for same key: ');
  if Insert(tree, 50, 1) and Insert(tree, 50, 2) and Insert(tree, 50, 3) then
  begin
    WriteLn('PASS');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL');
    Inc(failed);
  end;

  Write('Find all values for key: ');
  if Find(tree, 50, values, count) and (count = 3) then
  begin
    allMatch := (values[0] = 1) and (values[1] = 2) and (values[2] = 3);
    if allMatch then
    begin
      WriteLn('PASS (count=', count, ')');
      Inc(passed);
    end
    else
    begin
      WriteLn('FAIL (values don''t match)');
      Inc(failed);
    end;
  end
  else
  begin
    WriteLn('FAIL (count=', count, ', expected 3)');
    Inc(failed);
  end;

  CloseBTree(tree);
end;

procedure TestMultipleKeys;
var
  tree: TBTree;
  values: array[0..99] of LongInt;
  count: Integer;
  i: Integer;
begin
  if not OpenBTree(tree, TEST_FILE) then
  begin
    WriteLn('FAIL: Could not open tree');
    Inc(failed);
    Exit;
  end;

  Write('Insert multiple different keys: ');
  if Insert(tree, 10, 100) and Insert(tree, 20, 200) and
     Insert(tree, 30, 300) and Insert(tree, 15, 150) then
  begin
    WriteLn('PASS');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL');
    Inc(failed);
  end;

  Write('Find first key: ');
  if Find(tree, 10, values, count) and (count = 1) and (values[0] = 100) then
  begin
    WriteLn('PASS');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL');
    Inc(failed);
  end;

  Write('Find middle key: ');
  if Find(tree, 15, values, count) and (count = 1) and (values[0] = 150) then
  begin
    WriteLn('PASS');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL');
    Inc(failed);
  end;

  Write('Find last key: ');
  if Find(tree, 30, values, count) and (count = 1) and (values[0] = 300) then
  begin
    WriteLn('PASS');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL');
    Inc(failed);
  end;

  CloseBTree(tree);
end;

procedure TestDelete;
var
  tree: TBTree;
  values: array[0..99] of LongInt;
  count: Integer;
begin
  if not OpenBTree(tree, TEST_FILE) then
  begin
    WriteLn('FAIL: Could not open tree');
    Inc(failed);
    Exit;
  end;

  Write('Delete specific value: ');
  if DeleteValue(tree, 50, 2) then
  begin
    if Find(tree, 50, values, count) and (count = 2) and
       (values[0] = 1) and (values[1] = 3) then
    begin
      WriteLn('PASS');
      Inc(passed);
    end
    else
    begin
      WriteLn('FAIL (remaining values incorrect)');
      Inc(failed);
    end;
  end
  else
  begin
    WriteLn('FAIL (delete failed)');
    Inc(failed);
  end;

  Write('Delete entire key: ');
  if Delete(tree, 100) then
  begin
    if not Find(tree, 100, values, count) then
    begin
      WriteLn('PASS');
      Inc(passed);
    end
    else
    begin
      WriteLn('FAIL (key still exists)');
      Inc(failed);
    end;
  end
  else
  begin
    WriteLn('FAIL (delete failed)');
    Inc(failed);
  end;

  CloseBTree(tree);
end;

procedure TestPersistence;
var
  tree: TBTree;
  values: array[0..99] of LongInt;
  count: Integer;
begin
  { Close and reopen to test persistence }
  Write('Persistence after close/reopen: ');

  if OpenBTree(tree, TEST_FILE) then
  begin
    if Find(tree, 10, values, count) and (count = 1) and (values[0] = 100) then
    begin
      WriteLn('PASS');
      Inc(passed);
    end
    else
    begin
      WriteLn('FAIL (data lost)');
      Inc(failed);
    end;
    CloseBTree(tree);
  end
  else
  begin
    WriteLn('FAIL (could not reopen)');
    Inc(failed);
  end;
end;

procedure TestStringKey;
var
  key1, key2, key3: LongInt;
begin
  Write('StringKey generates consistent keys: ');
  key1 := StringKey('TestString');
  key2 := StringKey('TestString');
  if key1 = key2 then
  begin
    WriteLn('PASS (key=', key1, ')');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (keys don''t match)');
    Inc(failed);
  end;

  Write('StringKey is case-insensitive: ');
  key1 := StringKey('TestString');
  key2 := StringKey('TESTSTRING');
  key3 := StringKey('teststring');
  if (key1 = key2) and (key2 = key3) then
  begin
    WriteLn('PASS');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (case sensitivity issue)');
    Inc(failed);
  end;

  Write('StringKey generates different keys for different strings: ');
  key1 := StringKey('String1');
  key2 := StringKey('String2');
  if key1 <> key2 then
  begin
    WriteLn('PASS (key1=', key1, ', key2=', key2, ')');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (keys should differ)');
    Inc(failed);
  end;
end;

procedure Cleanup;
var
  f: File;
begin
  { Remove test file }
  Assign(f, TEST_FILE);
  {$I-}
  Erase(f);
  {$I+}
end;

begin
  passed := 0;
  failed := 0;

  WriteLn('B-Tree Unit Test Suite');
  WriteLn('======================');
  WriteLn;

  { Test create and open }
  WriteLn('File Operations:');
  TestCreateAndOpen;
  WriteLn;

  { Test insert and find }
  WriteLn('Insert and Find:');
  TestInsertAndFind;
  WriteLn;

  { Test multiple values }
  WriteLn('Multiple Values:');
  TestMultipleValues;
  WriteLn;

  { Test multiple keys }
  WriteLn('Multiple Keys:');
  TestMultipleKeys;
  WriteLn;

  { Test delete }
  WriteLn('Delete Operations:');
  TestDelete;
  WriteLn;

  { Test persistence }
  WriteLn('Persistence:');
  TestPersistence;
  WriteLn;

  { Test string key utility }
  WriteLn('String Key Utility:');
  TestStringKey;
  WriteLn;

  { Summary }
  WriteLn('======================');
  WriteLn('Tests passed: ', passed);
  WriteLn('Tests failed: ', failed);

  { Cleanup }
  Cleanup;

  if failed > 0 then
    Halt(1);
end.
