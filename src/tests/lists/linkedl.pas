program LinkedListTest;

{
  TLinkedList Test Suite

  Comprehensive tests for the TLinkedList implementation.

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

{ Test: Initialize list }
procedure TestInitLinkedList;
var
  list: TLinkedList;
begin
  WriteLn('TestInitLinkedList');
  InitLinkedList(list);
  Assert(list.Count = 0, 'Initial count should be 0');
  Assert(list.Head = nil, 'Head should be nil');
  Assert(list.Tail = nil, 'Tail should be nil');
  FreeLinkedList(list);
end;

{ Test: Add items to front }
procedure TestAddLinkedListItemFirst;
var
  list: TLinkedList;
  item: PInteger;
  i: TInt;
begin
  WriteLn('TestAddLinkedListItemFirst');
  InitLinkedList(list);

  { Add items 0, 1, 2 to front (so order will be 2, 1, 0) }
  for i := 0 to 2 do
  begin
    New(item);
    item^ := i;
    AddLinkedListItemFirst(list, item);
  end;

  Assert(list.Count = 3, 'Count should be 3');
  Assert(PInteger(GetLinkedListItem(list, 0))^ = 2, 'First item should be 2');
  Assert(PInteger(GetLinkedListItem(list, 1))^ = 1, 'Second item should be 1');
  Assert(PInteger(GetLinkedListItem(list, 2))^ = 0, 'Third item should be 0');

  { Verify head and tail }
  Assert(PInteger(list.Head^.Item)^ = 2, 'Head should be 2');
  Assert(PInteger(list.Tail^.Item)^ = 0, 'Tail should be 0');

  { Clean up }
  while list.Head <> nil do
  begin
    item := RemoveLinkedListNode(list, list.Head);
    Dispose(item);
  end;
  FreeLinkedList(list);
end;

{ Test: Add items to end }
procedure TestAddLinkedListItemLast;
var
  list: TLinkedList;
  item: PInteger;
  i: TInt;
begin
  WriteLn('TestAddLinkedListItemLast');
  InitLinkedList(list);

  { Add items 0, 1, 2 to end }
  for i := 0 to 2 do
  begin
    New(item);
    item^ := i;
    AddLinkedListItemLast(list, item);
  end;

  Assert(list.Count = 3, 'Count should be 3');
  Assert(PInteger(GetLinkedListItem(list, 0))^ = 0, 'First item should be 0');
  Assert(PInteger(GetLinkedListItem(list, 1))^ = 1, 'Second item should be 1');
  Assert(PInteger(GetLinkedListItem(list, 2))^ = 2, 'Third item should be 2');

  { Verify head and tail }
  Assert(PInteger(list.Head^.Item)^ = 0, 'Head should be 0');
  Assert(PInteger(list.Tail^.Item)^ = 2, 'Tail should be 2');

  { Clean up }
  while list.Head <> nil do
  begin
    item := RemoveLinkedListNode(list, list.Head);
    Dispose(item);
  end;
  FreeLinkedList(list);
end;

{ Test: Get node by index }
procedure TestGetLinkedListNode;
var
  list: TLinkedList;
  item: PInteger;
  node: PLinkedListNode;
  i: TInt;
begin
  WriteLn('TestGetLinkedListNode');
  InitLinkedList(list);

  { Add items 0 through 9 }
  for i := 0 to 9 do
  begin
    New(item);
    item^ := i;
    AddLinkedListItemLast(list, item);
  end;

  { Get node at index 5 }
  node := GetLinkedListNode(list, 5);
  Assert(node <> nil, 'Node should not be nil');
  Assert(PInteger(node^.Item)^ = 5, 'Node item should be 5');

  { Get first node }
  node := GetLinkedListNode(list, 0);
  Assert(node = list.Head, 'Node should be head');

  { Get last node }
  node := GetLinkedListNode(list, 9);
  Assert(node = list.Tail, 'Node should be tail');

  { Clean up }
  while list.Head <> nil do
  begin
    item := RemoveLinkedListNode(list, list.Head);
    Dispose(item);
  end;
  FreeLinkedList(list);
end;

{ Test: Insert at index }
procedure TestInsertLinkedListItem;
var
  list: TLinkedList;
  item: PInteger;
  i: TInt;
begin
  WriteLn('TestInsertLinkedListItem');
  InitLinkedList(list);

  { Add items 0, 2, 4 }
  for i := 0 to 2 do
  begin
    New(item);
    item^ := i * 2;
    AddLinkedListItemLast(list, item);
  end;

  { Insert 99 at index 1 }
  New(item);
  item^ := 99;
  InsertLinkedListItem(list, 1, item);

  Assert(list.Count = 4, 'Count should be 4');
  Assert(PInteger(GetLinkedListItem(list, 0))^ = 0, 'Item 0 should be 0');
  Assert(PInteger(GetLinkedListItem(list, 1))^ = 99, 'Item 1 should be 99');
  Assert(PInteger(GetLinkedListItem(list, 2))^ = 2, 'Item 2 should be 2');
  Assert(PInteger(GetLinkedListItem(list, 3))^ = 4, 'Item 3 should be 4');

  { Clean up }
  while list.Head <> nil do
  begin
    item := RemoveLinkedListNode(list, list.Head);
    Dispose(item);
  end;
  FreeLinkedList(list);
end;

{ Test: Insert before node }
procedure TestInsertLinkedListNodeBefore;
var
  list: TLinkedList;
  item: PInteger;
  node: PLinkedListNode;
  i: TInt;
begin
  WriteLn('TestInsertLinkedListNodeBefore');
  InitLinkedList(list);

  { Add items 0, 1, 2 }
  for i := 0 to 2 do
  begin
    New(item);
    item^ := i;
    AddLinkedListItemLast(list, item);
  end;

  { Insert 99 before node at index 1 }
  node := GetLinkedListNode(list, 1);
  New(item);
  item^ := 99;
  InsertLinkedListNodeBefore(list, node, item);

  Assert(list.Count = 4, 'Count should be 4');
  Assert(PInteger(GetLinkedListItem(list, 1))^ = 99, 'Item 1 should be 99');

  { Clean up }
  while list.Head <> nil do
  begin
    item := RemoveLinkedListNode(list, list.Head);
    Dispose(item);
  end;
  FreeLinkedList(list);
end;

{ Test: Insert after node }
procedure TestInsertLinkedListNodeAfter;
var
  list: TLinkedList;
  item: PInteger;
  node: PLinkedListNode;
  i: TInt;
begin
  WriteLn('TestInsertLinkedListNodeAfter');
  InitLinkedList(list);

  { Add items 0, 1, 2 }
  for i := 0 to 2 do
  begin
    New(item);
    item^ := i;
    AddLinkedListItemLast(list, item);
  end;

  { Insert 99 after node at index 1 }
  node := GetLinkedListNode(list, 1);
  New(item);
  item^ := 99;
  InsertLinkedListNodeAfter(list, node, item);

  Assert(list.Count = 4, 'Count should be 4');
  Assert(PInteger(GetLinkedListItem(list, 2))^ = 99, 'Item 2 should be 99');

  { Clean up }
  while list.Head <> nil do
  begin
    item := RemoveLinkedListNode(list, list.Head);
    Dispose(item);
  end;
  FreeLinkedList(list);
end;

{ Test: Remove by index }
procedure TestRemoveLinkedListItem;
var
  list: TLinkedList;
  item, removed: PInteger;
  i: TInt;
begin
  WriteLn('TestRemoveLinkedListItem');
  InitLinkedList(list);

  { Add items 0, 10, 20, 30 }
  for i := 0 to 3 do
  begin
    New(item);
    item^ := i * 10;
    AddLinkedListItemLast(list, item);
  end;

  { Remove item at index 1 }
  removed := RemoveLinkedListItem(list, 1);

  Assert(list.Count = 3, 'Count should be 3');
  Assert(removed^ = 10, 'Removed item should be 10');
  Assert(PInteger(GetLinkedListItem(list, 0))^ = 0, 'Item 0 should be 0');
  Assert(PInteger(GetLinkedListItem(list, 1))^ = 20, 'Item 1 should be 20');
  Assert(PInteger(GetLinkedListItem(list, 2))^ = 30, 'Item 2 should be 30');

  Dispose(removed);

  { Clean up }
  while list.Head <> nil do
  begin
    item := RemoveLinkedListNode(list, list.Head);
    Dispose(item);
  end;
  FreeLinkedList(list);
end;

{ Test: Remove by node }
procedure TestRemoveLinkedListNode;
var
  list: TLinkedList;
  item, removed: PInteger;
  node: PLinkedListNode;
  i: TInt;
begin
  WriteLn('TestRemoveLinkedListNode');
  InitLinkedList(list);

  { Add items 0, 10, 20 }
  for i := 0 to 2 do
  begin
    New(item);
    item^ := i * 10;
    AddLinkedListItemLast(list, item);
  end;

  { Remove middle node }
  node := GetLinkedListNode(list, 1);
  removed := RemoveLinkedListNode(list, node);

  Assert(list.Count = 2, 'Count should be 2');
  Assert(removed^ = 10, 'Removed item should be 10');

  Dispose(removed);

  { Clean up }
  while list.Head <> nil do
  begin
    item := RemoveLinkedListNode(list, list.Head);
    Dispose(item);
  end;
  FreeLinkedList(list);
end;

{ Test: Remove head }
procedure TestRemoveLinkedListHead;
var
  list: TLinkedList;
  item, removed: PInteger;
  i: TInt;
begin
  WriteLn('TestRemoveLinkedListHead');
  InitLinkedList(list);

  { Add items }
  for i := 0 to 2 do
  begin
    New(item);
    item^ := i;
    AddLinkedListItemLast(list, item);
  end;

  { Remove head }
  removed := RemoveLinkedListNode(list, list.Head);

  Assert(removed^ = 0, 'Removed item should be 0');
  Assert(list.Count = 2, 'Count should be 2');
  Assert(PInteger(list.Head^.Item)^ = 1, 'New head should be 1');

  Dispose(removed);

  { Clean up }
  while list.Head <> nil do
  begin
    item := RemoveLinkedListNode(list, list.Head);
    Dispose(item);
  end;
  FreeLinkedList(list);
end;

{ Test: Remove tail }
procedure TestRemoveLinkedListTail;
var
  list: TLinkedList;
  item, removed: PInteger;
  i: TInt;
begin
  WriteLn('TestRemoveLinkedListTail');
  InitLinkedList(list);

  { Add items }
  for i := 0 to 2 do
  begin
    New(item);
    item^ := i;
    AddLinkedListItemLast(list, item);
  end;

  { Remove tail }
  removed := RemoveLinkedListNode(list, list.Tail);

  Assert(removed^ = 2, 'Removed item should be 2');
  Assert(list.Count = 2, 'Count should be 2');
  Assert(PInteger(list.Tail^.Item)^ = 1, 'New tail should be 1');

  Dispose(removed);

  { Clean up }
  while list.Head <> nil do
  begin
    item := RemoveLinkedListNode(list, list.Head);
    Dispose(item);
  end;
  FreeLinkedList(list);
end;

{ Test: Find node }
procedure TestFindLinkedListNode;
var
  list: TLinkedList;
  item1, item2, item3, item4: PInteger;
  node: PLinkedListNode;
begin
  WriteLn('TestFindLinkedListNode');
  InitLinkedList(list);

  New(item1); item1^ := 10;
  New(item2); item2^ := 20;
  New(item3); item3^ := 30;
  New(item4); item4^ := 40;

  AddLinkedListItemLast(list, item1);
  AddLinkedListItemLast(list, item2);
  AddLinkedListItemLast(list, item3);

  node := FindLinkedListNode(list, item2);
  Assert(node <> nil, 'Should find node');
  Assert(PInteger(node^.Item)^ = 20, 'Found node should have value 20');

  node := FindLinkedListNode(list, item4);
  Assert(node = nil, 'Should not find item4');

  Dispose(item1);
  Dispose(item2);
  Dispose(item3);
  Dispose(item4);
  FreeLinkedList(list);
end;

{ Test: Find item index }
procedure TestFindLinkedListItem;
var
  list: TLinkedList;
  item1, item2, item3, item4: PInteger;
  index: TInt;
begin
  WriteLn('TestFindLinkedListItem');
  InitLinkedList(list);

  New(item1); item1^ := 10;
  New(item2); item2^ := 20;
  New(item3); item3^ := 30;
  New(item4); item4^ := 40;

  AddLinkedListItemLast(list, item1);
  AddLinkedListItemLast(list, item2);
  AddLinkedListItemLast(list, item3);

  index := FindLinkedListItem(list, item2);
  Assert(index = 1, 'Should find item2 at index 1');

  index := FindLinkedListItem(list, item4);
  Assert(index = -1, 'Should return -1 for item4');

  Dispose(item1);
  Dispose(item2);
  Dispose(item3);
  Dispose(item4);
  FreeLinkedList(list);
end;

{ Test: Contains item }
procedure TestContainsLinkedListItem;
var
  list: TLinkedList;
  item1, item2: PInteger;
begin
  WriteLn('TestContainsLinkedListItem');
  InitLinkedList(list);

  New(item1); item1^ := 10;
  New(item2); item2^ := 20;

  AddLinkedListItemLast(list, item1);

  Assert(ContainsLinkedListItem(list, item1) = True, 'Should contain item1');
  Assert(ContainsLinkedListItem(list, item2) = False, 'Should not contain item2');

  Dispose(item1);
  Dispose(item2);
  FreeLinkedList(list);
end;

{ Test: ForEach forward iteration }
var
  iterationSum: TInt;

procedure SumIterator(item: Pointer; index: TInt);
begin
  iterationSum := iterationSum + PInteger(item)^;
end;

procedure TestForEachLinkedListItem;
var
  list: TLinkedList;
  item: PInteger;
  i: TInt;
begin
  WriteLn('TestForEachLinkedListItem');
  InitLinkedList(list);

  { Add items 1, 2, 3, 4, 5 }
  for i := 1 to 5 do
  begin
    New(item);
    item^ := i;
    AddLinkedListItemLast(list, item);
  end;

  iterationSum := 0;
  ForEachLinkedListItem(list, SumIterator);

  Assert(iterationSum = 15, 'Sum should be 15 (1+2+3+4+5)');

  { Clean up }
  while list.Head <> nil do
  begin
    item := RemoveLinkedListNode(list, list.Head);
    Dispose(item);
  end;
  FreeLinkedList(list);
end;

{ Test: ForEach reverse iteration }
var
  reverseItems: array[0..4] of TInt;
  reverseIndex: TInt;

procedure ReverseCollector(item: Pointer; index: TInt);
begin
  reverseItems[reverseIndex] := PInteger(item)^;
  reverseIndex := reverseIndex + 1;
end;

procedure TestForEachLinkedListItemReverse;
var
  list: TLinkedList;
  item: PInteger;
  i: TInt;
begin
  WriteLn('TestForEachLinkedListItemReverse');
  InitLinkedList(list);

  { Add items 1, 2, 3, 4, 5 }
  for i := 1 to 5 do
  begin
    New(item);
    item^ := i;
    AddLinkedListItemLast(list, item);
  end;

  reverseIndex := 0;
  ForEachLinkedListItemReverse(list, ReverseCollector);

  Assert(reverseItems[0] = 5, 'First reverse item should be 5');
  Assert(reverseItems[1] = 4, 'Second reverse item should be 4');
  Assert(reverseItems[2] = 3, 'Third reverse item should be 3');
  Assert(reverseItems[3] = 2, 'Fourth reverse item should be 2');
  Assert(reverseItems[4] = 1, 'Fifth reverse item should be 1');

  { Clean up }
  while list.Head <> nil do
  begin
    item := RemoveLinkedListNode(list, list.Head);
    Dispose(item);
  end;
  FreeLinkedList(list);
end;

{ Test: Doubly-linked structure }
procedure TestDoublyLinkedStructure;
var
  list: TLinkedList;
  item: PInteger;
  node: PLinkedListNode;
  i: TInt;
begin
  WriteLn('TestDoublyLinkedStructure');
  InitLinkedList(list);

  { Add items 0, 1, 2 }
  for i := 0 to 2 do
  begin
    New(item);
    item^ := i;
    AddLinkedListItemLast(list, item);
  end;

  { Verify forward links }
  node := list.Head;
  Assert(PInteger(node^.Item)^ = 0, 'Head item should be 0');
  node := node^.Next;
  Assert(PInteger(node^.Item)^ = 1, 'Next item should be 1');
  node := node^.Next;
  Assert(PInteger(node^.Item)^ = 2, 'Next item should be 2');
  Assert(node^.Next = nil, 'Last node next should be nil');

  { Verify backward links }
  node := list.Tail;
  Assert(PInteger(node^.Item)^ = 2, 'Tail item should be 2');
  node := node^.Prev;
  Assert(PInteger(node^.Item)^ = 1, 'Prev item should be 1');
  node := node^.Prev;
  Assert(PInteger(node^.Item)^ = 0, 'Prev item should be 0');
  Assert(node^.Prev = nil, 'First node prev should be nil');

  { Clean up }
  while list.Head <> nil do
  begin
    item := RemoveLinkedListNode(list, list.Head);
    Dispose(item);
  end;
  FreeLinkedList(list);
end;

{ Test: Single item list }
procedure TestSingleItemList;
var
  list: TLinkedList;
  item: PInteger;
begin
  WriteLn('TestSingleItemList');
  InitLinkedList(list);

  New(item);
  item^ := 42;
  AddLinkedListItemLast(list, item);

  Assert(list.Count = 1, 'Count should be 1');
  Assert(list.Head = list.Tail, 'Head and tail should be same');
  Assert(list.Head^.Next = nil, 'Head next should be nil');
  Assert(list.Head^.Prev = nil, 'Head prev should be nil');

  Dispose(item);
  FreeLinkedList(list);
end;

{ Main test runner }
begin
  testsPassed := 0;
  testsFailed := 0;

  WriteLn('===========================================');
  WriteLn('TLinkedList Test Suite');
  WriteLn('===========================================');
  WriteLn;

  TestInitLinkedList;
  TestAddLinkedListItemFirst;
  TestAddLinkedListItemLast;
  TestGetLinkedListNode;
  TestInsertLinkedListItem;
  TestInsertLinkedListNodeBefore;
  TestInsertLinkedListNodeAfter;
  TestRemoveLinkedListItem;
  TestRemoveLinkedListNode;
  TestRemoveLinkedListHead;
  TestRemoveLinkedListTail;
  TestFindLinkedListNode;
  TestFindLinkedListItem;
  TestContainsLinkedListItem;
  TestForEachLinkedListItem;
  TestForEachLinkedListItemReverse;
  TestDoublyLinkedStructure;
  TestSingleItemList;

  WriteLn;
  WriteLn('===========================================');
  WriteLn('Results: ', testsPassed, ' passed, ', testsFailed, ' failed');
  WriteLn('===========================================');

  if testsFailed > 0 then
    Halt(1);
end.
