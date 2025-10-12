# User Administration Utility - Implementation Tasks (Phases 1-3)

This document provides detailed, step-by-step tasks for implementing the first three phases of the `useradm` utility. These tasks are designed to be followed by an AI agent in sequence.

---

## Phase 1: Core Application Structure

### Task 1.1: Create Main Program File

**File:** `src/utils/useradm.pas`

**Actions:**

1. Create the file `src/utils/useradm.pas`
2. Add the program header:
   ```pascal
   program UserAdm;

   {
     User Administration Utility

     Full-screen text-based user management interface for RetroBBS.

     Copyright 2025, Andrew C. Young <andrew@vaelen.org>
     MIT License
   }
   ```
3. Add uses clause with all required units:
   ```pascal
   uses
     BBSTypes, User, Table, UI, ANSI, Colors, Lists, Keyboard, SysUtils;
   ```

### Task 1.2: Define Constants and Global Variables

**File:** `src/utils/useradm.pas`

**Actions:**

1. After the uses clause, add a `const` section with screen layout constants:
   ```pascal
   const
     { Screen layout constants }
     TABLE_TOP = 1;           { Top row of table }
     TABLE_LEFT = 1;          { Left column of table }
     STATUS_HEIGHT = 3;       { Height of status bar (including borders) }
   ```

2. Add a `var` section with global variables:
   ```pascal
   var
     { Screen and display }
     screen: TScreen;
     table: TTable;
     tableBox: TBox;
     statusBox: TBox;

     { State }
     running: Boolean;
     totalUsers: TInt;
     termWidth: TInt;
     termHeight: TInt;
   ```

### Task 1.3: Implement InitializeScreen Procedure

**File:** `src/utils/useradm.pas`

**Actions:**

1. Create a procedure to initialize the screen and terminal:
   ```pascal
   procedure InitializeScreen;
   begin
     { Get terminal dimensions }
     termWidth := 80;   { Default, will be updated if terminal size detection works }
     termHeight := 25;

     { Initialize ANSI }
     InitANSI;

     { Setup screen structure }
     screen.Output := @Output;
     screen.Width := termWidth;
     screen.Height := termHeight;
     screen.IsANSI := True;
     screen.IsColor := True;
     screen.ScreenType := stANSI;

     { Clear screen }
     ClearScreen;
   end;
   ```

### Task 1.4: Implement CalculateLayout Procedure

**File:** `src/utils/useradm.pas`

**Actions:**

1. Create a procedure to calculate box positions based on terminal size:
   ```pascal
   procedure CalculateLayout;
   var
     tableHeight: TInt;
   begin
     { Calculate table box dimensions }
     tableHeight := termHeight - STATUS_HEIGHT;

     tableBox.Row := TABLE_TOP;
     tableBox.Column := TABLE_LEFT;
     tableBox.Width := termWidth;
     tableBox.Height := tableHeight;

     { Calculate status bar box dimensions }
     statusBox.Row := tableHeight + 1;
     statusBox.Column := TABLE_LEFT;
     statusBox.Width := termWidth;
     statusBox.Height := STATUS_HEIGHT;
   end;
   ```

### Task 1.5: Implement Cleanup Procedure

**File:** `src/utils/useradm.pas`

**Actions:**

1. Create a cleanup procedure to free resources:
   ```pascal
   procedure Cleanup;
   begin
     { Free table resources }
     FreeTable(table);

     { Close user database }
     CloseUserDatabase;

     { Clear screen and reset cursor }
     ClearScreen;
     GotoXY(1, 1);
   end;
   ```

### Task 1.6: Implement Main Program Structure

**File:** `src/utils/useradm.pas`

**Actions:**

1. Create the main program block with initialization:
   ```pascal
   begin
     { Initialize }
     running := True;

     { Initialize screen }
     InitializeScreen;

     { Calculate layout }
     CalculateLayout;

     { Initialize user database }
     if not InitUserDatabase then
     begin
       WriteLn('Error: Could not initialize user database');
       Halt(1);
     end;

     { Get total user count }
     totalUsers := GetUserCount;

     { Main event loop - placeholder for now }
     { TODO: Implement in Phase 4 }

     { Cleanup }
     Cleanup;
   end.
   ```

### Task 1.7: Add GetUserCount Function to User Unit

**Note:** The User unit needs a function to get the total count of users.

**File:** Check if `src/user.pas` has a `GetUserCount` function. If not, add:

**Actions:**

1. Read `src/user.pas` to check if `GetUserCount` exists
2. If it doesn't exist, add to the interface section:
   ```pascal
   function GetUserCount: TInt;
   ```
3. Add implementation:
   ```pascal
   function GetUserCount: TInt;
   begin
     { Implementation depends on database structure }
     { Should query the database for total record count }
     { Placeholder: return 0 for now }
     GetUserCount := 0;
   end;
   ```

---

## Phase 2: User Table Display

### Task 2.1: Implement User Data Fetch Callback

**File:** `src/utils/useradm.pas`

**Actions:**

1. Add the fetch callback function before the main procedures:
   ```pascal
   function FetchUserData(startIndex: TInt; maxRows: TInt; var rows: TArrayList): Boolean;
   var
     i, count: TInt;
     user: TUser;
     row: PTableRow;
     cell: PTableCell;
     userID: TUserID;
   begin
     { Initialize result list }
     InitArrayList(rows, maxRows);

     { Fetch users starting at startIndex }
     count := 0;
     i := startIndex;

     { Iterate through users }
     while (count < maxRows) and (i < totalUsers) do
     begin
       { Get user by index - need to add GetUserByIndex to User unit }
       userID := i + 1;  { User IDs start at 1 }
       if FindUserByID(userID, user) then
       begin
         { Allocate row }
         New(row);
         row^.RecordID := user.ID;
         InitArrayList(row^.Cells, 5);

         { Add ID cell }
         New(cell);
         cell^ := FormatUserID(user.ID);
         AddArrayListItem(row^.Cells, cell);

         { Add Name cell }
         New(cell);
         cell^ := user.Name;
         AddArrayListItem(row^.Cells, cell);

         { Add Full Name cell }
         New(cell);
         cell^ := user.FullName;
         AddArrayListItem(row^.Cells, cell);

         { Add Email cell }
         New(cell);
         cell^ := user.Email;
         AddArrayListItem(row^.Cells, cell);

         { Add Location cell }
         New(cell);
         cell^ := user.Location;
         AddArrayListItem(row^.Cells, cell);

         { Add row to list }
         AddArrayListItem(rows, row);
         Inc(count);
       end;

       Inc(i);
     end;

     FetchUserData := True;
   end;
   ```

### Task 2.2: Implement FormatUserID Helper Function

**File:** `src/utils/useradm.pas`

**Actions:**

1. Add helper function to format User ID as 6-digit string:
   ```pascal
   function FormatUserID(id: TUserID): Str63;
   var
     s: String;
   begin
     Str(id:6, s);
     while Length(s) < 6 do
       s := '0' + s;
     FormatUserID := s;
   end;
   ```

### Task 2.3: Initialize Table in Main Program

**File:** `src/utils/useradm.pas`

**Actions:**

1. In the main program block, after getting totalUsers, add table initialization:
   ```pascal
   { Initialize table }
   InitTable(table, screen, tableBox);

   { Configure table appearance }
   table.BorderType := btSingle;
   table.BorderColor := MakeColor(cWhite, cBlack);
   table.HeaderColor := MakeColor(cBlack, cCyan);
   table.RowColor := MakeColor(cWhite, cBlack);
   table.AltRowColor := 0;  { No alternating colors }
   table.SelectedColor := MakeColor(cBlack, cWhite);
   ```

### Task 2.4: Add Table Columns

**File:** `src/utils/useradm.pas`

**Actions:**

1. After table appearance configuration, add column definitions:
   ```pascal
   { Define table columns with responsive hiding priorities }
   AddTableColumn(table, 'ID', 6, 8, aLeft, 0);           { Always show }
   AddTableColumn(table, 'Name', 10, 15, aLeft, 0);       { Always show }
   AddTableColumn(table, 'Full Name', 15, 25, aLeft, 2);  { Hide 2nd on narrow }
   AddTableColumn(table, 'Email', 15, 30, aLeft, 1);      { Hide 3rd on narrow }
   AddTableColumn(table, 'Location', 10, 20, aLeft, 3);   { Hide 1st on narrow }
   ```

### Task 2.5: Set Table Data Source and Draw

**File:** `src/utils/useradm.pas`

**Actions:**

1. After column definitions, set the data source and draw:
   ```pascal
   { Set data source }
   SetTableDataSource(table, @FetchUserData, totalUsers);

   { Draw table }
   DrawTable(table);
   ```

### Task 2.6: Add Table Title to DrawTable

**Note:** The table should display "Users" as the title in the top border.

**File:** Check `src/table.pas` to see if DrawTable supports a title parameter.

**Actions:**

1. Read `src/table.pas` to check DrawTable signature
2. If title is not supported, check if there's a `SetTableTitle` or similar procedure
3. If not, add to `src/utils/useradm.pas` a custom procedure to draw the title:
   ```pascal
   procedure DrawTableWithTitle;
   begin
     DrawTable(table);
     { TODO: Add title "Users" to top border - may need Table unit enhancement }
   end;
   ```

### Task 2.7: Verify User Unit Has Required Functions

**File:** `src/user.pas`

**Actions:**

1. Verify the User unit has these functions (add if missing):
   - `GetUserCount: TInt` - Returns total number of users
   - `GetUserByIndex(index: TInt; var user: TUser): Boolean` - Gets user at position index (0-based)

2. If these don't exist, note them as dependencies that need to be added to the User unit

---

## Phase 3: Status Bar

### Task 3.1: Implement DrawStatusBar Procedure

**File:** `src/utils/useradm.pas`

**Actions:**

1. Create procedure to draw the status bar:
   ```pascal
   procedure DrawStatusBar;
   var
     commandText: Str255;
     hasUsers: Boolean;
   begin
     { Check if there are any users }
     hasUsers := (totalUsers > 0);

     { Build command text based on state }
     if hasUsers then
       commandText := 'Ins-Add  Del-Delete  Enter-View  ↑/K-Prev  ↓/J-Next  /-Search  Esc/Q-Quit'
     else
       commandText := 'Ins-Add  Esc/Q-Quit';

     { Draw box around status text }
     DrawBox(screen, statusBox, btSingle, MakeColor(cWhite, cBlack));

     { Position cursor inside box and write text }
     GotoXY(statusBox.Column + 2, statusBox.Row + 1);
     WriteString(commandText);
   end;
   ```

### Task 3.2: Call DrawStatusBar in Main Program

**File:** `src/utils/useradm.pas`

**Actions:**

1. In the main program block, after drawing the table, add:
   ```pascal
   { Draw status bar }
   DrawStatusBar;
   ```

### Task 3.3: Test Build

**Actions:**

1. Update the Makefile to include useradm in the utils target
2. Check if there's already a utils target in the Makefile
3. Add or update the Makefile rule for useradm:
   ```makefile
   bin/utils/useradm: src/utils/useradm.pas
   	fpc -Mobjfpc -Sh -O2 -gl -Fu./src -FU./build -o$@ $<
   ```

### Task 3.4: Add Keyboard Wait and Test Display

**File:** `src/utils/useradm.pas`

**Actions:**

1. For testing purposes, add a simple keyboard wait in the main loop:
   ```pascal
   { Main event loop - minimal for Phase 3 testing }
   { Wait for any key press }
   WriteLn;
   WriteLn('Press any key to exit...');
   ReadKey;
   ```

### Task 3.5: Handle Empty Database Case

**File:** `src/utils/useradm.pas`

**Actions:**

1. Add logic to handle when there are no users in the database:
   ```pascal
   { After getting totalUsers, check if empty }
   if totalUsers = 0 then
   begin
     { Draw table with no data }
     InitTable(table, screen, tableBox);
     table.BorderType := btSingle;
     table.BorderColor := MakeColor(cWhite, cBlack);
     table.HeaderColor := MakeColor(cBlack, cCyan);
     table.RowColor := MakeColor(cWhite, cBlack);
     table.AltRowColor := 0;
     table.SelectedColor := MakeColor(cBlack, cWhite);

     { Add columns }
     AddTableColumn(table, 'ID', 6, 8, aLeft, 0);
     AddTableColumn(table, 'Name', 10, 15, aLeft, 0);
     AddTableColumn(table, 'Full Name', 15, 25, aLeft, 2);
     AddTableColumn(table, 'Email', 15, 30, aLeft, 1);
     AddTableColumn(table, 'Location', 10, 20, aLeft, 3);

     { Set data source with 0 records }
     SetTableDataSource(table, @FetchUserData, 0);
     DrawTable(table);
   end
   else
   begin
     { Normal initialization with data }
     { ... existing table setup code ... }
   end;
   ```

2. Alternatively, simplify by always initializing the table the same way regardless of totalUsers value

### Task 3.6: Verify Table Component Displays Count

**File:** Check `src/table.pas`

**Actions:**

1. Read the Table unit DrawTable implementation to verify it displays "N of T Users" or similar count
2. If the Table unit uses a generic counter format, check if it needs modification
3. The counter should appear in the bottom-right of the table border as: "N of T Users" where:
   - N = number of rows currently visible
   - T = totalUsers (TotalRecords in table)

### Task 3.7: Test Compilation

**Actions:**

1. Run `make utils` to compile useradm
2. Verify the binary is created at `bin/utils/useradm`
3. Fix any compilation errors:
   - Missing unit dependencies
   - Undefined functions
   - Type mismatches
   - Syntax errors

### Task 3.8: Create Test Users (if needed)

**Actions:**

1. Check if a test user database exists
2. If not, you may need to manually create test users using the User unit's AddUser function
3. Consider creating a small test program to populate the database:
   ```pascal
   program CreateTestUsers;
   uses User;
   begin
     InitUserDatabase;
     AddUser('sysop', 'password', 'System Operator', 'sysop@retrobbs.local', 'Console');
     AddUser('alice', 'password', 'Alice Johnson', 'alice@example.com', 'New York');
     AddUser('bob', 'password', 'Bob Smith', 'bob@example.com', 'Los Angeles');
     CloseUserDatabase;
   end.
   ```

### Task 3.9: Visual Verification Test

**Actions:**

1. Run `bin/utils/useradm`
2. Verify the display shows:
   - Table with borders and "Users" title at top
   - 5 column headers: ID, Name, Full Name, Email, Location
   - User data rows (if any users exist)
   - Proper column separator characters
   - "N of T Users" counter in bottom-right of table border
   - Status bar below table with command list
   - Proper border drawing characters
3. Test on different terminal sizes if possible (80x25, 40x25, etc.) to verify responsive column hiding

### Task 3.10: Document Phase 1-3 Completion

**Actions:**

1. Update the implementation status:
   - Phase 1: Core Application Structure ✓
   - Phase 2: User Table Display ✓
   - Phase 3: Status Bar ✓
2. Note any issues or deviations from the plan
3. List any missing User unit functions that need to be implemented:
   - GetUserCount
   - GetUserByIndex (or equivalent)

---

## Notes for the AI Agent

### Important Reminders

1. **File naming:** Use 8.3 filename format (`useradm.pas`, not `user_admin.pas`)
2. **Pascal syntax:** Standard Pascal only, no Object Pascal classes or OOP features
3. **Memory management:** Always free allocated memory (New/Dispose, InitArrayList/FreeArrayList)
4. **Error handling:** Check return values from database and table operations
5. **Build system:** Use Free Pascal compiler (`fpc`) with appropriate flags

### Expected Challenges

1. **User unit may be incomplete:** The GetUserCount and GetUserByIndex functions may not exist yet and need to be added
2. **Table unit title support:** The Table component may not support titles in borders and may need enhancement
3. **Keyboard unit:** May need to verify the Keyboard unit exists with ReadKey function
4. **Terminal size detection:** May default to 80x25 if terminal size detection isn't implemented

### Testing Strategy

After completing Phase 3:

1. Compile with `make utils`
2. Run `bin/utils/useradm`
3. Verify display matches the mockup in [docs/user.md](docs/user.md)
4. Test with empty database (0 users)
5. Test with small dataset (1-5 users)
6. Test with dataset larger than screen
7. Verify status bar shows appropriate commands

### Next Steps

After Phase 3 is complete:

- Phase 4 will add keyboard navigation (up/down/vi keys)
- Phase 5 will add dialogs (Edit, Add, Delete, Search, Exit)
- Phase 6 will add refresh and state management
- Phase 7 will add error handling and edge cases

---

## Success Criteria for Phases 1-3

- ✓ Program compiles without errors
- ✓ Program initializes screen and ANSI terminal
- ✓ Program initializes user database
- ✓ Table displays with proper borders and title
- ✓ Table shows 5 columns with correct headers
- ✓ Table loads and displays user data via callback
- ✓ Table shows user count in bottom-right border
- ✓ Status bar displays below table with command list
- ✓ Status bar shows different commands when database is empty
- ✓ Program cleans up resources on exit
- ✓ No memory leaks or segmentation faults