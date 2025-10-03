# Custom Type Definitions

The 'BBSTypes' unit adds custom type declarations that are used throughout the code. All other units rely on the `BBSTypes` unit.

## Standard Types

RetroBBS expects the following standard data types:
- Integer (16-bit signed)
- LongInt (32-bit signed)
- Byte (8-bit unsigned)
- Word (16-bit unsigned)
- LongWord (32-bit unsigned)
- String (0-255 bytes in length)
- Boolean

**Note:** To ensure consistent sizes across compilers and modes, RetroBBS uses explicitly-sized type aliases (see below) rather than using these types directly.

## Explicitly-Sized Integer Types

To ensure consistent behavior across different compilers and compilation modes, RetroBBS defines explicitly-sized integer types:

| Name       | Definition | Size      | Range                          |
| ---------- | ---------- | --------- | ------------------------------ |
| TWord      | Word       | 16-bit    | 0 to 65535                     |
| TInt       | SmallInt   | 16-bit    | -32768 to 32767                |
| TLong      | LongInt    | 32-bit    | -2147483648 to 2147483647      |
| TLongWord  | LongWord   | 32-bit    | 0 to 4294967295                |

**Usage:** All code should use these types instead of `Word`, `Integer`, `LongInt`, or `LongWord` directly to ensure consistent record sizes and calculations across all target platforms.

## Custom Types

The following custom types are defined in the `BBSTypes` unit:

| Name           | Definition      | Notes                              |
| -------------- | --------------- | ---------------------------------- |
| Str255         | String[255]     | Used for long strings              |
| Str63          | String[63]      | Used for medium strings            |
| Str31          | String[31]      | Used for short string              |
| SHA1Hash       | String[41]      | Hex string of a SHA-1 hash         |
| TUserID        | TWord           | Unique user identifier (0-65535)   |
| TBBSTimestamp  | TLong           | Seconds since 1/1/1904 (Mac Epoch) |


## Record Types

The following record types are defined in the `BBSTypes` unit:

## Helper Functions

The following helper functions are defined in the `BBSTypes` unit:

- `UnixToMacEpoch(unixTime: TLong): TLong` - Converts a 1/1/1970 (UNIX) epoch timestamp to a 1/1/1904 (Mac) epoch timestamp.
- `MacToUnixEpoch(macTime: TLong): TLong` - Converts a 1/1/1904 (Mac) epoch timestamp to a 1/1/1970 (UNIX) epoch timestamp.