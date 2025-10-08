# Table Component Implementation Tasks

This document outlines the tasks required to implement the Table component as described in [table.md](table.md).

## Overview

The Table component is a scrollable, paginated table display for viewing tabular data. It uses a callback-based data loading mechanism to minimize memory usage by only loading one screen of data at a time.

## Phase 1: Core Type Definitions and Structure

### Task 1.1: Define TTableCell Type

**File:** `src/table.pas`

**Description:**
Define the TTableCell type and its pointer type.

**Implementation:**

```pascal
type
  TTableCell = Str63;
  PTableCell = ^TTableCell;
```

**Acceptance Criteria:**

- TTableCell is defined as Str63
- PTableCell pointer type is defined
- Code compiles without errors

**Dependencies:** BBSTypes unit

---

### Task 1.2: Define TTableRow Type

**File:** `src/table.pas`

**Description:**
Define the TTableRow record type containing a unique identifier and list of cells.

**Implementation:**

```pascal
type
  TTableRow = record
    RecordID: TLong;
    Cells: TArrayList;
  end;
  PTableRow = ^TTableRow;
```

**Acceptance Criteria:**

- TTableRow record has RecordID field (TLong)
- TTableRow record has Cells field (TArrayList)
- PTableRow pointer type is defined
- Code compiles without errors

**Dependencies:** BBSTypes, Lists units

---

### Task 1.3: Define TTableColumn Type

**File:** `src/table.pas`

**Description:**
Define the TTableColumn record type for column definitions.

**Implementation:**

```pascal
type
  TTableColumn = record
    Title: Str31;
    MinWidth: TInt;
    MaxWidth: TInt;
    Alignment: TAlignment;
    Priority: TInt;
  end;
  PTableColumn = ^TTableColumn;
```

**Acceptance Criteria:**

- TTableColumn has all required fields including Priority
- PTableColumn pointer type is defined
- Uses TAlignment from UI unit
- Priority field supports responsive column hiding (0 = always show, 1+ = optional)
- Code compiles without errors

**Dependencies:** BBSTypes, UI units

---

### Task 1.4: Define TTableFetchProc Type

**File:** `src/table.pas`

**Description:**
Define the callback function type for fetching data.

**Implementation:**

```pascal
type
  TTableFetchProc = function(
    startIndex: TInt;
    maxRows: TInt;
    var rows: TArrayList
  ): Boolean;
```

**Acceptance Criteria:**

- Function type matches specification
- Parameters are correctly typed
- Returns Boolean
- Code compiles without errors

**Dependencies:** BBSTypes, Lists units

---

### Task 1.5: Define TTable Type

**File:** `src/table.pas`

**Description:**
Define the main TTable record structure with all fields organized by category.

**Implementation:**

```pascal
type
  TTable = record
    { Display properties }
    Screen: TScreen;
    Box: TBox;

    { Appearance }
    BorderType: TBorderType;
    BorderColor: TColor;
    HeaderColor: TColor;
    RowColor: TColor;
    AltRowColor: TColor;
    SelectedColor: TColor;

    { Column definitions }
    Columns: TArrayList;

    { Current data }
    Rows: TArrayList;

    { Navigation state }
    TopIndex: TInt;
    SelectedIndex: TInt;
    SelectedOffset: TInt;
    TotalRecords: TInt;

    { Data source }
    FetchData: TTableFetchProc;

    { Cached layout values }
    VisibleRows: TInt;
    VisibleColumns: TArrayList;
    ColumnWidths: array[0..31] of TInt;
    NeedsRedraw: Boolean;
  end;
```

**Acceptance Criteria:**

- All fields are present and correctly typed
- Fields are organized into logical groups with comments
- VisibleColumns ArrayList tracks which columns are currently visible based on priority
- Code compiles without errors

**Dependencies:** BBSTypes, Lists, UI, Colors units

---

## Phase 2: Initialization and Cleanup

### Task 2.1: Implement InitTable

**File:** `src/table.pas`

**Description:**
Initialize a table structure with default values.

**Implementation Requirements:**

- Initialize Columns ArrayList (empty)
- Initialize Rows ArrayList (empty)
- Initialize VisibleColumns ArrayList (empty)
- Set Screen and Box from parameters
- Set default BorderType to btSingle
- Set default colors (white on black)
- Set TopIndex = 0
- Set SelectedIndex = 0
- Set SelectedOffset = 0
- Set TotalRecords = -1 (unknown)
- Set VisibleRows = 0
- Clear ColumnWidths array
- Set NeedsRedraw = True
- Set FetchData = nil

**Acceptance Criteria:**

- Procedure signature matches: `procedure InitTable(var table: TTable; screen: TScreen; box: TBox)`
- All fields are properly initialized
- No memory leaks
- Code compiles without errors

**Dependencies:** Task 1.5

**Test Cases:**

- Initialize table and verify all fields have correct default values
- Verify Columns and Rows ArrayLists are initialized

---

### Task 2.2: Implement FreeTable

**File:** `src/table.pas`

**Description:**
Free all memory associated with a table.

**Implementation Requirements:**

- Free all PTableColumn in Columns list
- Free all PTableRow in Rows list
  - For each row, free all PTableCell in row.Cells
  - Free row.Cells ArrayList
  - Free the row itself
- Free Columns ArrayList
- Free Rows ArrayList
- Free VisibleColumns ArrayList (contains integers, not pointers)
- Reset all pointer fields to nil
- Reset numeric fields to 0

**Acceptance Criteria:**

- Procedure signature matches: `procedure FreeTable(var table: TTable)`
- All allocated memory is freed
- No memory leaks (verify with test)
- No dangling pointers
- Code compiles without errors

**Dependencies:** Task 2.1

**Test Cases:**

- Create table, add columns, add rows, free table - verify no memory leaks
- Call FreeTable on empty table - should not crash
- Call FreeTable multiple times - should be safe

---

## Phase 3: Configuration

### Task 3.1: Implement AddTableColumn

**File:** `src/table.pas`

**Description:**
Add a column definition to the table.

**Procedure Signature:**

```pascal
procedure AddTableColumn(
  var table: TTable;
  title: Str31;
  minWidth: TInt;
  maxWidth: TInt;
  alignment: TAlignment;
  priority: TInt
);
```

**Implementation Requirements:**

- Allocate new TTableColumn
- Set Title, MinWidth, MaxWidth, Alignment, Priority from parameters
- Add column to Columns ArrayList
- Set NeedsRedraw = True

**Acceptance Criteria:**

- Procedure signature matches specification with priority parameter
- Column is added to Columns list with all fields set correctly
- Priority field is stored for responsive column hiding
- NeedsRedraw flag is set
- Code compiles without errors

**Dependencies:** Task 2.1

**Test Cases:**

- Add single column and verify it's in the list
- Add multiple columns and verify order
- Verify NeedsRedraw is set

---

### Task 3.2: Implement SetTableDataSource

**File:** `src/table.pas`

**Description:**
Set the data source callback and total record count, then fetch initial data.

**Implementation Requirements:**

- Assign fetchProc to table.FetchData
- Set table.TotalRecords = totalRecords
- Free any existing row data in table.Rows
- Call FetchData callback with startIndex=0, maxRows=calculated visible rows
- Set NeedsRedraw = True

**Acceptance Criteria:**

- Procedure signature matches specification
- FetchData callback is assigned
- TotalRecords is stored
- Initial data is fetched
- Old data is properly freed
- NeedsRedraw flag is set
- Code compiles without errors

**Dependencies:** Tasks 2.1, 2.2, 3.1

**Test Cases:**

- Set data source and verify callback is assigned
- Verify initial data fetch is called
- Change data source and verify old data is freed

---

## Phase 4: Layout Calculation Helper Functions

### Task 4.1: Implement CalculateVisibleRows

**File:** `src/table.pas` (internal helper)

**Description:**
Calculate how many data rows fit in the display area.

**Implementation Requirements:**

- Calculate: VisibleRows = Box.Height - 4
  - 4 = top border + header + separator + bottom border
- Return 0 if result is negative

**Acceptance Criteria:**

- Returns correct row count
- Handles edge cases (very small boxes)
- Code compiles without errors

**Dependencies:** Task 1.5

**Test Cases:**

- Box height 25 → returns 21
- Box height 10 → returns 6
- Box height 3 → returns 0 (too small)

---

### Task 4.2: Implement CalculateColumnWidths

**File:** `src/table.pas` (internal helper)

**Description:**
Calculate the width for each visible column based on terminal width, column constraints, and priority-based hiding.

**Implementation Requirements:**

Step 1: Determine Visible Columns (Responsive Hiding)

- Calculate available width: Box.Width - 2 (borders)
- Clear VisibleColumns ArrayList
- Add all Priority 0 columns (always show) to VisibleColumns
- For each priority level (1, 2, 3, etc.):
  - Try adding all columns at this priority level
  - Calculate total width needed (including separators)
  - If they fit: add to VisibleColumns, continue to next priority
  - If they don't fit: stop (don't add any columns from this or higher priorities)

Step 2: Calculate Widths for Visible Columns

- Calculate available width: Box.Width - 2 (borders) - (VisibleColumnCount - 1) (separators)
- Calculate total minimum width: sum of MinWidth for visible columns
- If available < total minimum: use MinWidth for all visible columns
- Else distribute extra space:
  - Count flexible visible columns (MaxWidth = 0)
  - Calculate extra space
  - For each visible column:
    - If MaxWidth = 0: MinWidth + (extraSpace / flexColumns)
    - Else: Min(MinWidth + proportional share, MaxWidth)
- Store results in table.ColumnWidths array (indexed by position in VisibleColumns)
- Update table.VisibleRows

**Acceptance Criteria:**

- Correctly implements priority-based responsive column hiding
- Priority 0 columns are always visible
- Higher priority columns are hidden first when space is tight
- Calculates widths correctly for visible columns only
- Handles narrow terminals gracefully
- Distributes extra space properly among visible columns
- Respects MaxWidth constraints
- Updates ColumnWidths array and VisibleColumns list
- Code compiles without errors

**Dependencies:** Tasks 1.5, 3.1

**Test Cases:**

- Terminal wider than minimum: verify extra space distributed among visible columns
- Terminal narrower than minimum: verify MinWidth used for visible columns
- Mixed flexible and fixed columns: verify correct distribution
- Single column: gets all available width
- Priority 0 columns: always visible regardless of terminal width
- Priority 1+ columns: hidden when terminal too narrow
- Multiple priority levels: correct hiding order (higher priorities hidden first)
- Very narrow terminal: only Priority 0 columns visible

---

## Phase 5: Cell and Row Rendering Helpers

### Task 5.1: Implement FormatCell

**File:** `src/table.pas` (internal helper)

**Description:**
Format a cell's text content with padding and alignment.

**Implementation Requirements:**

- Input: cell text, column width, alignment
- If text longer than width: truncate to width
- Apply alignment:
  - aLeft: text + spaces
  - aRight: spaces + text
  - aCenter: spaces + text + spaces (balanced)
- Return formatted string

**Acceptance Criteria:**

- Correctly truncates long text
- Applies left alignment properly
- Applies right alignment properly
- Applies center alignment properly (even distribution)
- Handles edge cases (empty text, width 0)
- Code compiles without errors

**Dependencies:** Task 1.1

**Test Cases:**

- Text "Hello", width 10, left → "Hello     "
- Text "Hello", width 10, right → "     Hello"
- Text "Hello", width 10, center → "  Hello   "
- Text "Hello World", width 5 → "Hello" (truncated)

---

### Task 5.2: Implement GetRowColor

**File:** `src/table.pas` (internal helper)

**Description:**
Determine the color to use for a given row.

**Implementation Requirements:**

- Input: table, row index in dataset
- If row index = SelectedIndex: return SelectedColor
- Else if AltRowColor is set (non-zero):
  - If row index is even: return RowColor
  - If row index is odd: return AltRowColor
- Else: return RowColor

**Acceptance Criteria:**

- Selected row uses SelectedColor
- Alternating colors work correctly
- Falls back to RowColor when no alternation
- Code compiles without errors

**Dependencies:** Task 1.5

**Test Cases:**

- Selected row returns SelectedColor
- Even row with alternation returns RowColor
- Odd row with alternation returns AltRowColor
- No alternation always returns RowColor

---

## Phase 6: Drawing Implementation

### Task 6.1: Implement DrawTableBorder

**File:** `src/table.pas` (internal helper)

**Description:**
Draw the outer border of the table.

**Implementation Requirements:**

- Use TBoxChars from UI unit based on table.Screen.ScreenType
- Draw top border: TopLeft + Horizontal + TopRight
- Draw side borders: Vertical on left and right
- Draw bottom border: BottomLeft + Horizontal + BottomRight
- Use table.BorderColor
- Handle VT100 character set switching if needed

**Acceptance Criteria:**

- Border is drawn correctly
- Uses appropriate character set for terminal type
- Applies correct color
- Code compiles without errors

**Dependencies:** Tasks 1.5, 4.2

**Test Cases:**

- Draw border on ASCII terminal
- Draw border on ANSI terminal
- Draw border on VT100 terminal
- Draw border on UTF8 terminal

---

### Task 6.2: Implement DrawTableHeader

**File:** `src/table.pas` (internal helper)

**Description:**
Draw the header row with column titles.

**Implementation Requirements:**

- Position cursor at header row (row 1 inside border)
- Apply HeaderColor
- For each visible column (iterate through VisibleColumns list):
  - Draw Vertical separator
  - Get column definition from Columns[VisibleColumns[i]]
  - Draw formatted column title (centered in column width)
- Draw final Vertical separator
- Draw header separator line below:
  - CenterLeft + Horizontal + Center (between visible columns) + CenterRight

**Acceptance Criteria:**

- Header titles are drawn
- Column separators are drawn with correct junction characters
- Header separator line is drawn correctly
- Applies HeaderColor
- Code compiles without errors

**Dependencies:** Tasks 4.2, 5.1, 6.1

**Test Cases:**
- Draw header with 5 columns
- Verify separator junctions use correct characters
- Verify titles are centered

---

### Task 6.3: Implement DrawTableRow
**File:** `src/table.pas` (internal helper)

**Description:**
Draw a single data row.

**Implementation Requirements:**
- Input: table, row data, row position, row index in dataset
- Calculate row color using GetRowColor
- Apply row color
- For each visible column (iterate through VisibleColumns list):
  - Draw Vertical separator
  - Get column index from VisibleColumns[i]
  - Get cell value from row.Cells[column index]
  - Format cell using FormatCell with column width and alignment
  - Draw formatted cell
- Draw final Vertical separator

**Acceptance Criteria:**
- Row is drawn with correct color
- Cells are formatted correctly
- Column separators are drawn
- Handles missing cells gracefully
- Only displays cells for visible columns
- Code compiles without errors

**Dependencies:** Tasks 4.2, 5.1, 5.2

**Test Cases:**
- Draw normal row
- Draw selected row (different color)
- Draw row with long cell values (truncation)
- Draw row with fewer cells than columns
- Draw row with some columns hidden (verify only visible columns shown)

---

### Task 6.4: Implement DrawTableEmptyRow
**File:** `src/table.pas` (internal helper)

**Description:**
Draw an empty row (when there are fewer data rows than visible rows).

**Implementation Requirements:**
- Input: table, row position
- Apply RowColor
- For each visible column (iterate through VisibleColumns list):
  - Draw Vertical separator
  - Get column index from VisibleColumns[i]
  - Draw spaces to fill column width (from ColumnWidths[column index])
- Draw final Vertical separator

**Acceptance Criteria:**
- Empty row maintains table structure
- Uses correct spacing for visible columns only
- Code compiles without errors

**Dependencies:** Task 4.2

**Test Cases:**
- Draw empty row in 5-column table
- Verify proper spacing
- Draw empty row with some columns hidden (verify only visible columns shown)

---

### Task 6.5: Implement DrawTableFooter
**File:** `src/table.pas` (internal helper)

**Description:**
Draw the bottom border with status message.

**Implementation Requirements:**
- Draw bottom border: BottomLeft + Horizontal + BottomRight
- If TotalRecords is known (>= 0):
  - Calculate message: "N of T Type" (e.g., "10 of 47 Users")
  - Draw message in bottom border (right-aligned before BottomRight)
  - Use BottomCenter characters where message interrupts Horizontal line

**Acceptance Criteria:**
- Bottom border is drawn
- Status message is displayed when TotalRecords is known
- Message is properly integrated into border
- Code compiles without errors

**Dependencies:** Task 6.1

**Test Cases:**
- Draw footer with known total (displays status)
- Draw footer with unknown total (no status)
- Status message fits in available space

---

### Task 6.6: Implement DrawTable
**File:** `src/table.pas`

**Description:**
Main procedure to draw or redraw the entire table.

**Implementation Requirements:**
1. Call CalculateColumnWidths to update layout
2. Call CalculateVisibleRows
3. Call DrawTableBorder
4. Call DrawTableHeader
5. For each visible row position:
   - If row data exists: call DrawTableRow
   - Else: call DrawTableEmptyRow
6. Call DrawTableFooter
7. Set NeedsRedraw = False

**Acceptance Criteria:**
- Procedure signature matches: `procedure DrawTable(var table: TTable)`
- Entire table is drawn correctly
- Layout is calculated before drawing
- NeedsRedraw flag is cleared
- Code compiles without errors

**Dependencies:** Tasks 6.1-6.5

**Test Cases:**
- Draw table with data
- Draw table with no data (empty)
- Draw table with fewer rows than visible area
- Draw table with more rows than visible area

---

## Phase 7: Navigation Implementation

### Task 7.1: Implement TableScrollDown
**File:** `src/table.pas`

**Description:**
Scroll down one row, fetching new data if needed.

**Implementation Requirements:**
- If at last record, do nothing
- Increment SelectedIndex
- Increment SelectedOffset
- If SelectedOffset >= VisibleRows:
  - Increment TopIndex
  - Decrement SelectedOffset
  - Call FetchData with new TopIndex
  - Free old row data
- Enforce boundaries using TotalRecords if known
- Set NeedsRedraw = True

**Acceptance Criteria:**
- Procedure signature matches: `procedure TableScrollDown(var table: TTable)`
- Scrolls down correctly within page
- Fetches new data when crossing page boundary
- Respects boundaries
- Sets NeedsRedraw flag
- Code compiles without errors

**Dependencies:** Tasks 3.2, 4.1, 6.6

**Test Cases:**
- Scroll down within page (no fetch)
- Scroll down crossing page boundary (fetch occurs)
- Scroll down at last record (no change)
- Scroll down with unknown total (tries fetch, stops at end)

---

### Task 7.2: Implement TableScrollUp
**File:** `src/table.pas`

**Description:**
Scroll up one row, fetching new data if needed.

**Implementation Requirements:**
- If at first record (index 0), do nothing
- Decrement SelectedIndex
- Decrement SelectedOffset
- If SelectedOffset < 0:
  - Decrement TopIndex
  - Set SelectedOffset = 0
  - Call FetchData with new TopIndex
  - Free old row data
- Set NeedsRedraw = True

**Acceptance Criteria:**
- Procedure signature matches: `procedure TableScrollUp(var table: TTable)`
- Scrolls up correctly within page
- Fetches new data when crossing page boundary
- Stops at first record
- Sets NeedsRedraw flag
- Code compiles without errors

**Dependencies:** Tasks 3.2, 4.1, 6.6

**Test Cases:**
- Scroll up within page (no fetch)
- Scroll up crossing page boundary (fetch occurs)
- Scroll up at first record (no change)

---

### Task 7.3: Implement TablePageDown
**File:** `src/table.pas`

**Description:**
Scroll down one page.

**Implementation Requirements:**
- Calculate page size = VisibleRows
- Add page size to SelectedIndex
- Add page size to TopIndex
- Keep SelectedOffset constant
- Enforce boundaries
- Call FetchData with new TopIndex
- Free old row data
- Set NeedsRedraw = True

**Acceptance Criteria:**
- Procedure signature matches: `procedure TablePageDown(var table: TTable)`
- Advances by full page
- Fetches new data
- Respects boundaries
- Sets NeedsRedraw flag
- Code compiles without errors

**Dependencies:** Tasks 3.2, 4.1, 7.1

**Test Cases:**
- Page down with full page available
- Page down near end (partial page)
- Page down at end (no change)

---

### Task 7.4: Implement TablePageUp
**File:** `src/table.pas`

**Description:**
Scroll up one page.

**Implementation Requirements:**
- Calculate page size = VisibleRows
- Subtract page size from SelectedIndex
- Subtract page size from TopIndex
- Keep SelectedOffset constant
- Enforce boundaries (don't go below 0)
- Call FetchData with new TopIndex
- Free old row data
- Set NeedsRedraw = True

**Acceptance Criteria:**
- Procedure signature matches: `procedure TablePageUp(var table: TTable)`
- Goes back by full page
- Fetches new data
- Stops at top
- Sets NeedsRedraw flag
- Code compiles without errors

**Dependencies:** Tasks 3.2, 4.1, 7.2

**Test Cases:**
- Page up with full page available
- Page up near beginning (partial page)
- Page up at beginning (no change)

---

### Task 7.5: Implement TableGoToTop
**File:** `src/table.pas`

**Description:**
Jump to the first record.

**Implementation Requirements:**
- Set TopIndex = 0
- Set SelectedIndex = 0
- Set SelectedOffset = 0
- Call FetchData from beginning
- Free old row data
- Set NeedsRedraw = True

**Acceptance Criteria:**
- Procedure signature matches: `procedure TableGoToTop(var table: TTable)`
- Jumps to first record
- Fetches data from beginning
- Sets NeedsRedraw flag
- Code compiles without errors

**Dependencies:** Tasks 3.2, 4.1

**Test Cases:**
- Go to top from middle of dataset
- Go to top when already at top

---

### Task 7.6: Implement TableGoToBottom
**File:** `src/table.pas`

**Description:**
Jump to the last record (if total is known).

**Implementation Requirements:**
- If TotalRecords < 0 (unknown), do nothing
- Set SelectedIndex = TotalRecords - 1
- Calculate TopIndex to show last page:
  - TopIndex = Max(0, TotalRecords - VisibleRows)
- Calculate SelectedOffset:
  - SelectedOffset = SelectedIndex - TopIndex
- Call FetchData from TopIndex
- Free old row data
- Set NeedsRedraw = True

**Acceptance Criteria:**
- Procedure signature matches: `procedure TableGoToBottom(var table: TTable)`
- Jumps to last record when total is known
- Does nothing when total is unknown
- Fetches data for last page
- Sets NeedsRedraw flag
- Code compiles without errors

**Dependencies:** Tasks 3.2, 4.1

**Test Cases:**
- Go to bottom with known total
- Go to bottom with unknown total (no change)
- Go to bottom when already at bottom

---

## Phase 8: Data Management

### Task 8.1: Implement RefreshTable
**File:** `src/table.pas`

**Description:**
Reload the current page of data.

**Implementation Requirements:**
- Free existing row data in table.Rows
- Call FetchData with current TopIndex
- Set NeedsRedraw = True

**Acceptance Criteria:**
- Procedure signature matches: `procedure RefreshTable(var table: TTable)`
- Frees old data
- Fetches fresh data at same position
- Sets NeedsRedraw flag
- Code compiles without errors

**Dependencies:** Tasks 2.2, 3.2

**Test Cases:**
- Refresh table and verify data is reloaded
- Verify old data is freed (no memory leak)

---

### Task 8.2: Implement GetSelectedRecordID
**File:** `src/table.pas`

**Description:**
Get the RecordID of the currently selected row.

**Implementation Requirements:**
- Calculate which row in Rows list is selected:
  - rowIndex = SelectedOffset
- If rowIndex is valid in Rows list:
  - Get row = Rows[rowIndex]
  - Return row.RecordID
- Else return -1

**Acceptance Criteria:**
- Function signature matches: `function GetSelectedRecordID(var table: TTable): TLong`
- Returns correct RecordID for selected row
- Returns -1 if no data or invalid selection
- Code compiles without errors

**Dependencies:** Tasks 1.2, 1.5

**Test Cases:**
- Get RecordID with valid selection
- Get RecordID with no data (returns -1)

---

### Task 8.3: Implement SetSelectedRecordID
**File:** `src/table.pas`

**Description:**
Set the selection to a specific RecordID.

**Implementation Requirements:**
- Search through current Rows for matching RecordID
- If found:
  - Calculate index in Rows list
  - Set SelectedOffset to that index
  - Set SelectedIndex = TopIndex + index
  - Set NeedsRedraw = True
  - Return True
- If not found:
  - Return False

**Acceptance Criteria:**
- Function signature matches: `function SetSelectedRecordID(var table: TTable; recordID: TLong): Boolean`
- Finds and selects matching record
- Returns True if found, False otherwise
- Sets NeedsRedraw when selection changes
- Code compiles without errors

**Dependencies:** Tasks 1.2, 1.5

**Test Cases:**
- Set selection to existing RecordID (returns True)
- Set selection to non-existent RecordID (returns False)
- Verify NeedsRedraw is set on success

---

## Phase 9: Testing

### Task 9.1: Create Test Data Generator
**File:** `src/tests/table/data.pas`

**Description:**
Create helper functions to generate test data for table tests.

**Implementation Requirements:**
- Function to create mock rows with sequential RecordIDs
- Function to populate cells with test data
- Callback function for TTableFetchProc that returns mock data

**Acceptance Criteria:**
- Can generate N rows of test data
- Test data has proper structure (RecordID, cells)
- Mock fetch callback works correctly
- Code compiles without errors

**Dependencies:** Tasks 1.1-1.4

---

### Task 9.2: Test Basic Operations
**File:** `src/tests/table/basic.pas`

**Description:**
Test initialization, configuration, and cleanup.

**Test Cases:**

1. InitTable: verify all fields initialized (including VisibleColumns)
2. AddTableColumn: add columns with priorities, verify in list
3. AddTableColumn: verify Priority field is stored correctly
4. SetTableDataSource: verify callback assigned, data fetched
5. FreeTable: verify no memory leaks (including VisibleColumns)

**Acceptance Criteria:**
- All tests pass
- Priority field is correctly stored in columns
- VisibleColumns ArrayList is initialized and freed
- No memory leaks detected
- Code compiles without errors

**Dependencies:** Tasks 2.1, 2.2, 3.1, 3.2, 9.1

---

### Task 9.3: Test Layout Calculation
**File:** `src/tests/table/layout.pas`

**Description:**
Test column width and row calculation, including responsive column hiding.

**Test Cases:**
1. CalculateVisibleRows: various box heights
2. CalculateColumnWidths: narrow terminal
3. CalculateColumnWidths: wide terminal
4. CalculateColumnWidths: mixed fixed/flexible columns
5. CalculateColumnWidths: single column
6. CalculateColumnWidths: many columns
7. Responsive hiding: all Priority 0 columns visible on narrow screen
8. Responsive hiding: Priority 1 columns hidden on very narrow screen
9. Responsive hiding: all columns visible on wide screen
10. Responsive hiding: verify VisibleColumns list populated correctly
11. Responsive hiding: mixed priorities with incremental hiding

**Acceptance Criteria:**
- All calculations are correct
- Responsive column hiding works as expected
- VisibleColumns list contains correct column indices
- Edge cases handled properly
- Code compiles without errors

**Dependencies:** Tasks 4.1, 4.2, 9.1

---

### Task 9.4: Test Navigation
**File:** `src/tests/table/nav.pas`

**Description:**
Test all navigation operations.

**Test Cases:**
1. ScrollDown: within page
2. ScrollDown: cross page boundary
3. ScrollDown: at end
4. ScrollUp: within page
5. ScrollUp: cross page boundary
6. ScrollUp: at beginning
7. PageDown: full page
8. PageDown: partial page at end
9. PageUp: full page
10. PageUp: partial page at beginning
11. GoToTop: from middle
12. GoToBottom: with known total
13. GoToBottom: with unknown total

**Acceptance Criteria:**
- All navigation works correctly
- Data fetching occurs when expected
- Boundaries are respected
- Code compiles without errors

**Dependencies:** Tasks 7.1-7.6, 9.1

---

### Task 9.5: Test Edge Cases
**File:** `src/tests/table/edge.pas`

**Description:**
Test edge cases and error conditions.

**Test Cases:**

1. Empty dataset (0 rows)
2. Single row dataset
3. Fewer rows than visible area
4. Exactly visible rows
5. Many more rows than visible area
6. Very long cell content (truncation)
7. Missing cells in row
8. Unknown total record count
9. Very small terminal (can't fit minimum widths)
10. Very small box (can't fit even one row)
11. All columns have Priority > 0 (all optional) - at least Priority 0 columns should show
12. Terminal too narrow to fit even Priority 0 columns - graceful degradation
13. Many columns with same priority - all should show/hide together

**Acceptance Criteria:**
- All edge cases handled gracefully
- No crashes or errors
- Reasonable fallback behavior for responsive hiding edge cases
- Code compiles without errors

**Dependencies:** Tasks 6.6, 7.1-7.6, 9.1

---

### Task 9.6: Test Memory Management
**File:** `src/tests/table/memory.pas`

**Description:**
Test memory allocation and deallocation.

**Test Cases:**
1. Create and free empty table
2. Create table, add columns, free
3. Create table, fetch data, free
4. Multiple fetch/free cycles
5. RefreshTable multiple times
6. SetDataSource twice (old data freed)

**Acceptance Criteria:**
- No memory leaks in any test
- All allocated memory is freed
- Multiple cycles work correctly
- Code compiles without errors

**Dependencies:** Tasks 2.1, 2.2, 3.2, 8.1, 9.1

---

### Task 9.7: Create Master Test Suite
**File:** `src/tests/table/all.pas`

**Description:**
Create test suite runner that executes all table tests.

**Implementation:**
- Run each test program
- Report pass/fail for each
- Exit with error code if any test fails

**Acceptance Criteria:**
- Runs all table tests
- Reports results clearly
- Returns appropriate exit code
- Code compiles without errors

**Dependencies:** Tasks 9.2-9.6

---

## Phase 10: Integration and Documentation

### Task 10.1: Update Makefile
**File:** `Makefile`

**Description:**
Add build targets for table unit and tests.

**Changes Required:**
- Add TABLE_UNIT variable
- Add table test source variables
- Add table test output variables
- Add table test build targets
- Add test-table target
- Add table to main test target

**Acceptance Criteria:**
- `make` compiles table unit
- `make test-table` builds and runs table tests
- `make test` includes table tests
- Code compiles without errors

**Dependencies:** All Phase 9 tasks

---

### Task 10.2: Update Documentation Index
**File:** `docs/index.md`

**Description:**
Mark Table unit as complete in documentation index.

**Changes Required:**
- Change Table row from `[ ]` to `[x]`

**Acceptance Criteria:**
- Documentation index is updated
- Table is marked as complete

**Dependencies:** All previous tasks

---

### Task 10.3: Create Table Demo Program
**File:** `src/demos/tabledmo.pas`

**Description:**
Create a demo program showing table component in action.

**Implementation:**
- Generate sample data (users, products, or similar)
- Create columns with mixed priorities to demonstrate responsive hiding
  - Example: ID (Priority 0), Name (Priority 0), Email (Priority 1), LastLogin (Priority 2)
- Display table with sample data
- Allow navigation with arrow keys
- Show selection with Enter key
- Allow terminal resize to demonstrate responsive column hiding
- Exit with Esc/Q

**Acceptance Criteria:**
- Demo compiles and runs
- Shows all major features including responsive column hiding
- Demonstrates priority-based hiding on narrow terminals
- User-friendly and instructive
- Code compiles without errors

**Dependencies:** All Phase 1-8 tasks

---

## Task Dependencies Summary

### Phase Dependencies
- Phase 2 depends on Phase 1
- Phase 3 depends on Phase 2
- Phase 4 depends on Phase 1
- Phase 5 depends on Phase 1
- Phase 6 depends on Phases 1, 4, 5
- Phase 7 depends on Phases 3, 4, 6
- Phase 8 depends on Phases 1, 2, 3
- Phase 9 depends on all previous phases
- Phase 10 depends on Phase 9

### Critical Path
1. Phase 1: Core types (foundation)
2. Phase 2: Init/cleanup (memory management)
3. Phase 3: Configuration (setup)
4. Phase 4: Layout calculation (preparation for drawing)
5. Phase 5: Rendering helpers (drawing utilities)
6. Phase 6: Drawing (visualization)
7. Phase 7: Navigation (user interaction)
8. Phase 8: Data management (advanced features)
9. Phase 9: Testing (quality assurance)
10. Phase 10: Integration (completion)

## Estimated Effort

- Phase 1: 2-3 hours
- Phase 2: 2-3 hours
- Phase 3: 1-2 hours
- Phase 4: 2-3 hours
- Phase 5: 2-3 hours
- Phase 6: 4-6 hours
- Phase 7: 4-5 hours
- Phase 8: 2-3 hours
- Phase 9: 6-8 hours
- Phase 10: 2-3 hours

**Total: 27-39 hours**

## Notes for Implementation

### Code Organization
- Keep all internal helpers as local procedures within the implementation section
- Use consistent naming: DrawTable* for drawing helpers, Calculate* for layout helpers
- Add comprehensive comments for complex algorithms
- Follow existing code style in other units

### Testing Strategy
- Write tests incrementally as you implement features
- Test each phase before moving to the next
- Focus on edge cases and boundary conditions
- Use valgrind or similar to detect memory leaks

### Error Handling
- Check for nil pointers before dereferencing
- Validate array indices before access
- Handle empty lists gracefully
- Provide sensible defaults for error conditions

### Performance
- Minimize string allocations in drawing code
- Cache layout calculations
- Only redraw when NeedsRedraw flag is set
- Reuse allocated memory where possible

### Responsive Column Hiding

- VisibleColumns ArrayList must be updated by CalculateColumnWidths
- Priority 0 columns always show (if they fit)
- Higher priority columns (1, 2, 3...) hide first on narrow terminals
- All columns at the same priority level show/hide together
- Drawing code must iterate through VisibleColumns, not all Columns
- Test responsive behavior with various terminal widths

### Compatibility
- Test on all terminal types (ASCII, ANSI, VT100, UTF8)
- Verify 8.3 filename compliance
- Ensure standard Pascal syntax (no OOP features)
- Test compilation with Free Pascal

## Success Criteria

The Table component implementation is complete when:

1. ✅ All type definitions compile without errors
2. ✅ All procedures and functions are implemented
3. ✅ All tests pass without errors
4. ✅ No memory leaks detected
5. ✅ Demo program runs successfully
6. ✅ Works with all terminal types
7. ✅ Documentation is complete and accurate
8. ✅ Makefile targets work correctly
9. ✅ Code follows project conventions
10. ✅ Integration with existing codebase is seamless
