# A file based B-Tree implementation

The `BTree` unit implements a file-based B-Tree that is used by the `DB` unit for indexing. The unit is separated out for ease of testing and reuse. The file that the B-Tree is stored in is broken up into 512 byte pages, which aligns with common disk block sizes for 16bit and 32bit operating systems. Both keys and values are LongInts. If a key has more values than can be stored in its node, then an overflow page is allocated for them. Overflow pages are stored in a separate page in the same file. The very first page of the file contains a header with various information about the tree.

To create a B-Tree you need to provide the path to the file the tree will be stored in.

## Usage Example

```pascal
uses BTree;

var
  tree: TBTree;
  values: array[0..99] of LongInt;
  count: Integer;
  userKey: LongInt;

begin
  { Create a new B-Tree }
  CreateBTree('index.btree');

  { Open the B-Tree }
  OpenBTree(tree, 'index.btree');

  { Insert numeric key-value pairs }
  Insert(tree, 100, 200);    { Key: 100, Value: 200 }
  Insert(tree, 100, 201);    { Multiple values for same key }
  Insert(tree, 150, 300);    { Different key }

  { Insert using string-based keys }
  userKey := StringKey('alice');
  Insert(tree, userKey, 1);  { User ID 1 for username 'alice' }

  { Find values for a key }
  if Find(tree, 100, values, count) then
    WriteLn('Found ', count, ' values for key 100');

  { Find by username (case-insensitive) }
  userKey := StringKey('ALICE');  { Same key as 'alice' }
  if Find(tree, userKey, values, count) then
    WriteLn('User alice has ID: ', values[0]);

  { Delete a specific value }
  DeleteValue(tree, 100, 200);

  { Delete all values for a key }
  Delete(tree, 150);

  { Close the tree }
  CloseBTree(tree);
end;
```

## Implementation Details

### File Structure

The B-Tree file is organized into 512-byte pages:

- **Page 0**: Header page containing tree metadata
- **Page 1+**: Node pages (internal nodes, leaf nodes, or overflow pages)

### Page Types

1. **Header Page (Page 0)**
   - Magic number: 'BTRE' (4 bytes)
   - Format version: Word (2 bytes)
   - Tree order: Word (2 bytes) - maximum children per node
   - Root page number: LongInt (4 bytes)
   - Next free page: LongInt (4 bytes)
   - Total page count: LongInt (4 bytes)

2. **Leaf Node Pages**
   - Page type: Byte (1 = leaf)
   - Key count: Word (2 bytes)
   - Next leaf pointer: LongInt (4 bytes) - for range queries
   - Entries: Array of leaf entries
     - Each entry contains:
       - Key: LongInt (4 bytes)
       - Value count: Word (2 bytes)
       - Values: Array of LongInt (up to 60 values)
       - Overflow page: LongInt (4 bytes, 0 if none)

3. **Internal Node Pages** (for future expansion)
   - Page type: Byte (2 = internal)
   - Key count: Word
   - Keys and child page pointers

4. **Overflow Pages** (for future expansion)
   - Page type: Byte (4 = overflow)
   - Value count: Word
   - Next overflow page: LongInt
   - Values: Array of LongInt (up to 120 values)

### Capacity

With 512-byte pages:
- **Maximum keys per leaf node**: 60
- **Maximum values per key (in-node)**: 60
- **Maximum values in overflow page**: 120
- **Tree order**: 61 (max 60 keys, 61 children)

### Current Limitations

The current implementation is simplified and suitable for small to medium datasets:

1. **No node splitting**: The root is always a leaf node. Once MAX_KEYS is reached, inserts fail.
2. **No internal nodes**: Tree does not grow in height, limiting capacity.
3. **Basic overflow**: Overflow pages are allocated but not yet implemented.
4. **Linear search**: Uses linear search within nodes (good for small nodes).

These limitations make the implementation simple and suitable for learning, testing, and small-scale use. Future enhancements can add full B-Tree splitting, balancing, and multi-level trees.

## Data Structures

```pascal
const
  PAGE_SIZE = 512;
  MAX_KEYS = 60;        { Maximum keys per node }
  MAX_VALUES = 60;      { Maximum values per key in a leaf }
  MAX_OVERFLOW = 120;   { Maximum values in an overflow page }

type
  TPageNum = LongInt;
  TKeyValue = LongInt;

  TPageType = (ptNone, ptHeader, ptInternal, ptLeaf, ptOverflow);

  TBTreeHeader = record
    Magic: array[0..3] of Char;
    Version: Word;
    Order: Word;
    RootPage: TPageNum;
    NextFreePage: TPageNum;
    PageCount: LongInt;
  end;

  TLeafEntry = record
    Key: TKeyValue;
    ValueCount: Word;
    Values: array[0..MAX_VALUES-1] of TKeyValue;
    OverflowPage: TPageNum;
  end;

  TBTree = record
    FileName: String;
    FileHandle: File;
    Header: TBTreeHeader;
    IsOpen: Boolean;
  end;
```

## Methods

### File Operations

**`CreateBTree(fileName: String): Boolean`**
- Creates a new B-Tree file
- Initializes header with magic number and metadata
- Creates empty root leaf node
- Returns true on success

**`OpenBTree(var tree: TBTree; fileName: String): Boolean`**
- Opens an existing B-Tree file
- Reads and validates header
- Returns true on success

**`CloseBTree(var tree: TBTree)`**
- Writes updated header to disk
- Closes the file
- Marks tree as not open

### Data Operations

**`Insert(var tree: TBTree; key: TKeyValue; value: TKeyValue): Boolean`**
- Inserts a key-value pair
- If key exists, adds value to that key's value list
- If key doesn't exist, creates new entry
- Returns true on success

**`Find(var tree: TBTree; key: TKeyValue; var values: array of TKeyValue; var count: Integer): Boolean`**
- Finds all values for a given key
- Returns values in the provided array
- Sets count to number of values found
- Returns true if key exists

**`Delete(var tree: TBTree; key: TKeyValue): Boolean`**
- Deletes a key and all its associated values
- Shifts remaining entries to fill gap
- Returns true on success

**`DeleteValue(var tree: TBTree; key: TKeyValue; value: TKeyValue): Boolean`**
- Deletes a specific key-value pair
- If no values remain for key, deletes the key entirely
- Returns true on success

### Utility Functions

**`StringKey(s: Str255): TKeyValue`**
- Generates a B-Tree key from a string
- Converts string to lowercase for case-insensitive lookups
- Computes CRC16 hash of the lowercase string
- Returns the CRC16 value as a LongInt key
- Use this to create keys for indexing string values like usernames

Example:
```pascal
var
  key: LongInt;
begin
  key := StringKey('Username');  { Same as StringKey('username') }
  Insert(tree, key, 12345);      { Index user ID 12345 under this name }
end;
```

## Testing

Run the B-Tree test suite:

```bash
make test
bin/tests/btreetest
```

The test suite covers:
- File creation and opening
- Single and multiple key-value insertions
- Multiple values per key
- Key lookups (existing and non-existent)
- Value and key deletion
- Data persistence across close/reopen
- StringKey utility function (consistency, case-insensitivity, uniqueness)

All 17 tests pass successfully.

## Future Enhancements

For production use with larger datasets, consider adding:

1. **Node splitting and merging**: Allow tree to grow beyond single leaf
2. **Internal nodes**: Multi-level B-Tree for better scalability
3. **Overflow page implementation**: Support unlimited values per key
4. **Binary search**: Within nodes for better performance
5. **Range queries**: Leverage next-leaf pointers for scans
6. **Bulk loading**: Efficient initial tree construction
7. **Defragmentation**: Reclaim deleted page space
