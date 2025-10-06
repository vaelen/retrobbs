program ArrayListTest;

{
  TArrayList Test Suite

  Comprehensive tests for the TArrayList implementation.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  Lists, BBSTypes;

var
  testsPassed: TInt;
  testsFailed: TInt;

procedure Assert(condition: Boolean; testName: Str255);
begin
  if condition then
  begin
    WriteLn('  PASS: ', testName);
    testsPassed := testsPassed + 1;
  end
  else
  begin
    WriteLn('  FAIL: ', testName);
    testsFailed := testsFailed + 1;
  end;
end;

{ Test: Initialize with capacity }
procedure TestInitArrayList;
var
  list: TArrayList;
begin
  WriteLn('TestInitArrayList');
  InitArrayList(list, 10);
  Assert(list.Count = 0, 'Initial count should be 0');
  Assert(list.Capacity = 10, 'Initial capacity should be 10');
  Assert(list.Items <> nil, 'Items pointer should not be nil');
  FreeArrayList(list);
end;

{ Test: Initialize with zero capacity }
procedure TestInitArrayListZeroCapacity;
var
  list: TArrayList;
begin
  WriteLn('TestInitArrayListZeroCapacity');
  InitArrayList(list, 0);
  Assert(list.Count = 0, 'Count should be 0');
  Assert(list.Capacity = 0, 'Capacity should be 0');
  Assert(list.Items = nil, 'Items pointer should be nil');
  FreeArrayList(list);
end;

{ Test: Add items }
procedure TestAddArrayListItem;
var
  list: TArrayList;
  i: TInt;
  item: PInteger;
begin
  WriteLn('TestAddArrayListItem');
  InitArrayList(list, 5);

  { Add 10 items to test growth }
  for i := 0 to 9 do
  begin
    New(item);
    item^ := i * 10;
    AddArrayListItem(list, item);
  end;

  Assert(list.Count = 10, 'Count should be 10');
  Assert(list.Capacity >= 10, 'Capacity should be at least 10');

  { Verify items }
  for i := 0 to 9 do
  begin
    item := GetArrayListItem(list, i);
    Assert(item^ = i * 10, 'Item value should match');
  end;

  { Clean up }
  for i := 0 to list.Count - 1 do
  begin
    item := GetArrayListItem(list, i);
    Dispose(item);
  end;
  FreeArrayList(list);
end;

{ Test: Get and Set items }
procedure TestGetSetArrayListItem;
var
  list: TArrayList;
  item1, item2: PInteger;
begin
  WriteLn('TestGetSetArrayListItem');
  InitArrayList(list, 5);

  New(item1);
  item1^ := 100;
  AddArrayListItem(list, item1);

  New(item2);
  item2^ := 200;
  SetArrayListItem(list, 0, item2);

  Assert(GetArrayListItem(list, 0) = item2, 'Get should return set item');
  Assert(PInteger(GetArrayListItem(list, 0))^ = 200, 'Value should be 200');

  Dispose(item1);
  Dispose(item2);
  FreeArrayList(list);
end;

{ Test: Insert items }
procedure TestInsertArrayListItem;
var
  list: TArrayList;
  item: PInteger;
  i: TInt;
begin
  WriteLn('TestInsertArrayListItem');
  InitArrayList(list, 5);

  { Add items 0, 2, 4 }
  for i := 0 to 2 do
  begin
    New(item);
    item^ := i * 2;
    AddArrayListItem(list, item);
  end;

  { Insert item at index 1 }
  New(item);
  item^ := 99;
  InsertArrayListItem(list, 1, item);

  Assert(list.Count = 4, 'Count should be 4');
  Assert(PInteger(GetArrayListItem(list, 0))^ = 0, 'Item 0 should be 0');
  Assert(PInteger(GetArrayListItem(list, 1))^ = 99, 'Item 1 should be 99');
  Assert(PInteger(GetArrayListItem(list, 2))^ = 2, 'Item 2 should be 2');
  Assert(PInteger(GetArrayListItem(list, 3))^ = 4, 'Item 3 should be 4');

  { Clean up }
  for i := 0 to list.Count - 1 do
  begin
    item := GetArrayListItem(list, i);
    Dispose(item);
  end;
  FreeArrayList(list);
end;

{ Test: Remove items }
procedure TestRemoveArrayListItem;
var
  list: TArrayList;
  item, removed: PInteger;
  i: TInt;
begin
  WriteLn('TestRemoveArrayListItem');
  InitArrayList(list, 5);

  { Add items 0, 10, 20, 30 }
  for i := 0 to 3 do
  begin
    New(item);
    item^ := i * 10;
    AddArrayListItem(list, item);
  end;

  { Remove item at index 1 }
  removed := RemoveArrayListItem(list, 1);

  Assert(list.Count = 3, 'Count should be 3');
  Assert(removed^ = 10, 'Removed item should be 10');
  Assert(PInteger(GetArrayListItem(list, 0))^ = 0, 'Item 0 should be 0');
  Assert(PInteger(GetArrayListItem(list, 1))^ = 20, 'Item 1 should be 20');
  Assert(PInteger(GetArrayListItem(list, 2))^ = 30, 'Item 2 should be 30');

  Dispose(removed);

  { Clean up }
  for i := 0 to list.Count - 1 do
  begin
    item := GetArrayListItem(list, i);
    Dispose(item);
  end;
  FreeArrayList(list);
end;

{ Test: Delete items }
procedure TestDeleteArrayListItem;
var
  list: TArrayList;
  item: PInteger;
  i: TInt;
begin
  WriteLn('TestDeleteArrayListItem');
  InitArrayList(list, 5);

  { Add items }
  for i := 0 to 3 do
  begin
    New(item);
    item^ := i;
    AddArrayListItem(list, item);
  end;

  { Delete item at index 2 }
  DeleteArrayListItem(list, 2);

  Assert(list.Count = 3, 'Count should be 3');
  Assert(PInteger(GetArrayListItem(list, 0))^ = 0, 'Item 0 should be 0');
  Assert(PInteger(GetArrayListItem(list, 1))^ = 1, 'Item 1 should be 1');
  Assert(PInteger(GetArrayListItem(list, 2))^ = 3, 'Item 2 should be 3');

  { Clean up }
  for i := 0 to list.Count - 1 do
  begin
    item := GetArrayListItem(list, i);
    Dispose(item);
  end;
  FreeArrayList(list);
end;

{ Test: Find items }
procedure TestFindArrayListItem;
var
  list: TArrayList;
  item1, item2, item3: PInteger;
begin
  WriteLn('TestFindArrayListItem');
  InitArrayList(list, 5);

  New(item1); item1^ := 10;
  New(item2); item2^ := 20;
  New(item3); item3^ := 30;

  AddArrayListItem(list, item1);
  AddArrayListItem(list, item2);
  AddArrayListItem(list, item3);

  Assert(FindArrayListItem(list, item1) = 0, 'Should find item1 at index 0');
  Assert(FindArrayListItem(list, item2) = 1, 'Should find item2 at index 1');
  Assert(FindArrayListItem(list, item3) = 2, 'Should find item3 at index 2');

  Dispose(item1);
  Dispose(item2);
  Dispose(item3);
  FreeArrayList(list);
end;

{ Test: Contains items }
procedure TestContainsArrayListItem;
var
  list: TArrayList;
  item1, item2: PInteger;
begin
  WriteLn('TestContainsArrayListItem');
  InitArrayList(list, 5);

  New(item1); item1^ := 10;
  New(item2); item2^ := 20;

  AddArrayListItem(list, item1);

  Assert(ContainsArrayListItem(list, item1) = True, 'Should contain item1');
  Assert(ContainsArrayListItem(list, item2) = False, 'Should not contain item2');

  Dispose(item1);
  Dispose(item2);
  FreeArrayList(list);
end;

{ Test: Clear list }
procedure TestClearArrayList;
var
  list: TArrayList;
  item: PInteger;
  i: TInt;
begin
  WriteLn('TestClearArrayList');
  InitArrayList(list, 5);

  for i := 0 to 4 do
  begin
    New(item);
    item^ := i;
    AddArrayListItem(list, item);
  end;

  ClearArrayList(list);

  Assert(list.Count = 0, 'Count should be 0 after clear');
  Assert(list.Capacity >= 5, 'Capacity should remain');

  { Items were not freed by Clear, so we need to clean up manually }
  { In a real scenario, you'd track them separately or use ClearAndFree }
  FreeArrayList(list);
end;

{ Test: Ensure capacity }
procedure TestEnsureArrayListCapacity;
var
  list: TArrayList;
begin
  WriteLn('TestEnsureArrayListCapacity');
  InitArrayList(list, 5);

  Assert(list.Capacity = 5, 'Initial capacity should be 5');

  EnsureArrayListCapacity(list, 20);

  Assert(list.Capacity >= 20, 'Capacity should be at least 20');

  FreeArrayList(list);
end;

{ Test: Trim capacity }
procedure TestTrimArrayListCapacity;
var
  list: TArrayList;
  item: PInteger;
  i: TInt;
begin
  WriteLn('TestTrimArrayListCapacity');
  InitArrayList(list, 20);

  { Add only 5 items }
  for i := 0 to 4 do
  begin
    New(item);
    item^ := i;
    AddArrayListItem(list, item);
  end;

  Assert(list.Count = 5, 'Count should be 5');
  Assert(list.Capacity = 20, 'Capacity should be 20');

  TrimArrayListCapacity(list);

  Assert(list.Capacity = 5, 'Capacity should be trimmed to 5');

  { Clean up }
  for i := 0 to list.Count - 1 do
  begin
    item := GetArrayListItem(list, i);
    Dispose(item);
  end;
  FreeArrayList(list);
end;

{ Test: ForEach iteration }
var
  iterationSum: TInt;

procedure SumIterator(item: Pointer; index: TInt);
begin
  iterationSum := iterationSum + PInteger(item)^;
end;

procedure TestForEachArrayListItem;
var
  list: TArrayList;
  item: PInteger;
  i: TInt;
begin
  WriteLn('TestForEachArrayListItem');
  InitArrayList(list, 5);

  { Add items 1, 2, 3, 4, 5 }
  for i := 1 to 5 do
  begin
    New(item);
    item^ := i;
    AddArrayListItem(list, item);
  end;

  iterationSum := 0;
  ForEachArrayListItem(list, SumIterator);

  Assert(iterationSum = 15, 'Sum should be 15 (1+2+3+4+5)');

  { Clean up }
  for i := 0 to list.Count - 1 do
  begin
    item := GetArrayListItem(list, i);
    Dispose(item);
  end;
  FreeArrayList(list);
end;

{ Test: Growth strategy }
procedure TestArrayListGrowth;
var
  list: TArrayList;
  item: PInteger;
  i: TInt;
  prevCapacity: TInt;
begin
  WriteLn('TestArrayListGrowth');
  InitArrayList(list, 0);

  Assert(list.Capacity = 0, 'Initial capacity should be 0');

  { Add first item - should grow to 8 }
  New(item); item^ := 0;
  AddArrayListItem(list, item);
  Assert(list.Capacity = 8, 'Capacity should grow to 8');
  prevCapacity := list.Capacity;

  { Add items until capacity grows }
  for i := 1 to 20 do
  begin
    New(item); item^ := i;
    AddArrayListItem(list, item);
    if list.Capacity > prevCapacity then
    begin
      Assert(list.Capacity = prevCapacity * 2, 'Capacity should double');
      prevCapacity := list.Capacity;
    end;
  end;

  { Clean up }
  for i := 0 to list.Count - 1 do
  begin
    item := GetArrayListItem(list, i);
    Dispose(item);
  end;
  FreeArrayList(list);
end;

{ Main test runner }
begin
  testsPassed := 0;
  testsFailed := 0;

  WriteLn('===========================================');
  WriteLn('TArrayList Test Suite');
  WriteLn('===========================================');
  WriteLn;

  TestInitArrayList;
  TestInitArrayListZeroCapacity;
  TestAddArrayListItem;
  TestGetSetArrayListItem;
  TestInsertArrayListItem;
  TestRemoveArrayListItem;
  TestDeleteArrayListItem;
  TestFindArrayListItem;
  TestContainsArrayListItem;
  TestClearArrayList;
  TestEnsureArrayListCapacity;
  TestTrimArrayListCapacity;
  TestForEachArrayListItem;
  TestArrayListGrowth;

  WriteLn;
  WriteLn('===========================================');
  WriteLn('Results: ', testsPassed, ' passed, ', testsFailed, ' failed');
  WriteLn('===========================================');

  if testsFailed > 0 then
    Halt(1);
end.
