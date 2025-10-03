# Database Library

RetroBBS stores data in a variety of data files. To make it easier to work with and maintain these files, the `DB` unit defines a standard data file format and utility functions for working with it.

## Data File Format

RetroBBS data files are binary files that store fixed sized records. This allows for both random access of specific records and easy reuse of freed space when records are removed. To accomplish this, the data file is divided into equal size blocks.

**Note: Data files are not guaranteed to be readable by a RetroBBS instance running on a different operating system than the one that originally created the data file. This is especially true when moving between 16, 32, and 64 bit systems.**

### Files

Each database is actually comprised of a number of files. Let's look at the `Users` database as an example:
- USERS.INF - Info about the database structure
- USERS.DAT - The actual data is stored here
- USERS.IDX - List of indexes
- USERS.I00 - Index 00 - contains a B-Tree as defined by the `BTree` unit.

### Info File Layout

The `.INF` file contains a single record of type `TDBInfo` stored in fixed length binary format. This information is generally kept in memory while the program is running.

| Name          | Type       | Notes  |
| ------------- | ---------- | ------ |
| Name          | Str64      |        |
| BlockSize     | Integer    |        |
| LastCompacted | TTimestamp |        |

### Data Block Layout

The `.DAT` file contains a series of records of type `TDBData` stored in fixed length binary format. This data is queried on demand as needed by the program and not stored in memory.

| Name  | Type                          | Notes                         |
| ----- | ----------------------------- | ----------------------------- |
| ID    | LongInt                       | Unique                        |
| Empty | Boolean                       | If True, blcok can be reused  |
| Data  | array[0..BlockSize-9] of Byte |                               |

### Index List Layout

The `.IDX` file contains a series of records of type `TDBIndexInfo` stored in fixed length binary format. This information is generally kept in memory while the program is running.

| Name          | Type       | Notes  |
| ------------- | ---------- | ------------------------------------ |
| FieldName     | Str64      | The name of the field being indexed. |
| IndexType     | Byte       | 0 = ID, 1 = Str64                    |
| IndexNumber   | Byte       | Maps to one of the `I??` files.      |

### Index Layout

The `.I??` files contain a B-Tree as defined by the `BTree` unit. The `??` in the extension should be replaced by the `IndexNumber` value. For example, `USERS.I00` or `USERS.I01`. `ID` type indexes will use the ID value directly as the key for the B-Tree. `String` type indexes will use the `StringKey` method to generate a key for a given input string.

### Example Usage: Find a User by ID

At program start, the program reads the data in `.INF` and `.IDX` files into memory. This data doesn't normally change during runtime.

To find a User by their ID, the program looks through the `TBIndexInfo` records for a record with `FieldName` = `ID`. In this example, let's say that the `TDBIndexInfo` record looks like this: `{FieldName: "ID", IndexType: 0, IndexNumber: 0}`. Based on this information, the program then opens `USERS.I00` using the 'BTree unit and retrieves the list of users.

## Database Helper Methods

**TODO: Document helper methods here**