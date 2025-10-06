# Resizable Lists

Pascal's array type is very basic. The `Lists` unit implements two more complex list types: `TArrayList` and `TLinkedList`.

Both list types store generic pointers (`Pointer` type) to allow storing any data type. Users are responsible for managing the memory of stored items.

## TArrayList

`TArrayList` is a resizable list backed by a single block of memory (dynamic array). It provides:

- **Constant time access** - Direct indexing into the array
- **Linear time iteration** - Sequential traversal
- **Linear time insertion** - May require shifting elements
- **Constant time addition (amortized)** - Best case: append to end; Worst case: resize array

### Structure

```pascal
type
  PPointer = ^Pointer;

  TArrayList = record
    Items: PPointer;       { Pointer to allocated memory block }
    Count: TInt;           { Number of items currently in list }
    Capacity: TInt;        { Current allocated capacity }
  end;
```

Memory is allocated using `GetMem` and `FreeMem` from standard Pascal. When the array needs to grow, memory is reallocated and existing items are copied to the new location.

**Accessing items**: To access the i-th item in the array, use pointer arithmetic:

```pascal
{ Get pointer to i-th element }
itemPtr := PPointer(PtrUInt(list.Items) + (i * SizeOf(Pointer)));
{ Access the item }
item := itemPtr^;
```

### Procedures and Functions

**Initialization and Cleanup:**

- `procedure InitArrayList(var list: TArrayList; initialCapacity: TInt)` - Initialize with initial capacity
- `procedure FreeArrayList(var list: TArrayList)` - Free the list (does not free items)
- `procedure ClearArrayList(var list: TArrayList)` - Remove all items without freeing memory
- `procedure ClearAndFreeArrayList(var list: TArrayList; freeProc: TFreeProc)` - Clear and free all items using callback

**Access:**

- `function GetArrayListItem(var list: TArrayList; index: TInt): Pointer` - Get item at index (0-based)
- `procedure SetArrayListItem(var list: TArrayList; index: TInt; item: Pointer)` - Set item at index

**Modification:**

- `procedure AddArrayListItem(var list: TArrayList; item: Pointer)` - Add item to end
- `procedure InsertArrayListItem(var list: TArrayList; index: TInt; item: Pointer)` - Insert at index
- `procedure RemoveArrayListItem(var list: TArrayList; index: TInt): Pointer` - Remove and return item
- `procedure DeleteArrayListItem(var list: TArrayList; index: TInt)` - Remove item (doesn't return)

**Capacity Management:**

- `procedure EnsureArrayListCapacity(var list: TArrayList; minCapacity: TInt)` - Ensure minimum capacity
- `procedure TrimArrayListCapacity(var list: TArrayList)` - Reduce capacity to match count

**Searching:**

- `function FindArrayListItem(var list: TArrayList; item: Pointer): TInt` - Find index (-1 if not found)
- `function ContainsArrayListItem(var list: TArrayList; item: Pointer): Boolean` - Check if contains item

**Iteration:**

- `procedure ForEachArrayListItem(var list: TArrayList; proc: TIteratorProc)` - Apply procedure to each item

### TArrayList Callback Types

```pascal
type
  TFreeProc = procedure(item: Pointer);
  TIteratorProc = procedure(item: Pointer; index: TInt);
```

## TLinkedList

`TLinkedList` is a resizable list backed by a series of doubly-linked nodes. It provides:

- **Linear time access** - Must traverse from head or tail
- **Linear time iteration** - Sequential traversal
- **Constant time insertion** - No element shifting required
- **Constant time addition** - Add to head or tail

### TLinkedList Structure

```pascal
type
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
```

### TLinkedList Procedures and Functions

**Initialization and Cleanup:**

- `procedure InitLinkedList(var list: TLinkedList)` - Initialize empty list
- `procedure FreeLinkedList(var list: TLinkedList)` - Free all nodes (does not free items)
- `procedure ClearLinkedList(var list: TLinkedList)` - Remove all nodes without freeing items
- `procedure ClearAndFreeLinkedList(var list: TLinkedList; freeProc: TFreeProc)` - Clear and free all items using callback

**Access:**

- `function GetLinkedListNode(var list: TLinkedList; index: TInt): PLinkedListNode` - Get node at index (0-based)
- `function GetLinkedListItem(var list: TLinkedList; index: TInt): Pointer` - Get item at index

**Modification (by position):**

- `procedure AddLinkedListItemFirst(var list: TLinkedList; item: Pointer)` - Add to beginning
- `procedure AddLinkedListItemLast(var list: TLinkedList; item: Pointer)` - Add to end
- `procedure InsertLinkedListItem(var list: TLinkedList; index: TInt; item: Pointer)` - Insert at index
- `procedure RemoveLinkedListItem(var list: TLinkedList; index: TInt): Pointer` - Remove and return item
- `procedure DeleteLinkedListItem(var list: TLinkedList; index: TInt)` - Remove item (doesn't return)

**Modification (by node):**

- `procedure InsertLinkedListNodeBefore(var list: TLinkedList; node: PLinkedListNode; item: Pointer)` - Insert before node
- `procedure InsertLinkedListNodeAfter(var list: TLinkedList; node: PLinkedListNode; item: Pointer)` - Insert after node
- `procedure RemoveLinkedListNode(var list: TLinkedList; node: PLinkedListNode): Pointer` - Remove and return item
- `procedure DeleteLinkedListNode(var list: TLinkedList; node: PLinkedListNode)` - Remove node (doesn't return)

**Searching:**

- `function FindLinkedListNode(var list: TLinkedList; item: Pointer): PLinkedListNode` - Find node (nil if not found)
- `function FindLinkedListItem(var list: TLinkedList; item: Pointer): TInt` - Find index (-1 if not found)
- `function ContainsLinkedListItem(var list: TLinkedList; item: Pointer): Boolean` - Check if contains item

**Iteration:**

- `procedure ForEachLinkedListItem(var list: TLinkedList; proc: TIteratorProc)` - Apply procedure to each item (forward)
- `procedure ForEachLinkedListItemReverse(var list: TLinkedList; proc: TIteratorProc)` - Apply procedure (reverse)

### TLinkedList Callback Types

```pascal
type
  TFreeProc = procedure(item: Pointer);
  TIteratorProc = procedure(item: Pointer; index: TInt);
```

## Usage Notes

1. **Memory Management**: Both list types store `Pointer` values. The caller is responsible for:

   - Allocating memory for items before adding to list
   - Freeing memory for items when removing from list or using `ClearAndFree*` with appropriate callback

2. **Index Bounds**: Indices are 0-based. Accessing out-of-bounds indices is undefined behavior.

3. **Performance Characteristics**:

   - Use `TArrayList` when you need fast random access and mostly append operations
   - Use `TLinkedList` when you need frequent insertions/deletions in the middle of the list

4. **Growth Strategy** (TArrayList): When capacity is exceeded, the array doubles in size to provide amortized O(1) append performance.

5. **Thread Safety**: Neither list type is thread-safe. External synchronization is required for concurrent access.

## Examples

### TArrayList Example

```pascal
var
  list: TArrayList;
  item: PInteger;
  i: TInt;

begin
  InitArrayList(list, 10);

  { Add items }
  for i := 0 to 9 do
  begin
    New(item);
    item^ := i * 10;
    AddArrayListItem(list, item);
  end;

  { Access items }
  item := GetArrayListItem(list, 5);
  WriteLn('Item at index 5: ', item^);

  { Clean up }
  for i := 0 to list.Count - 1 do
  begin
    item := GetArrayListItem(list, i);
    Dispose(item);
  end;
  FreeArrayList(list);
end;
```

### TLinkedList Example

```pascal
var
  list: TLinkedList;
  item: PInteger;
  node: PLinkedListNode;

begin
  InitLinkedList(list);

  { Add items }
  New(item); item^ := 100;
  AddLinkedListItemFirst(list, item);

  New(item); item^ := 200;
  AddLinkedListItemLast(list, item);

  { Iterate forward }
  node := list.Head;
  while node <> nil do
  begin
    item := node^.Item;
    WriteLn('Item: ', item^);
    node := node^.Next;
  end;

  { Clean up }
  node := list.Head;
  while node <> nil do
  begin
    item := node^.Item;
    Dispose(item);
    node := node^.Next;
  end;
  FreeLinkedList(list);
end;
```
