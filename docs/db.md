# Database Library

RetroBBS stores data in a variety of data files. To make it easier to work with and maintain these files, the `DB` unit defines a standard data file format and utility functions for working with it.

## Data File Format

RetroBBS data files are binary files that store fixed sized records. This allows for both random access of specific records and easy reuse of freed space when records are removed. To accomplish this, the data file is divided into equal size blocks.

**Note: Data files are not guaranteed to be readable by a RetroBBS instance running on a different operating system than the one that originally created the data file. This is especially true when moving between 16, 32, and 64 bit systems. Cross-platform compatibility issues include:**
- **Endianness**: Big-endian vs little-endian byte order
- **Record alignment**: Different compilers may pad records differently
- **Integer sizes**: Integer may be 16-bit on old systems, 32-bit on modern ones

**Recommendation**: Always use explicit byte-by-byte serialization (like the BTree unit does) rather than direct record writes for true cross-platform compatibility.

### Files

Each database is actually comprised of a number of files. Let's look at the `Users` database as an example:
- USERS.INF - Info about the database structure
- USERS.DAT - The actual data is stored here
- USERS.IDX - List of indexes
- USERS.I00 - Index 00 - contains a B-Tree as defined by the `BTree` unit
- USERS.I01 - Index 01 - another index (e.g., username index)

Multiple index files allow querying the same data by different keys (e.g., user ID or username).

### Info File Layout

The `.INF` file contains a single record of type `TDBInfo` stored in fixed length binary format. This information is generally kept in memory while the program is running.

| Name          | Type            | Notes                                      |
| ------------- | --------------- | ------------------------------------------ |
| Name          | Str64           | Database name (e.g., "Users")              |
| BlockSize     | Word            | Size of each data block in bytes           |
| LastCompacted | TBBSTimestamp   | Timestamp of last compaction operation     |

**Compaction**: The process of removing empty blocks and rebuilding indexes to reclaim disk space. The `LastCompacted` field tracks when this was last done.

### Data Block Layout

The `.DAT` file contains a series of records of type `TDBData` stored in fixed length binary format. Blocks are numbered sequentially starting from 0. This data is queried on demand as needed by the program and not stored in memory.

| Name  | Type                          | Notes                                    |
| ----- | ----------------------------- | ---------------------------------------- |
| ID    | LongInt (4 bytes)             | Unique record identifier                 |
| Empty | Boolean (1 byte)              | If True, block can be reused             |
| Data  | array[0..BlockSize-9] of Byte | Actual record data (variable size)       |

**Block Size Calculation**:
- Overhead: 4 bytes (ID) + 1 byte (Empty) + 4 bytes (alignment) = 9 bytes minimum
- Data size: BlockSize - 9 bytes
- Total block size must account for record alignment on the target platform

**Free Space Management**:
- When a record is deleted, its `Empty` flag is set to `True`
- Finding free space requires scanning the .DAT file for empty blocks (O(n) operation)
- Consider implementing a free list or bitmap for O(1) free block lookup in production use

### Index List Layout

The `.IDX` file contains a series of records of type `TDBIndexInfo` stored in fixed length binary format. This information is generally kept in memory while the program is running.

| Name          | Type           | Notes                                           |
| ------------- | -------------- | ----------------------------------------------- |
| FieldName     | Str64          | The name of the field being indexed             |
| IndexType     | TDBIndexType   | itID (0) = LongInt ID, itString (1) = Str64     |
| IndexNumber   | Byte           | Maps to one of the `I??` files (00-99)          |

**Index Type Enumeration**:
```pascal
type
  TDBIndexType = (itID, itString);
```

This is more type-safe than using raw Byte values.

### Index Layout

The `.I??` files contain a B-Tree as defined by the `BTree` unit. The `??` in the extension should be replaced by the `IndexNumber` value formatted as a 2-digit decimal. For example, `USERS.I00` or `USERS.I01`.

**Index Key Generation**:
- `itID` type indexes: Use the ID value directly as the B-Tree key
- `itString` type indexes: Use the `StringKey()` function to generate a CRC16-based key from the string

**Index Values**: The B-Tree values are block numbers in the .DAT file where the record can be found.

### Example Usage: Find a User by ID

At program start, the program reads the data in `.INF` and `.IDX` files into memory. This data doesn't normally change during runtime.

To find a User by their ID, the program:

1. **Looks up the index**: Searches through the `TDBIndexInfo` records for one with `FieldName = "ID"`
   - Example: `{FieldName: "ID", IndexType: itID, IndexNumber: 0}`

2. **Opens the index file**: Opens `USERS.I00` using the `BTree` unit
   ```pascal
   OpenBTree(tree, 'USERS.I00');
   ```

3. **Finds the block number**: Calls `Find(tree, userID, values, count)` where `userID` is the ID to search for
   - The `values` array will contain one or more block numbers

4. **Reads the data block**: For each block number in `values`:
   - Seeks to position `(blockNum * blockSize)` in `USERS.DAT`
   - Reads the `TDBData` record
   - Verifies `Empty = False` and `ID = userID`
   - Returns the `Data` field to the caller

5. **Closes the index**: `CloseBTree(tree)`

### Example Usage: Find a User by Username

Similar to finding by ID, but using a string index:

1. **Looks up the index**: Find `TDBIndexInfo` with `FieldName = "Username"`
   - Example: `{FieldName: "Username", IndexType: itString, IndexNumber: 1}`

2. **Opens the index file**: Opens `USERS.I01`

3. **Generates string key**: `key := StringKey('alice')`
   - This is case-insensitive, so 'alice', 'Alice', 'ALICE' all produce the same key

4. **Finds the block number**: `Find(tree, key, values, count)`

5. **Reads and validates**: Read block(s), verify username matches (handle hash collisions)

6. **Closes the index**

### Example Usage: Adding a New Record

1. **Assign ID**: Get next available ID (scan all records or maintain counter)

2. **Find free block**:
   - Scan .DAT file for block with `Empty = True`
   - Or append new block at end of file

3. **Write data**:
   ```pascal
   block.ID := newID;
   block.Empty := False;
   block.Data := userData;
   { Write to .DAT at blockNum * blockSize }
   ```

4. **Update all indexes**:
   - For ID index: `Insert(idTree, newID, blockNum)`
   - For username index: `Insert(nameTree, StringKey(username), blockNum)`
   - Keep all indexes synchronized

### Example Usage: Deleting a Record

1. **Find the record**: Use index to get block number

2. **Mark empty**:
   ```pascal
   block.Empty := True;
   { Write updated block back to .DAT }
   ```

3. **Update indexes**: Remove from all indexes
   - `Delete(idTree, recordID)`
   - `DeleteValue(nameTree, StringKey(username), blockNum)`

4. **Compaction**: Eventually run compaction to reclaim space

### Example Usage: Updating a Record

**Non-indexed field changes**: Simply overwrite the block in .DAT

**Indexed field changes** (e.g., username change):
1. Delete old index entries
2. Update the data block
3. Insert new index entries
4. Must be done atomically or data may become inconsistent

## Database Helper Methods

The `DB` unit should provide high-level helper methods to encapsulate these operations:

### Database Operations

**`OpenDatabase(name: Str64; var db: TDatabase): Boolean`**
- Opens all database files (.INF, .DAT, .IDX, .I??)
- Loads metadata into memory
- Returns true on success

**`CloseDatabase(var db: TDatabase)`**
- Closes all open files
- Writes any cached metadata

**`CreateDatabase(name: Str64; blockSize: Word): Boolean`**
- Creates new .INF, .DAT, and .IDX files
- Initializes with default values
- Returns true on success

### Record Operations

**`AddRecord(var db: TDatabase; data: array of Byte; var recordID: LongInt): Boolean`**
- Finds free block or allocates new one
- Writes data to .DAT file
- Updates all indexes
- Returns new record ID

**`FindRecordByID(var db: TDatabase; id: LongInt; var data: array of Byte): Boolean`**
- Uses ID index to locate block
- Reads and returns record data
- Returns true if found

**`FindRecordByString(var db: TDatabase; fieldName: Str64; value: Str64; var data: array of Byte): Boolean`**
- Generates key using StringKey()
- Uses appropriate string index
- Handles hash collisions
- Returns first matching record

**`UpdateRecord(var db: TDatabase; id: LongInt; data: array of Byte): Boolean`**
- Finds record by ID
- Overwrites data in existing block
- Updates indexes if indexed fields changed
- Returns true on success

**`DeleteRecord(var db: TDatabase; id: LongInt): Boolean`**
- Marks block as empty
- Removes from all indexes
- Returns true on success

### Index Operations

**`AddIndex(var db: TDatabase; fieldName: Str64; indexType: TDBIndexType): Boolean`**
- Creates new .I?? file
- Scans existing records to build index
- Updates .IDX file
- Returns true on success

**`RebuildIndex(var db: TDatabase; indexNumber: Byte): Boolean`**
- Clears and rebuilds specified index
- Useful for corruption recovery
- Returns true on success

### Maintenance Operations

**`CompactDatabase(var db: TDatabase): Boolean`**
- Removes empty blocks
- Rebuilds all indexes
- Updates LastCompacted timestamp
- Returns true on success

**`ValidateDatabase(var db: TDatabase): Boolean`**
- Checks for corruption
- Validates indexes against data
- Returns true if database is valid

## Data Types

```pascal
type
  TDBIndexType = (itID, itString);

  TDBInfo = record
    Name: Str64;
    BlockSize: Word;
    LastCompacted: TBBSTimestamp;
  end;

  TDBIndexInfo = record
    FieldName: Str64;
    IndexType: TDBIndexType;
    IndexNumber: Byte;
  end;

  TDBData = record
    ID: LongInt;
    Empty: Boolean;
    Data: array[0..MAX_BLOCK_SIZE-9] of Byte;
  end;

  TDatabase = record
    Info: TDBInfo;
    Indexes: array of TDBIndexInfo;
    DataFile: File;
    IndexFiles: array of TBTree;
    IsOpen: Boolean;
  end;
```

## Performance Considerations

- **Index lookups**: O(log n) via B-Tree - fast
- **Finding free blocks**: O(n) linear scan - slow without free list
- **Multiple indexes**: Each insert/update/delete must update all indexes
- **Hash collisions**: StringKey uses CRC16, so collisions are possible (1 in 65536)
  - Always verify string match after hash lookup
- **No transactions**: Updates are not atomic; crash during update may corrupt database

## Future Enhancements

1. **Free list management**: Bitmap or linked list of empty blocks
2. **Transaction support**: Atomic operations with rollback
3. **Write-ahead logging**: For crash recovery
4. **Checksums**: Detect corruption
5. **Compression**: For large text fields
6. **Variable-length records**: More space-efficient
7. **Index caching**: Keep frequently-used index nodes in memory
