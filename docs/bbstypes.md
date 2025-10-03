# Custom Type Definitions

The 'BBSTypes' unit adds custom type declarations that are used throughout the code. All other units rely on the `BBSTypes` unit.

## Standard Types

RetroBBS expects the following standard data types:
- Integer (16-bit signed)
- LongInt (32-bit signed)
- Byte (8-bit unsigned)
- Word (16-bit unsigned)
- String (0-255 bytes in length)
- Boolean

(I'd like to use LongWord, but Turbo Pascal doesn't support it.)

## Custom Types

The following custom types are defined in the `BBSTypes` unit:

| Name      | Definition  | Notes                              |
| --------- | ----------- | ---------------------------------- |
| Str255    | String[255] | Used for long strings              |
| Str63     | String[63]  | Used for medium strings            |
| Str31     | String[31]  | Used for short string              |
| SHA1Hash  | String[41]  | Hex string of a SHA-1 hash         |
| UserID    | Word        | Unique user identifier             |
| Timestamp | LongInt     | Seconds since 1/1/1904 (Mac Epoch) |


## Record Types

The following record types are defined in the `BBSTypes` unit:

## Helper Functions

The following helper functions are defined in the `BBSTypes` unit:

- UnixToMacEpoch(LongInt) : LongInt - Converts a 1/1/1904 (Mac) epoch timestamp to a 1/1/1970 (UNIX) epoch timestamp.
- MacToUnixEpoch(LongInt) : LongInt - Converts a 1/1/1970 (UNIX) epoch timestamp to a 1/1/1904 (Mac) epoch timestamp.