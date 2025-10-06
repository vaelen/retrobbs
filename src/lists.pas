unit Lists;

{
  Resizable Lists

  The Lists unit implements two resizable list types for Pascal:
  - TArrayList: Dynamic array-backed list with fast random access
  - TLinkedList: Doubly-linked list with fast insertions/deletions

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

interface

uses
  BBSTypes;

type
  { Callback procedure types }
  TFreeProc = procedure(item: Pointer);
  TIteratorProc = procedure(item: Pointer; index: TInt);

  { TArrayList - Dynamic array-backed list }
  PPointer = ^Pointer;

  TArrayList = record
    Items: PPointer;       { Pointer to allocated memory block }
    Count: TInt;           { Number of items currently in list }
    Capacity: TInt;        { Current allocated capacity }
  end;

  { TLinkedList - Doubly-linked list }
  PLinkedListNode = ^TLinkedListNode;
  TLinkedListNode = record
    Item: Pointer;
    Next: PLinkedListNode;
    Prev: PLinkedListNode;
  end;

  TLinkedList = record
    Head: PLinkedListNode;  { First node }
    Tail: PLinkedListNode;  { Last node }
    Count: TInt;            { Number of nodes }
  end;

{ TArrayList Procedures and Functions }

{ Initialization and Cleanup }
procedure InitArrayList(var list: TArrayList; initialCapacity: TInt);
procedure FreeArrayList(var list: TArrayList);
procedure ClearArrayList(var list: TArrayList);
procedure ClearAndFreeArrayList(var list: TArrayList; freeProc: TFreeProc);

{ Access }
function GetArrayListItem(var list: TArrayList; index: TInt): Pointer;
procedure SetArrayListItem(var list: TArrayList; index: TInt; item: Pointer);

{ Modification }
procedure AddArrayListItem(var list: TArrayList; item: Pointer);
procedure InsertArrayListItem(var list: TArrayList; index: TInt; item: Pointer);
function RemoveArrayListItem(var list: TArrayList; index: TInt): Pointer;
procedure DeleteArrayListItem(var list: TArrayList; index: TInt);

{ Capacity Management }
procedure EnsureArrayListCapacity(var list: TArrayList; minCapacity: TInt);
procedure TrimArrayListCapacity(var list: TArrayList);

{ Searching }
function FindArrayListItem(var list: TArrayList; item: Pointer): TInt;
function ContainsArrayListItem(var list: TArrayList; item: Pointer): Boolean;

{ Iteration }
procedure ForEachArrayListItem(var list: TArrayList; proc: TIteratorProc);

{ TLinkedList Procedures and Functions }

{ Initialization and Cleanup }
procedure InitLinkedList(var list: TLinkedList);
procedure FreeLinkedList(var list: TLinkedList);
procedure ClearLinkedList(var list: TLinkedList);
procedure ClearAndFreeLinkedList(var list: TLinkedList; freeProc: TFreeProc);

{ Access }
function GetLinkedListNode(var list: TLinkedList; index: TInt): PLinkedListNode;
function GetLinkedListItem(var list: TLinkedList; index: TInt): Pointer;

{ Modification (by position) }
procedure AddLinkedListItemFirst(var list: TLinkedList; item: Pointer);
procedure AddLinkedListItemLast(var list: TLinkedList; item: Pointer);
procedure InsertLinkedListItem(var list: TLinkedList; index: TInt; item: Pointer);
function RemoveLinkedListItem(var list: TLinkedList; index: TInt): Pointer;
procedure DeleteLinkedListItem(var list: TLinkedList; index: TInt);

{ Modification (by node) }
procedure InsertLinkedListNodeBefore(var list: TLinkedList; node: PLinkedListNode; item: Pointer);
procedure InsertLinkedListNodeAfter(var list: TLinkedList; node: PLinkedListNode; item: Pointer);
function RemoveLinkedListNode(var list: TLinkedList; node: PLinkedListNode): Pointer;
procedure DeleteLinkedListNode(var list: TLinkedList; node: PLinkedListNode);

{ Searching }
function FindLinkedListNode(var list: TLinkedList; item: Pointer): PLinkedListNode;
function FindLinkedListItem(var list: TLinkedList; item: Pointer): TInt;
function ContainsLinkedListItem(var list: TLinkedList; item: Pointer): Boolean;

{ Iteration }
procedure ForEachLinkedListItem(var list: TLinkedList; proc: TIteratorProc);
procedure ForEachLinkedListItemReverse(var list: TLinkedList; proc: TIteratorProc);

implementation

{ ============================================================================ }
{ TArrayList Implementation                                                    }
{ ============================================================================ }

{ Helper function to get pointer to i-th element }
function GetArrayListItemPtr(var list: TArrayList; index: TInt): PPointer;
begin
  GetArrayListItemPtr := PPointer(PtrUInt(list.Items) + (PtrUInt(index) * SizeOf(Pointer)));
end;

{ InitArrayList - Initialize with initial capacity }
procedure InitArrayList(var list: TArrayList; initialCapacity: TInt);
begin
  list.Count := 0;
  list.Capacity := initialCapacity;
  if initialCapacity > 0 then
    GetMem(list.Items, initialCapacity * SizeOf(Pointer))
  else
    list.Items := nil;
end;

{ FreeArrayList - Free the list (does not free items) }
procedure FreeArrayList(var list: TArrayList);
begin
  if list.Items <> nil then
    FreeMem(list.Items, list.Capacity * SizeOf(Pointer));
  list.Items := nil;
  list.Count := 0;
  list.Capacity := 0;
end;

{ ClearArrayList - Remove all items without freeing memory }
procedure ClearArrayList(var list: TArrayList);
begin
  list.Count := 0;
end;

{ ClearAndFreeArrayList - Clear and free all items using callback }
procedure ClearAndFreeArrayList(var list: TArrayList; freeProc: TFreeProc);
var
  i: TInt;
begin
  for i := 0 to list.Count - 1 do
    freeProc(GetArrayListItem(list, i));
  ClearArrayList(list);
end;

{ GetArrayListItem - Get item at index (0-based) }
function GetArrayListItem(var list: TArrayList; index: TInt): Pointer;
begin
  GetArrayListItem := GetArrayListItemPtr(list, index)^;
end;

{ SetArrayListItem - Set item at index }
procedure SetArrayListItem(var list: TArrayList; index: TInt; item: Pointer);
begin
  GetArrayListItemPtr(list, index)^ := item;
end;

{ EnsureArrayListCapacity - Ensure minimum capacity }
procedure EnsureArrayListCapacity(var list: TArrayList; minCapacity: TInt);
var
  newCapacity: TInt;
  newItems: PPointer;
  i: TInt;
begin
  if minCapacity <= list.Capacity then
    Exit;

  { Double the capacity until it meets minimum }
  if list.Capacity = 0 then
    newCapacity := 8
  else
    newCapacity := list.Capacity;

  while newCapacity < minCapacity do
    newCapacity := newCapacity * 2;

  { Allocate new memory }
  GetMem(newItems, newCapacity * SizeOf(Pointer));

  { Copy existing items }
  if list.Count > 0 then
  begin
    for i := 0 to list.Count - 1 do
      PPointer(PtrUInt(newItems) + (PtrUInt(i) * SizeOf(Pointer)))^ := GetArrayListItem(list, i);
  end;

  { Free old memory and update }
  if list.Items <> nil then
    FreeMem(list.Items, list.Capacity * SizeOf(Pointer));

  list.Items := newItems;
  list.Capacity := newCapacity;
end;

{ TrimArrayListCapacity - Reduce capacity to match count }
procedure TrimArrayListCapacity(var list: TArrayList);
var
  newItems: PPointer;
  i: TInt;
begin
  if list.Count = list.Capacity then
    Exit;

  if list.Count = 0 then
  begin
    if list.Items <> nil then
      FreeMem(list.Items, list.Capacity * SizeOf(Pointer));
    list.Items := nil;
    list.Capacity := 0;
    Exit;
  end;

  { Allocate new memory }
  GetMem(newItems, list.Count * SizeOf(Pointer));

  { Copy items }
  for i := 0 to list.Count - 1 do
    PPointer(PtrUInt(newItems) + (PtrUInt(i) * SizeOf(Pointer)))^ := GetArrayListItem(list, i);

  { Free old memory and update }
  FreeMem(list.Items, list.Capacity * SizeOf(Pointer));
  list.Items := newItems;
  list.Capacity := list.Count;
end;

{ AddArrayListItem - Add item to end }
procedure AddArrayListItem(var list: TArrayList; item: Pointer);
begin
  EnsureArrayListCapacity(list, list.Count + 1);
  SetArrayListItem(list, list.Count, item);
  list.Count := list.Count + 1;
end;

{ InsertArrayListItem - Insert at index }
procedure InsertArrayListItem(var list: TArrayList; index: TInt; item: Pointer);
var
  i: TInt;
begin
  EnsureArrayListCapacity(list, list.Count + 1);

  { Shift items to make room }
  for i := list.Count - 1 downto index do
    SetArrayListItem(list, i + 1, GetArrayListItem(list, i));

  { Insert new item }
  SetArrayListItem(list, index, item);
  list.Count := list.Count + 1;
end;

{ RemoveArrayListItem - Remove and return item }
function RemoveArrayListItem(var list: TArrayList; index: TInt): Pointer;
var
  i: TInt;
begin
  RemoveArrayListItem := GetArrayListItem(list, index);

  { Shift items to fill gap }
  for i := index to list.Count - 2 do
    SetArrayListItem(list, i, GetArrayListItem(list, i + 1));

  list.Count := list.Count - 1;
end;

{ DeleteArrayListItem - Remove item (doesn't return) }
procedure DeleteArrayListItem(var list: TArrayList; index: TInt);
var
  dummy: Pointer;
begin
  dummy := RemoveArrayListItem(list, index);
end;

{ FindArrayListItem - Find index (-1 if not found) }
function FindArrayListItem(var list: TArrayList; item: Pointer): TInt;
var
  i: TInt;
begin
  for i := 0 to list.Count - 1 do
  begin
    if GetArrayListItem(list, i) = item then
    begin
      FindArrayListItem := i;
      Exit;
    end;
  end;
  FindArrayListItem := -1;
end;

{ ContainsArrayListItem - Check if contains item }
function ContainsArrayListItem(var list: TArrayList; item: Pointer): Boolean;
begin
  ContainsArrayListItem := FindArrayListItem(list, item) >= 0;
end;

{ ForEachArrayListItem - Apply procedure to each item }
procedure ForEachArrayListItem(var list: TArrayList; proc: TIteratorProc);
var
  i: TInt;
begin
  for i := 0 to list.Count - 1 do
    proc(GetArrayListItem(list, i), i);
end;

{ ============================================================================ }
{ TLinkedList Implementation                                                   }
{ ============================================================================ }

{ InitLinkedList - Initialize empty list }
procedure InitLinkedList(var list: TLinkedList);
begin
  list.Head := nil;
  list.Tail := nil;
  list.Count := 0;
end;

{ FreeLinkedList - Free all nodes (does not free items) }
procedure FreeLinkedList(var list: TLinkedList);
var
  node, nextNode: PLinkedListNode;
begin
  node := list.Head;
  while node <> nil do
  begin
    nextNode := node^.Next;
    Dispose(node);
    node := nextNode;
  end;
  list.Head := nil;
  list.Tail := nil;
  list.Count := 0;
end;

{ ClearLinkedList - Remove all nodes without freeing items }
procedure ClearLinkedList(var list: TLinkedList);
begin
  FreeLinkedList(list);
end;

{ ClearAndFreeLinkedList - Clear and free all items using callback }
procedure ClearAndFreeLinkedList(var list: TLinkedList; freeProc: TFreeProc);
var
  node: PLinkedListNode;
begin
  node := list.Head;
  while node <> nil do
  begin
    freeProc(node^.Item);
    node := node^.Next;
  end;
  FreeLinkedList(list);
end;

{ GetLinkedListNode - Get node at index (0-based) }
function GetLinkedListNode(var list: TLinkedList; index: TInt): PLinkedListNode;
var
  node: PLinkedListNode;
  i: TInt;
begin
  { Optimize by starting from the closer end }
  if index < list.Count div 2 then
  begin
    { Start from head }
    node := list.Head;
    for i := 0 to index - 1 do
      node := node^.Next;
  end
  else
  begin
    { Start from tail }
    node := list.Tail;
    for i := list.Count - 1 downto index + 1 do
      node := node^.Prev;
  end;

  GetLinkedListNode := node;
end;

{ GetLinkedListItem - Get item at index }
function GetLinkedListItem(var list: TLinkedList; index: TInt): Pointer;
var
  node: PLinkedListNode;
begin
  node := GetLinkedListNode(list, index);
  if node <> nil then
    GetLinkedListItem := node^.Item
  else
    GetLinkedListItem := nil;
end;

{ AddLinkedListItemFirst - Add to beginning }
procedure AddLinkedListItemFirst(var list: TLinkedList; item: Pointer);
var
  node: PLinkedListNode;
begin
  New(node);
  node^.Item := item;
  node^.Next := list.Head;
  node^.Prev := nil;

  if list.Head <> nil then
    list.Head^.Prev := node
  else
    list.Tail := node;

  list.Head := node;
  list.Count := list.Count + 1;
end;

{ AddLinkedListItemLast - Add to end }
procedure AddLinkedListItemLast(var list: TLinkedList; item: Pointer);
var
  node: PLinkedListNode;
begin
  New(node);
  node^.Item := item;
  node^.Next := nil;
  node^.Prev := list.Tail;

  if list.Tail <> nil then
    list.Tail^.Next := node
  else
    list.Head := node;

  list.Tail := node;
  list.Count := list.Count + 1;
end;

{ InsertLinkedListItem - Insert at index }
procedure InsertLinkedListItem(var list: TLinkedList; index: TInt; item: Pointer);
var
  node, newNode: PLinkedListNode;
begin
  if index = 0 then
  begin
    AddLinkedListItemFirst(list, item);
    Exit;
  end;

  if index >= list.Count then
  begin
    AddLinkedListItemLast(list, item);
    Exit;
  end;

  node := GetLinkedListNode(list, index);
  InsertLinkedListNodeBefore(list, node, item);
end;

{ InsertLinkedListNodeBefore - Insert before node }
procedure InsertLinkedListNodeBefore(var list: TLinkedList; node: PLinkedListNode; item: Pointer);
var
  newNode: PLinkedListNode;
begin
  if node = nil then
    Exit;

  New(newNode);
  newNode^.Item := item;
  newNode^.Next := node;
  newNode^.Prev := node^.Prev;

  if node^.Prev <> nil then
    node^.Prev^.Next := newNode
  else
    list.Head := newNode;

  node^.Prev := newNode;
  list.Count := list.Count + 1;
end;

{ InsertLinkedListNodeAfter - Insert after node }
procedure InsertLinkedListNodeAfter(var list: TLinkedList; node: PLinkedListNode; item: Pointer);
var
  newNode: PLinkedListNode;
begin
  if node = nil then
    Exit;

  New(newNode);
  newNode^.Item := item;
  newNode^.Next := node^.Next;
  newNode^.Prev := node;

  if node^.Next <> nil then
    node^.Next^.Prev := newNode
  else
    list.Tail := newNode;

  node^.Next := newNode;
  list.Count := list.Count + 1;
end;

{ RemoveLinkedListNode - Remove and return item }
function RemoveLinkedListNode(var list: TLinkedList; node: PLinkedListNode): Pointer;
begin
  if node = nil then
  begin
    RemoveLinkedListNode := nil;
    Exit;
  end;

  RemoveLinkedListNode := node^.Item;

  { Update links }
  if node^.Prev <> nil then
    node^.Prev^.Next := node^.Next
  else
    list.Head := node^.Next;

  if node^.Next <> nil then
    node^.Next^.Prev := node^.Prev
  else
    list.Tail := node^.Prev;

  list.Count := list.Count - 1;
  Dispose(node);
end;

{ DeleteLinkedListNode - Remove node (doesn't return) }
procedure DeleteLinkedListNode(var list: TLinkedList; node: PLinkedListNode);
var
  dummy: Pointer;
begin
  dummy := RemoveLinkedListNode(list, node);
end;

{ RemoveLinkedListItem - Remove and return item }
function RemoveLinkedListItem(var list: TLinkedList; index: TInt): Pointer;
var
  node: PLinkedListNode;
begin
  node := GetLinkedListNode(list, index);
  RemoveLinkedListItem := RemoveLinkedListNode(list, node);
end;

{ DeleteLinkedListItem - Remove item (doesn't return) }
procedure DeleteLinkedListItem(var list: TLinkedList; index: TInt);
var
  dummy: Pointer;
begin
  dummy := RemoveLinkedListItem(list, index);
end;

{ FindLinkedListNode - Find node (nil if not found) }
function FindLinkedListNode(var list: TLinkedList; item: Pointer): PLinkedListNode;
var
  node: PLinkedListNode;
begin
  node := list.Head;
  while node <> nil do
  begin
    if node^.Item = item then
    begin
      FindLinkedListNode := node;
      Exit;
    end;
    node := node^.Next;
  end;
  FindLinkedListNode := nil;
end;

{ FindLinkedListItem - Find index (-1 if not found) }
function FindLinkedListItem(var list: TLinkedList; item: Pointer): TInt;
var
  node: PLinkedListNode;
  index: TInt;
begin
  node := list.Head;
  index := 0;
  while node <> nil do
  begin
    if node^.Item = item then
    begin
      FindLinkedListItem := index;
      Exit;
    end;
    node := node^.Next;
    index := index + 1;
  end;
  FindLinkedListItem := -1;
end;

{ ContainsLinkedListItem - Check if contains item }
function ContainsLinkedListItem(var list: TLinkedList; item: Pointer): Boolean;
begin
  ContainsLinkedListItem := FindLinkedListNode(list, item) <> nil;
end;

{ ForEachLinkedListItem - Apply procedure to each item (forward) }
procedure ForEachLinkedListItem(var list: TLinkedList; proc: TIteratorProc);
var
  node: PLinkedListNode;
  index: TInt;
begin
  node := list.Head;
  index := 0;
  while node <> nil do
  begin
    proc(node^.Item, index);
    node := node^.Next;
    index := index + 1;
  end;
end;

{ ForEachLinkedListItemReverse - Apply procedure (reverse) }
procedure ForEachLinkedListItemReverse(var list: TLinkedList; proc: TIteratorProc);
var
  node: PLinkedListNode;
  index: TInt;
begin
  node := list.Tail;
  index := list.Count - 1;
  while node <> nil do
  begin
    proc(node^.Item, index);
    node := node^.Prev;
    index := index - 1;
  end;
end;

end.
