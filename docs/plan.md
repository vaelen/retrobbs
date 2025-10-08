# User Administration Utility Implementation Plan

## Overview

The `useradm` utility is a full-screen text-based user management interface for RetroBBS. It allows the system operator to view, add, edit, delete, and search user accounts using an interactive table-based interface.

## Dependencies

- `User` unit - User management functions
- `Table` unit - Scrollable table component
- `UI` unit - Dialog boxes, borders, text alignment
- `ANSI` unit - Terminal control and display
- `Colors` unit - Color constants
- `Keyboard` unit - Keyboard input handling

## Implementation Phases

### Phase 1: Core Application Structure

1. **Main Program Setup** (`src/utils/useradm.pas`)
   - Initialize user database
   - Initialize ANSI/terminal
   - Set up screen layout (table area + status bar)
   - Main event loop
   - Cleanup on exit

2. **Screen Layout Constants**
   - Define table position and dimensions
   - Define status bar position
   - Calculate responsive heights based on terminal size

### Phase 2: User Table Display

1. **Table Configuration**
   - Define 5 columns: ID, Name, Full Name, Email, Location
   - Set column widths (with responsive hiding from Table unit)
   - Implement data callback function to load user records
   - Display border with "Users" title
   - Display "N of T Users" counter in bottom-right of border

2. **Data Loading Callback**
   - Query user database for record at given index
   - Format user data for table display
   - Return formatted row data
   - Handle database errors gracefully

3. **Row Selection & Scrolling**
   - Track currently selected row index
   - Highlight selected row
   - Implement scroll behavior (shift data when at edges)
   - Handle empty database state (no selection)

### Phase 3: Status Bar

1. **Command Display**
   - Draw bordered status bar below table
   - Display command list: "Ins-Add  Del-Delete  Enter-View  ↑/K-Prev  ↓/J-Next  /-Search  Esc/Q-Quit"
   - Update based on current state (e.g., disable commands when no records)

### Phase 4: Keyboard Navigation

1. **Arrow Key / VI Key Handling**
   - Up arrow / K - Previous record
   - Down arrow / J - Next record
   - Handle scrolling at boundaries
   - Prevent movement when no records exist

2. **Action Keys**
   - Insert - Add user dialog
   - Delete - Delete user dialog
   - Enter - View/Edit user dialog
   - / - Search dialog
   - Esc / Q - Exit confirmation

### Phase 5: Dialog Implementations

#### 5.1 Edit User Dialog

1. **Dialog Structure**
   - Create centered popup dialog (title: "Edit User")
   - Display read-only User ID field
   - Create editable text boxes for:
     - Name (max 63 chars)
     - Full Name (max 63 chars)
     - Email (max 63 chars)
     - Location (max 63 chars)
   - Display "Press Enter to Save or Esc to Cancel" footer
   - Implement Tab key cycling between fields
   - Track currently focused field

2. **Input Handling**
   - Load current user data into fields
   - Handle keyboard input for active field
   - Support basic text editing (insert, delete, backspace)
   - Validate input (no empty username)

3. **Save Confirmation**
   - Display "Apply changes to user?" dialog
   - "Press Enter to Confirm or Esc to Cancel"
   - On confirm: save record, close dialogs, refresh table
   - On cancel: return to edit dialog

#### 5.2 Add User Dialog

1. **Dialog Structure**
   - Same layout as Edit User dialog (title: "Add User")
   - Generate next User ID automatically (display read-only)
   - Empty text fields for data entry
   - Same input handling as Edit dialog

2. **Save Confirmation**
   - Display "Add user?" dialog
   - "Press Enter to Confirm or Esc to Cancel"
   - On confirm: create user, close dialogs, refresh table, select new record
   - On cancel: return to add dialog

3. **Error Handling**
   - Check for duplicate username
   - Display error message if username exists
   - Return to edit fields

#### 5.3 Delete User Dialog

1. **Confirmation Dialog**
   - Display "Delete User" dialog
   - Show all user fields (read-only) for verification
   - Display "Press Enter to Confirm or Esc to Cancel"
   - On confirm: delete user, close dialog, refresh table, adjust selection
   - On cancel: close dialog, return to table

2. **Post-Delete Selection**
   - If deleted row was last: select previous row
   - Otherwise: keep same index (now shows next user)
   - If no users remain: clear selection

#### 5.4 Search Dialog

1. **Search Dialog Structure**
   - Display centered "Search" dialog
   - Single text input box
   - Display "Press Enter to Search or Esc to Cancel"

2. **Search Logic**
   - Start search from record after currently selected
   - Case-insensitive substring match on: Name, Full Name, Email
   - Wrap around to beginning if not found
   - Stop at original position if no match found
   - Select and scroll to matching record

3. **Search Results**
   - On match: close dialog, select and display matching record
   - On no match: display "User not found" message, stay in dialog

#### 5.5 Exit Confirmation Dialog

1. **Exit Dialog**
   - Display "Exit the program?" dialog
   - "Press Enter to Exit or Esc to Cancel"
   - On confirm: cleanup and exit program
   - On cancel: close dialog, return to table

### Phase 6: Refresh & State Management

1. **Table Refresh Function**
   - Reload user count from database
   - Update table display
   - Update "N of T Users" counter
   - Maintain scroll position if possible
   - Adjust selection if current record deleted

2. **State Tracking**
   - Current selected row index
   - Current scroll offset (first visible row)
   - Total user count
   - Dialog stack (for nested dialogs)

### Phase 7: Error Handling & Edge Cases

1. **Database Errors**
   - Handle database initialization failure
   - Handle record read/write failures
   - Display error messages to user
   - Allow graceful recovery or exit

2. **Empty Database**
   - Disable navigation and edit/delete commands
   - Only allow Add and Quit commands
   - Display appropriate message

3. **Terminal Size Changes**
   - Handle terminal resize events
   - Recalculate layout
   - Adjust visible rows
   - Maintain selection if possible

## File Structure

```
src/utils/useradm.pas     - Main program
bin/utils/useradm         - Compiled binary (via Makefile)
```

## Testing Strategy

1. **Manual Testing Scenarios**
   - Empty database startup
   - Add first user
   - Add multiple users
   - Edit user fields
   - Delete users (middle, first, last)
   - Search (successful and unsuccessful)
   - Navigation with large dataset (scrolling)
   - Exit confirmation
   - All Esc/cancel paths

2. **Edge Cases**
   - Database with exactly 1 user
   - Database filling entire screen
   - Database larger than screen
   - Very long field values (truncation)
   - Duplicate username attempt
   - Terminal resize during operation

## Implementation Order

1. Main program structure and initialization
2. Basic table display (no interaction)
3. Navigation (up/down keys)
4. View/Edit dialog (read-only first)
5. Add text editing to dialogs
6. Save functionality
7. Add user dialog
8. Delete user dialog
9. Search dialog
10. Exit confirmation
11. Polish and error handling

## Success Criteria

- ✓ Displays user table with proper formatting
- ✓ All navigation keys work correctly
- ✓ Can add new users
- ✓ Can edit existing users
- ✓ Can delete users with confirmation
- ✓ Search finds users by name/fullname/email
- ✓ All dialogs display correctly
- ✓ No crashes or data corruption
- ✓ Handles empty database gracefully
- ✓ Exit confirmation works
- ✓ Compiles with Free Pascal on Linux