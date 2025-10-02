# User Management Library

The `User` unit manages user accounts and authentication.

## User Record

The `User` record contains the following fields:

| Name     | Type       | Description            |
| -------- | ---------- | ---------------------- |
| ID       | UserID     | Unique User Identifier |
| Name     | Str64      | Login Name or "Handle" |
| Password | SHA1Hash   | SHA-1 Hash of Password |
| FullName | Str64      | Real Name              |
| Email    | Str64      | Email Address          |
| Location | Str64      | Physical Location      |
| Access   | Word       | Access Control Bitmask |

**Note:** The Access Control Bitmask provides 16 separate ACL "groups" that the user can belong to. These are, in turn, used elsewhere to control access to specific areas. The most significant bit is the Sysop bit.

**Note:** Passwords are stored as the SHA-1 hash of user's password plus a configurable salt string. The default salt string is `retro` but this should be changed.

## User File

The User file is called `users.dat` and is used to store the list of all users. It is a new line delmited text file and access to it is sequential.

## User Related Functions

- FindUserByID(ID: UserID) : User
- FindUserByName(Name: Str64) : User
- AuthenticateUser(Name: Str64, Password: SHA1Hash) : Boolean
- SetUserPassword(ID: UserID, Password: Str64) : Boolean
- SaveUser(u: User)

**TODO: Document other user related functions here**

