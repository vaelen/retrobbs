# User Management Library

The `User` unit manages user accounts and authentication.

## User Record

The `User` record contains the following fields:

| Name     | Type       | Description            |
| -------- | ---------- | ---------------------- |
| ID       | UserID     | Unique User Identifier |
| Name     | Str63      | Login Name or "Handle" |
| Password | SHA1Hash   | SHA-1 Hash of Password |
| FullName | Str63      | Real Name              |
| Email    | Str63      | Email Address          |
| Location | Str63      | Physical Location      |
| Access   | TWord       | Access Control Bitmask |

**Note:** The Access Control Bitmask provides 16 separate ACL "groups" that the user can belong to. These are, in turn, used elsewhere to control access to specific areas. The most significant bit is the Sysop bit.

**Note:** Passwords are stored as the SHA-1 hash of user's password plus a configurable salt string. The default salt string is `retro` but this should be changed.

## User Database

The User database uses the `DB` unit for storage. User data is stored in the following files:

- `users.dat` - Main database file containing user records
- `users.idx` - Primary index (by user ID)
- `users.i00` - Secondary index (by user name)
- `users.jnl` - Journal file for transaction support

Each user record is stored as a fixed-size 304-byte record in the database.

## Database Management Functions

### InitUserDatabase() : Boolean

Initializes the user database. Creates a new database if it doesn't exist, or opens an existing one. This function is called automatically by other functions when needed.

### CloseUserDatabase()

Closes the user database and releases resources.

## User Lookup Functions

### FindUserByID(id: TUserID; var user: TUser) : Boolean

Finds a user by their unique ID. Returns true if found, false otherwise.

### FindUserByName(name: Str63; var user: TUser) : Boolean

Finds a user by their login name (case-insensitive). Returns true if found, false otherwise.

## User Management Functions

### AddUser(name, password, fullName, email, location: Str63) : TUserID

Creates a new user account. Returns the new user ID on success, or 0 on failure (e.g., if username already exists).

### UpdateUserByID(id: TUserID; user: TUser) : Boolean

Updates an existing user record by ID. Returns true on success.

### UpdateUserByName(name: Str63; user: TUser) : Boolean

Updates an existing user record by name. Returns true on success.

### DeleteUserByID(id: TUserID) : Boolean

Deletes a user by ID. Returns true on success.

### DeleteUserByName(name: Str63) : Boolean

Deletes a user by name. Returns true on success.

## Authentication Functions

### AuthenticateUser(name: Str63; password: Str63) : Boolean

Authenticates a user with their username and password. Returns true if credentials are valid.

### SetUserPasswordByID(id: TUserID; password: Str63) : Boolean

Changes a user's password by ID. The password is automatically hashed with the salt. Returns true on success.

### SetUserPasswordByName(name: Str63; password: Str63) : Boolean

Changes a user's password by name. The password is automatically hashed with the salt. Returns true on success.

### HashPassword(password: Str63) : SHA1Hash

Hashes a password with the current salt. This is used internally by the authentication functions.

## Access Control Functions

### HasAccess(user: TUser; accessBit: TWord) : Boolean

Checks if a user has a specific access bit set. Returns true if the bit is set.

### IsSysop(user: TUser) : Boolean

Checks if a user has system operator (sysop) privileges. Returns true if the user is a sysop.

## Global Variables

### Salt : Str63

The salt string used for password hashing. Default value is 'retro' but should be changed for security.

