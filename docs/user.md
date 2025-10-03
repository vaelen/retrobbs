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

## User File

The User file is called `users.dat` and is used to store the list of all users. It is a new line delmited text file and access to it is sequential.

## User Related Functions

- FindUserByID(ID: UserID) : User
- FindUserByName(Name: Str63) : User
- AuthenticateUser(Name: Str63, Password: SHA1Hash) : Boolean
- SetUserPassword(ID: UserID, Password: Str63) : Boolean
- SaveUser(u: User)

**TODO: Document other user related functions here**

