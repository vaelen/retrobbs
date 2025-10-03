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
- USERS.DAT - The actual data is stored here (includes header in first block)
- USERS.IDX - Primary index mapping Record ID → Block ID (B-Tree)
- USERS.I00 - Secondary index 00 (e.g., username → Record ID)
- USERS.I01 - Secondary index 01 (e.g., email → Record ID)
- USERS.JNL - Journal file for transaction recovery

**Index Architecture**:
- The `.IDX` file is the primary index that maps Record IDs to physical Block IDs
- All secondary indexes (`.I??` files) map field values to Record IDs
- This indirection allows records to move between blocks without updating secondary indexes
- Only the primary `.IDX` index needs updating when a record's physical location changes

### Database Header (Block 0 of .DAT file)

The first block (block 0) of the `.DAT` file contains a `TDBHeader` record stored in fixed length binary format. This header is loaded into memory when the database is opened.

| Name            | Type                          | Notes                                      |
| --------------- | ----------------------------- | ------------------------------------------ |
| Signature       | array[0..7] of Char           | 'RETRODB' + #0 for file type validation    |
| Version         | Word                          | Format version (currently 1)               |
| BlockSize       | Word                          | Size of each data block in bytes           |
| RecordCount     | LongInt                       | Total number of active records             |
| NextRecordID    | LongInt                       | Next available Record ID                   |
| LastCompacted   | TBBSTimestamp                 | Timestamp of last compaction operation     |
| JournalPending  | Boolean                       | True if journal needs replay on open       |
| IndexCount      | Word                          | Number of secondary indexes (0-99)         |
| Indexes         | array[0..98] of TDBIndexInfo  | Secondary index definitions                |
| Reserved        | Padding to BlockSize          | Reserved for future use                    |

**TDBIndexInfo** (embedded in header):
| Name          | Type           | Notes                                           |
| ------------- | -------------- | ----------------------------------------------- |
| FieldName     | Str31          | The name of the field being indexed             |
| IndexType     | TDBIndexType   | itID (0) = LongInt ID, itString (1) = Str63     |
| IndexNumber   | Byte           | Maps to one of the `I??` files (00-99)          |

**Index Type Enumeration**:
```pascal
type
  TDBIndexType = (itID, itString);
```

**Signature**: Used to verify file format. Always 'RETRODB' followed by null terminator.

**Version**: Format version number. Current version is 1. Future incompatible changes increment this.

**RecordCount**: Tracks active records. Updated on add/delete operations.

**NextRecordID**: Auto-incrementing counter for assigning new Record IDs. Never decreases.

**Compaction**: The process of removing empty blocks and rebuilding indexes to reclaim disk space. The `LastCompacted` field tracks when this was last done.

**Journal Pending**: Set to `True` when a transaction begins, `False` when committed. If `True` on database open, the journal must be replayed to complete interrupted operations.

**IndexCount**: Number of active secondary indexes. Maximum 99 (I00 through I98).

**Indexes**: Array containing metadata for all secondary indexes. Only the first `IndexCount` entries are valid.

### Data Block Layout

The `.DAT` file contains a series of records of type `TDBData` stored in fixed length binary format. Blocks are numbered sequentially starting from 0 (block 0 is the header). Data blocks start at block 1. This data is queried on demand as needed by the program and not stored in memory.

| Name   | Type                          | Notes                                    |
| ------ | ----------------------------- | ---------------------------------------- |
| ID     | LongInt (4 bytes)             | Unique record identifier                 |
| Status | Byte (1 byte)                 | 0 = Empty, 1 = Active                    |
| Data   | array[0..BlockSize-6] of Byte | Actual record data (variable size)       |

**Block Size Calculation**:
- Overhead: 4 bytes (ID) + 1 byte (Status) + 1 byte (alignment) = 6 bytes minimum
- Data size: BlockSize - 6 bytes
- Total block size must account for record alignment on the target platform

**Free Space Management**:
- When a record is deleted, its `Status` is set to 0 (Empty)
- Finding free space requires scanning the .DAT file for empty blocks (O(n) operation)
- Consider implementing a free list or bitmap for O(1) free block lookup in production use

### Primary Index (.IDX file)

The `.IDX` file is a B-Tree index (as defined by the `BTree` unit) that maps Record IDs to Block IDs.

**Index Structure**:
- **Keys**: Record IDs (LongInt values from `TDBData.ID`)
- **Values**: Block IDs (physical block numbers in .DAT file where record is stored)
- **Purpose**: Translates logical Record IDs to physical block locations

This primary index is updated whenever:
- A record is added (insert RecordID → BlockID mapping)
- A record is moved to a new block during compaction (update RecordID mapping)
- A record is deleted (remove RecordID from index)

### Secondary Indexes (.I?? files)

The `.I??` files contain B-Tree indexes for specific fields. The `??` in the extension should be replaced by the `IndexNumber` value formatted as a 2-digit decimal. For example, `USERS.I00` or `USERS.I01`.

**Index Structure**:
- **Keys**: Field values (generated based on IndexType)
- **Values**: Record IDs (NOT block IDs)
- **Purpose**: Look up records by field values

**Index Key Generation**:
- `itID` type indexes: Use the field value directly as the B-Tree key
- `itString` type indexes: Use the `StringKey()` function to generate a CRC16-based key from the string

**Index Values**: The B-Tree values are Record IDs. To retrieve the actual record, perform a second lookup in the primary `.IDX` index to get the Block ID.

## Journal File Structure

The journal file (`<database>.jnl`) contains pending operations that have not yet been committed. Each journal entry is a fixed-size record that describes an operation to be performed on the database.

### TDBJournalEntry

| Name      | Type                          | Notes                                           |
| --------- | ----------------------------- | ----------------------------------------------- |
| Operation | Byte                          | 0 = None/Empty, 1 = Update, 2 = Delete, 3 = Add |
| BlockID   | LongInt (4 bytes)             | Block being modified, -1 for Add operations     |
| RecordID  | LongInt (4 bytes)             | Record ID for verification                      |
| Data      | array[0..BlockSize-1] of Byte | New record data (for Update and Add)            |
| Checksum  | Word (2 bytes)                | CRC16 of Operation + BlockID + RecordID + Data  |

**Journal Entry Size**: 1 + 4 + 4 + BlockSize + 2 = BlockSize + 11 bytes

**Operation Types**:
- **0 (None/Empty)**: Unused journal entry
- **1 (Update)**: Update existing block at BlockID with new Data
- **2 (Delete)**: Mark block at BlockID as Empty
- **3 (Add)**: Add new record with Data (BlockID is -1, actual block assigned during replay)

**Checksum**: The CRC16 checksum ensures journal entry integrity. Corrupted entries are skipped during replay.

### Example Usage: Find a User by ID (Record ID)

At program start, the program reads the database header from block 0 of the `.DAT` file. The header contains all index metadata.

To find a User by their Record ID, the program:

1. **Opens the primary index**: Opens `USERS.IDX` using the `BTree` unit
   ```pascal
   OpenBTree(idxTree, 'USERS.IDX');
   ```

2. **Finds the block number**: Calls `Find(idxTree, recordID, values, count)` where `recordID` is the Record ID to search for
   - The `values` array will contain the physical block number

3. **Reads the data block**:
   - Seeks to position `(blockNum * blockSize)` in `USERS.DAT`
   - Reads the `TDBData` record
   - Verifies `Status = 1` (Active) and `ID = recordID`
   - Returns the `Data` field to the caller

4. **Closes the index**: `CloseBTree(idxTree)`

### Example Usage: Find a User by Username

Finding by a secondary index requires two lookups: secondary index → Record ID, then primary index → Block ID.

1. **Looks up the index**: Search through `Header.Indexes` for `FieldName = "Username"`
   - Example: `{FieldName: "Username", IndexType: itString, IndexNumber: 0}`

2. **Opens the secondary index file**: Opens `USERS.I00`
   ```pascal
   OpenBTree(nameTree, 'USERS.I00');
   ```

3. **Generates string key**: `key := StringKey('alice')`
   - This is case-insensitive, so 'alice', 'Alice', 'ALICE' all produce the same key

4. **Finds the Record ID**: `Find(nameTree, key, recordIDs, count)`
   - The `recordIDs` array contains Record IDs (may be multiple due to hash collisions)

5. **Lookup Block ID**: For each Record ID:
   - Open primary index: `OpenBTree(idxTree, 'USERS.IDX')`
   - Find block: `Find(idxTree, recordID, blockNums, count)`
   - Read block from .DAT file
   - Verify username matches (handle CRC16 hash collisions)
   - Close primary index

6. **Closes the secondary index**: `CloseBTree(nameTree)`

### Example Usage: Adding a New Record

1. **Assign Record ID**: Use `Header.NextRecordID` and increment it

2. **Find free block**:
   - Scan .DAT file for block with `Status = 0` (Empty)
   - Or append new block at end of file

3. **Write data**:
   ```pascal
   block.ID := newRecordID;
   block.Status := 1;  { Active }
   block.Data := userData;
   { Write to .DAT at blockNum * blockSize }
   ```

4. **Update primary index**:
   - Open `USERS.IDX`
   - Insert mapping: `Insert(idxTree, newRecordID, blockNum)`

5. **Update all secondary indexes**:
   - For username index: `Insert(nameTree, StringKey(username), newRecordID)`
   - For email index: `Insert(emailTree, StringKey(email), newRecordID)`
   - Note: Secondary indexes store Record IDs, not Block IDs

6. **Update header**:
   - Increment `Header.RecordCount`
   - Increment `Header.NextRecordID`
   - Write header back to block 0

### Example Usage: Deleting a Record

1. **Find the record**: Use primary index to get Record ID → Block ID

2. **Mark as empty**:
   ```pascal
   block.Status := 0;  { Empty }
   { Write updated block back to .DAT }
   ```

3. **Update primary index**:
   - `Delete(idxTree, recordID)` - Remove Record ID from primary index

4. **Update secondary indexes**: Remove from all secondary indexes
   - `DeleteValue(nameTree, StringKey(username), recordID)`
   - `DeleteValue(emailTree, StringKey(email), recordID)`

5. **Update header**:
   - Decrement `Header.RecordCount`
   - Write header back to block 0

6. **Compaction**: Eventually run compaction to reclaim space

### Example Usage: Updating a Record

**Non-indexed field changes**:
- Simply overwrite the data in the existing block
- No index updates needed

**Indexed field changes** (e.g., username change):
1. **Delete old secondary index entry**: `DeleteValue(nameTree, StringKey(oldUsername), recordID)`
2. **Update the data block**: Write new data to existing block
3. **Insert new secondary index entry**: `Insert(nameTree, StringKey(newUsername), recordID)`
4. **Primary index unchanged**: Record ID stays the same, so primary index is not modified

**Moving a record to a new block** (during compaction):
1. **Write data to new block**: Copy record to new physical location
2. **Update primary index**: Change mapping from `recordID → oldBlockNum` to `recordID → newBlockNum`
3. **Mark old block empty**: Set old block `Status = 0`
4. **Secondary indexes unchanged**: They map to Record IDs, so no updates needed

## Transaction Protocol

The journal file provides crash recovery by recording operations before they are committed to the database. This ensures that partial writes due to power loss or crashes can be detected and completed.

### Write Operation Sequence

When updating, deleting, or adding records, follow this sequence:

1. **Append to journal**: Write a `TDBJournalEntry` to the journal file with the operation details
   - For Update: Operation=1, BlockID=target block, RecordID=record ID, Data=new data
   - For Delete: Operation=2, BlockID=target block, RecordID=record ID
   - For Add: Operation=3, BlockID=-1, RecordID=new ID, Data=new data

2. **Set pending flag**: Update `Header.JournalPending = True` in block 0 of .DAT file

3. **Flush journal**: Ensure journal is written to disk (fsync/flush)

4. **Perform database update**: Execute the actual operation on the .DAT file

5. **Update indexes**: Modify all affected indexes (.I?? files)

6. **Clear pending flag**: Set `Header.JournalPending = False` in block 0 of .DAT file

7. **Truncate journal**: Set journal file size to 0 bytes

**Multiple Operations**: For operations affecting multiple records (e.g., bulk updates), write all journal entries before setting the `JournalPending` flag. This creates a multi-operation transaction.

### Recovery on Database Open

When opening a database, check the `JournalPending` flag to determine if recovery is needed:

1. **Check flag**: Read `Header.JournalPending` from block 0 of .DAT file

2. **If false**: Open database normally, no recovery needed

3. **If true**: Recovery is required:
   - Open journal file (.JNL)
   - For each journal entry:
     - Read entry and verify checksum using CRC16
     - If checksum valid, replay operation:
       - **Operation 1 (Update)**: Write `Data` to block `BlockID` in .DAT file
       - **Operation 2 (Delete)**: Set block `BlockID` status to 0 (Empty)
       - **Operation 3 (Add)**: Find first empty block (or append), write `Data`
     - If checksum invalid, skip entry (corrupted)
   - Rebuild all indexes from .DAT file (safer than trusting partial index updates)
   - Set `Header.JournalPending = False` in block 0 of .DAT file
   - Truncate journal file to 0 bytes

**Index Rebuild**: After crash recovery, always rebuild all indexes to ensure consistency. This is safer than attempting to replay partial index updates.

## Database Helper Methods

The `DB` unit should provide high-level helper methods to encapsulate these operations:

### Database Operations

**`OpenDatabase(name: Str63; var db: TDatabase): Boolean`**
- Opens all database files (.INF, .DAT, .IDX, .I??)
- Loads metadata into memory
- Returns true on success

**`CloseDatabase(var db: TDatabase)`**
- Closes all open files
- Writes any cached metadata

**`CreateDatabase(name: Str63; blockSize: Word): Boolean`**
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

**`FindRecordByString(var db: TDatabase; fieldName: Str63; value: Str63; var data: array of Byte): Boolean`**
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

**`AddIndex(var db: TDatabase; fieldName: Str63; indexType: TDBIndexType): Boolean`**
- Creates new .I?? file
- Scans existing records to build index
- Updates header (increment `IndexCount`, add to `Indexes` array)
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

### Transaction Operations

**`BeginTransaction(var db: TDatabase)`**
- Sets `Header.JournalPending = True`
- Prepares journal file for writing
- All subsequent operations will be journaled

**`CommitTransaction(var db: TDatabase)`**
- Sets `Header.JournalPending = False`
- Truncates journal file to 0 bytes
- Finalizes all pending operations

**`RollbackTransaction(var db: TDatabase)`**
- Discards journal without applying
- Sets `Header.JournalPending = False`
- Truncates journal file to 0 bytes
- Use when aborting an operation

**`ReplayJournal(var db: TDatabase): Boolean`**
- Reads and validates all journal entries
- Applies each operation to database
- Rebuilds all indexes
- Returns true on success
- Called automatically during `OpenDatabase` if `JournalPending = True`

## Data Types

```pascal
type
  TDBIndexType = (itID, itString);

  TDBIndexInfo = record
    FieldName: Str63;
    IndexType: TDBIndexType;
    IndexNumber: Byte;
  end;

  TDBHeader = record
    Signature: array[0..7] of Char;     { 'RETRODB' + #0 }
    Version: Word;                       { Format version (1) }
    BlockSize: Word;                     { Size of each data block }
    RecordCount: LongInt;                { Total active records }
    NextRecordID: LongInt;               { Next available Record ID }
    LastCompacted: TBBSTimestamp;        { Timestamp of last compaction }
    JournalPending: Boolean;             { True if journal needs replay }
    IndexCount: Word;                    { Number of secondary indexes }
    Indexes: array[0..98] of TDBIndexInfo; { Secondary index definitions }
    { Padded to BlockSize with Reserved bytes }
  end;

  TDBData = record
    ID: LongInt;       { Record ID }
    Status: Byte;      { 0 = Empty, 1 = Active }
    Data: array[0..MAX_BLOCK_SIZE-6] of Byte;
  end;

  TDBJournalEntry = record
    Operation: Byte;  { 0 = None, 1 = Update, 2 = Delete, 3 = Add }
    BlockID: LongInt;
    RecordID: LongInt;
    Data: array[0..MAX_BLOCK_SIZE-1] of Byte;
    Checksum: Word;
  end;

  TDatabase = record
    Header: TDBHeader;
    DataFile: File;
    JournalFile: File;
    PrimaryIndex: TBTree;              { .IDX - RecordID → BlockID }
    SecondaryIndexes: array of TBTree; { .I?? - FieldValue → RecordID }
    IsOpen: Boolean;
  end;
```

## Performance Considerations

- **Primary index lookups**: O(log n) via B-Tree - fast
- **Secondary index lookups**: O(log n) + O(log n) = two B-Tree lookups (secondary → primary)
  - Trade-off: Slower reads for faster compaction and updates
- **Finding free blocks**: O(n) linear scan - slow without free list
- **Multiple indexes**: Each insert/update/delete must update primary + all secondary indexes
- **Hash collisions**: StringKey uses CRC16, so collisions are possible (1 in 65536)
  - Always verify string match after hash lookup
- **Journal overhead**: Each write operation requires:
  - One journal file append (fsync)
  - One header update (set JournalPending flag in block 0)
  - Actual database modification
  - Second header update (clear flag)
  - Journal truncate
- **Recovery time**: Proportional to number of journal entries and total records (for index rebuild)
- **Batch operations**: Use multi-entry transactions to amortize journal overhead across multiple operations
- **Compaction advantage**: With indirect indexing, only primary index needs updating when moving records
  - Secondary indexes are unchanged since Record IDs don't change

## Future Enhancements

1. **Free list management**: Bitmap or linked list of empty blocks for O(1) free block lookup
2. **Multi-operation transactions**: Group related operations into atomic units
3. **Record-level checksums**: Detect data corruption in .DAT file
4. **Compression**: For large text fields
5. **Variable-length records**: More space-efficient storage
6. **Index caching**: Keep frequently-used index nodes in memory
7. **Incremental index updates**: During recovery, replay index changes from journal instead of full rebuild
