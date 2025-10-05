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
| Access   | TWord      | Access Control Bitmask |

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

## Utilities

The `useradm` utility (found in `src/utils/useradm.pas`) can be used by the sysop to manage the user database. It displays a full-screen text-based UI and relies on both the `ANSI` and `UI` units.

When the `useradm` program opens, it displays a full screen scrollable table of existing users. The includes columns for ID, Name, Full Name, Email, and Location. The width of each column will adjust with the width of the screen. The table is surrounded by a border and the border includes a centered title at the top that says "Users". On the right hand side of the bottom border the text "N of T Users" is displayed where N is the number currently shown on screen and T is the total number of users in the database. At the bottom of the screen, below the table, is a status line, surounded by its own border, listing possible commands. 

The commands are:
- Ins - Add a Record
- Del - Delete a Record
- Enter - View a Record
- Up or K - Previous Record
- Down or J - Next Record
- / - Search for a Record
- Esc / Q - Quit

By default, the first row in the table will be selected and highlighted. Using the down arrow keys (or J) moves the selection to the next row if there is one. Pressing the up arrow key (or K) moves the selection to the previous row if there is one. When the last row on the screen is selected and the down arrow is pressed, if there are more records then the data within all the rows shifts up by one so that the last row is still selected, but now it contains the data for the next user and the first row now contains the data for the second user. The same thing happens when the first row is selected and the user presses the up arrow and there are previous rows to display. In this way the data can be scrolled through.

If there are no rows in the database, then no row is selected and only the "Add" and "Quit" actions can be used.

```
┌─────────────────────────────────────── Users ────────────────────────────────────────┐
│ ID     │ Name         │ Full Name              │ Email                │ Location     │
├────────┼──────────────┼────────────────────────┼──────────────────────┼──────────────┤
│ 000001 │ sysop        │ System Operator        │ sysop@retrobbs.local │ Console      │
│ 000002 │ alice        │ Alice Johnson          │ alice@example.com    │ New York     │
│ 000003 │ bob          │ Bob Smith              │ bob@example.com      │ Los Angeles  │
│ 000004 │ charlie      │ Charlie Brown          │ charlie@example.com  │ Chicago      │
│ 000005 │ diana        │ Diana Prince           │ diana@example.com    │ Seattle      │
│ 000006 │ eve          │ Eve Anderson           │ eve@example.com      │ Boston       │
│ 000007 │ frank        │ Frank Miller           │ frank@example.com    │ Austin       │
│ 000008 │ grace        │ Grace Hopper           │ grace@example.com    │ San Diego    │
│ 000009 │ henry        │ Henry Ford             │ henry@example.com    │ Detroit      │
│ 000010 │ iris         │ Iris West              │ iris@example.com     │ Portland     │
│        │              │                        │                      │              │
│        │              │                        │                      │              │
└────────┴──────────────┴────────────────────────┴──────────────────── 10 of 47 Users ─┘
┌──────────────────────────────────────────────────────────────────────────────────────┐
│ Ins-Add  Del-Delete  Enter-View  ↑/K-Prev  ↓/J-Next  /-Search  Esc/Q-Quit            │
└──────────────────────────────────────────────────────────────────────────────────────┘
```

If the Enter key is pressed while a row is highlighted, the User Information dialog will be displayed. This dialog will be a popup in the middle of the screen on top of the user list with the title `Edit User`. It will provide text boxes for editing all of the values in the User record except the User ID, which will be be displayed but will not be editable. The text `Press Enter to Save or Esc to Cancel` will be displayed below the input fields, centered to the form. The currently selected textbox will be highlighted and this is where any keyboard input from the user will go. When the form loads, the first textbox will be automatically selected. The Tab key can be used to cycle between the selected text boxes and the buttons. Pressing Esc at any time will close the dialog. Pressing Enter will display a confirmation dialog. This dialog will be a popup on top of the User Information dialog and will ask `Apply changes to user?` Below that it will say `Press Enter to Confirm or Esc to Cancel.` Pressing `Esc` at this point will dismiss the confirmation dialog and return the user to the User Information dialog. Pressing `Enter` will save the user record, close both the confirmation dialog and the user information dialog, and refresh the user list to display the changes that were made. Only the values which are editable as part of the form are changed when the record is saved.

Mockup of the Edit User dialog:
```
┌─────────────────────────────── Users ─────────────────────────────────┐
│ ID     │ Name      │ Full Name        │ Email           │ Location    │
├────────┼───────────┼──────────────────┼─────────────────┼─────────────┤
│ 000001 │ sysop     │ System Operator  │ sysop@retro...  │ Console     │
│ 000002 │ ali┌──────────────── Edit User ────────────────┐ New York    │
│ 000003 │ bob│                                           │ Los Angeles │
│ 000004 │ cha│  User ID: 000002                          │ Chicago     │
│ 000005 │ dia│                                           │ Seattle     │
│ 000006 │ eve│  Name:     [alice                       ] │ Boston      │
│ 000007 │ fra│                                           │ Austin      │
│ 000008 │ gra│  Full Name:[Alice Johnson               ] │ San Diego   │
│ 000009 │ hen│                                           │ Detroit     │
│ 000010 │ iri│  Email:    [alice@example.com           ] │ Portland    │
│        │    │                                           │             │
│        │    │  Location: [New York                    ] │             │
│        │    │                                           │             │
│        │    │   Press Enter to Save or Esc to Cancel    │             │
│        │    │                                           │             │
│        │    └───────────────────────────────────────────┘             │
│        │           │                  │                 │             │
└────────┴───────────┴──────────────────┴────────────── 10 of 47 Users ─┘
┌───────────────────────────────────────────────────────────────────────┐
│ Ins-Add  Del-Delete  Enter-View  ↑/K-Prev  ↓/J-Next  /-Search  Esc/Q  │
└───────────────────────────────────────────────────────────────────────┘
```

When Enter is pressed, a confirmation dialog appears:
```
┌─────────────────────────────── Users ─────────────────────────────────┐
│ ID     │ Name      │ Full Name        │ Email           │ Location    │
├────────┼───────────┼──────────────────┼─────────────────┼─────────────┤
│ 000001 │ sysop     │ System Operator  │ sysop@retro...  │ Console     │
│ 000002 │ ali┌──────────────── Edit User ────────────────┐ New York    │
│ 000003 │ bob│                                           │ Los Angeles │
│ 000004 │ cha│  User ID: 000002                          │ Chicago     │ 
│ 000005 │ dia│         ┌────────────────────────┐        │ Seattle     │
│ 000006 │ eve│  Name:  │ Apply changes to user? │      ] │ Boston      │ 
│ 000007 │ fra│         │                        │        │ Austin      │
│ 000008 │ gra│  Full Na│ Press Enter to Confirm │      ] │ San Diego   │ 
│ 000009 │ hen│         │    or Esc to Cancel    │        │ Detroit     │
│ 000010 │ iri│  Email: └────────────────────────┘      ] │ Portland    │
│        │    │                                           │             │
│        │    │  Location: [New York                    ] │             │
│        │    │                                           │             │
│        │    │   Press Enter to Save or Esc to Cancel    │             │
│        │    │                                           │             │
│        │    └───────────────────────────────────────────┘             │
│        │           │                  │                 │             │
└────────┴───────────┴──────────────────┴────────────── 10 of 47 Users ─┘
┌───────────────────────────────────────────────────────────────────────┐
│ Ins-Add  Del-Delete  Enter-View  ↑/K-Prev  ↓/J-Next  /-Search  Esc/Q  │
└───────────────────────────────────────────────────────────────────────┘
```

If the Ins key is pressed, the User Information dialog is displayed with the title `Add User`. Pressing Enter will display the same confirmation dialog, except this time it will say `Add user?` instead of `Apply changes to user?`. Pressing Enter at this point will insert a new user into the database, close both dialogs, update the user table, and select the newly added record - scrolling if needed.

Mockup of New User dialog:
```
┌─────────────────────────────── Users ─────────────────────────────────┐
│ ID     │ Name      │ Full Name        │ Email           │ Location    │
├────────┼───────────┼──────────────────┼─────────────────┼─────────────┤
│ 000001 │ sysop     │ System Operator  │ sysop@retro...  │ Console     │
│ 000002 │ ali┌───────────────── Add User ────────────────┐ New York    │
│ 000003 │ bob│                                           │ Los Angeles │
│ 000004 │ cha│  User ID: 000011                          │ Chicago     │
│ 000005 │ dia│                                           │ Seattle     │
│ 000006 │ eve│  Name:     [                            ] │ Boston      │
│ 000007 │ fra│                                           │ Austin      │
│ 000008 │ gra│  Full Name:[                            ] │ San Diego   │
│ 000009 │ hen│                                           │ Detroit     │
│ 000010 │ iri│  Email:    [                            ] │ Portland    │
│        │    │                                           │             │
│        │    │  Location: [                            ] │             │
│        │    │                                           │             │
│        │    │   Press Enter to Save or Esc to Cancel    │             │
│        │    │                                           │             │
│        │    └───────────────────────────────────────────┘             │
│        │           │                  │                 │             │
└────────┴───────────┴──────────────────┴────────────── 10 of 47 Users ─┘
┌───────────────────────────────────────────────────────────────────────┐
│ Ins-Add  Del-Delete  Enter-View  ↑/K-Prev  ↓/J-Next  /-Search  Esc/Q  │
└───────────────────────────────────────────────────────────────────────┘
```

When Enter is pressed, a confirmation dialog appears:
```
┌─────────────────────────────── Users ─────────────────────────────────┐
│ ID     │ Name      │ Full Name        │ Email           │ Location    │
├────────┼───────────┼──────────────────┼─────────────────┼─────────────┤
│ 000001 │ sysop     │ System Operator  │ sysop@retro...  │ Console     │
│ 000002 │ ali┌───────────────── Add User ────────────────┐ New York    │
│ 000003 │ bob│                                           │ Los Angeles │
│ 000004 │ cha│  User ID: 000011                          │ Chicago     │
│ 000005 │ dia│         ┌────────Add User?───────┐        │ Seattle     │
│ 000006 │ eve│  Name:  │ Press Enter to Confirm │      ] │ Boston      │
│ 000007 │ fra│         │    or Esc to Cancel    │        │ Austin      │
│ 000008 │ gra│  Full Na└────────────────────────┘      ] │ San Diego   │
│ 000009 │ hen│                                           │ Detroit     │
│ 000010 │ iri│  Email:    [ken@example.com             ] │ Portland    │
│        │    │                                           │             │
│        │    │  Location: [Tokyo                       ] │             │
│        │    │                                           │             │
│        │    │   Press Enter to Save or Esc to Cancel    │             │
│        │    │                                           │             │
│        │    └───────────────────────────────────────────┘             │
│        │           │                  │                 │             │
└────────┴───────────┴──────────────────┴────────────── 10 of 47 Users ─┘
┌───────────────────────────────────────────────────────────────────────┐
│ Ins-Add  Del-Delete  Enter-View  ↑/K-Prev  ↓/J-Next  /-Search  Esc/Q  │
└───────────────────────────────────────────────────────────────────────┘
```


If the Del key is pressed while a row is highlighted, a dialog will popup on top of the table asking for confirmation before deleting the user. It will also display the user's information so that the admin can be sure they are deleting the right record. Below the user's information the dialog will say `Press Enter to Confirm or Esc to Cancel.`

Mockup of Delete User confirmation dialog:
```
┌─────────────────────────────── Users ─────────────────────────────────┐
│ ID     │ Name      │ Full Name        │ Email           │ Location    │
├────────┼───────────┼──────────────────┼─────────────────┼─────────────┤
│ 000001 │ sysop     │ System Operator  │ sysop@retro...  │ Console     │
│ 000002 │ ┌──────────────── Delete User ─────────────────┐ New York    │
│ 000003 │ │                                              │ Los Angeles │
│ 000004 │ │  User ID:   000003                           │ Chicago     │
│ 000005 │ │  Name:      bob                              │ Seattle     │
│ 000006 │ │  Full Name: Bob Smith                        │ Boston      │
│ 000007 │ │  Email:     bob@example.com                  │ Austin      │
│ 000008 │ │  Location:  Los Angeles                      │ San Diego   │
│ 000009 │ │                                              │ Detroit     │
│ 000010 │ │    Press Enter to Confirm or Esc to Cancel   │ Portland    │
│        │ │                                              │             │
│        │ └──────────────────────────────────────────────┘             │
│        │           │                  │                 │             │
└────────┴───────────┴──────────────────┴────────────── 10 of 47 Users ─┘

┌───────────────────────────────────────────────────────────────────────┐
│ Ins-Add  Del-Delete  Enter-View  ↑/K-Prev  ↓/J-Next  /-Search  Esc/Q  │
└───────────────────────────────────────────────────────────────────────┘
```

If the `/` key is pressed, a `Search` dialog will open in the middle of the screen on top of the table. It will have a single textbox in it for the user to type a search string into. Pressing `Esc` will close the dialog without doing anything else. Pressing `Enter` will search for the first user after the currently selected user whose name, full name, or email contain the search string. If a user is found, it will be selected in the table, scrolling the table if needed. If a user is not found after the currently selected user, then the search will resume from first user and stop if the currently selected user is reached without finding a matching user.

Mockup of Search dialog:
```
┌─────────────────────────────── Users ─────────────────────────────────┐
│ ID     │ Name      │ Full Name        │ Email           │ Location    │
├────────┼───────────┼──────────────────┼─────────────────┼─────────────┤
│ 000001 │ sysop     │ System Operator  │ sysop@retro...  │ Console     │
│ 000002 │ alice     │ Alice Johnson    │ alice@examp...  │ New York    │
│ 000003 │ bob       │ B┌─────── Search ────────┐mple...  │ Los Angeles │
│ 000004 │ charlie   │ C│ [johnson            ] │le.c...  │ Chicago     │
│ 000005 │ diana     │ D│                       │.com     │ Seattle     │
│ 000006 │ eve       │ E│ Press Enter to Search │om       │ Boston      │
│ 000007 │ frank     │ F│    or Esc to Cancel   │e.c ...  │ Austin      │
│ 000008 │ grace     │ G└───────────────────────┘e.c ...  │ San Diego   │
│ 000009 │ henry     │ Henry Ford       │ henry@examp...  │ Detroit     │
│ 000010 │ iris      │ Iris West        │ iris@exampl...  │ Portland    │
│        │           │                  │                 │             │
│        │           │                  │                 │             │
└────────┴───────────┴──────────────────┴────────────── 10 of 47 Users ─┘
┌───────────────────────────────────────────────────────────────────────┐
│ Ins-Add  Del-Delete  Enter-View  ↑/K-Prev  ↓/J-Next  /-Search  Esc/Q  │
└───────────────────────────────────────────────────────────────────────┘
```

If the `Esc` key is pressed, a confirmation dialog will be displayed on top of the table that says `Exit the program?`. Below that it should say `Press Enter to Exit or Esc to Cancel`. Pressing Enter closes the program. Pressing Esc dismisses the dialog and returns to the user list.

Mockup of exit confirmation dialog:
```
┌─────────────────────────────── Users ─────────────────────────────────┐
│ ID     │ Name      │ Full Name        │ Email           │ Location    │
├────────┼───────────┼──────────────────┼─────────────────┼─────────────┤
│ 000001 │ sysop     │ System Operator  │ sysop@retro...  │ Console     │
│ 000002 │ alice     │ Alice Johnson    │ alice@exampl... │ New York    │
│ 000003 │ bob       │ B┌──────── Exit? ──────┐xample.... │ Los Angeles │
│ 000004 │ charlie   │ C│ Press Enter to Exit │ie@exam... │ Chicago     │
│ 000005 │ diana     │ D│   or Esc to Cancel  │@exampl... │ Seattle     │
│ 000006 │ eve       │ E└─────────────────────┘xample.... │ Boston      │
│ 000007 │ frank     │ Frank Miller     │ frank@exampl... │ Austin      │
│ 000008 │ grace     │ Grace Hopper     │ grace@exampl... │ San Diego   │
│ 000009 │ henry     │ Henry Ford       │ henry@exampl... │ Detroit     │
│ 000010 │ iris      │ Iris West        │ iris@example... │ Portland    │
│        │           │                  │                 │             │
│        │           │                  │                 │             │
└────────┴───────────┴──────────────────┴────────────── 10 of 47 Users ─┘
┌───────────────────────────────────────────────────────────────────────┐
│ Ins-Add  Del-Delete  Enter-View  ↑/K-Prev  ↓/J-Next  /-Search  Esc/Q  │
└───────────────────────────────────────────────────────────────────────┘
```