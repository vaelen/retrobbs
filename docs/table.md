# Table Component

The `Table` component provides a scrollable, paginated table display for viewing tabular data. It is designed to work with large datasets by using a callback-basced data loading mechanism that only loads one screen of data at a time, minimizing memory usage.

## Design Philosophy

The Table component follows these principles:

1. **Minimal Memory Footprint** - Only loads visible data, not the entire dataset
2. **Decoupled from Storage** - Uses callbacks to fetch data, works with any data source
3. **Dynamic Sizing** - Adapts to terminal size and resizes columns appropriately
4. **Simple and Focused** - Handles display and navigation only; no editing, searching, or filtering

## Core Types

### TTableCell

A single cell value in the table.

```pascal
type
  TTableCell = Str63;  { Fixed-length string for cell content }
  PTableCell = ^TTableCell;
```

**Design Note:** Using `Str63` provides a good balance between flexibility and memory efficiency. Cells that contain longer values should be truncated by the caller before passing to the table.

### TTableRow

A single row in the table, containing an array of cells and metadata.

```pascal
type
  TTableRow = record
    RecordID: TLong;        { Unique identifier (e.g., database record ID) }
    Cells: TArrayList;      { List of PTableCell - one per column }
  end;
  PTableRow = ^TTableRow;
```

**Fields:**

- `RecordID` - Unique identifier for this row in the underlying dataset. Used for callbacks and selection tracking.
- `Cells` - ArrayList of cell values, one for each column. Must match the number of columns defined in the table.

### TTableColumn

Column definition including header text and display properties.

```pascal
type
  TTableColumn = record
    Title: Str31;           { Column header text }
    MinWidth: TInt;         { Minimum width in characters }
    MaxWidth: TInt;         { Maximum width (0 = unlimited) }
    Alignment: TAlignment;  { Left, Right, or Center alignment }
    Priority: TInt;         { Display priority (0 = always show, higher = hide first) }
  end;
  PTableColumn = ^TTableColumn;
```

**Fields:**

- `Title` - Text displayed in the column header
- `MinWidth` - Minimum column width in characters (for content, not including borders)
- `MaxWidth` - Maximum column width (0 = no maximum, takes proportional share of remaining space)
- `Alignment` - How cell content is aligned within the column
- `Priority` - Display priority for responsive hiding:
  - `0` = Always show (required column)
  - `1-9` = Optional columns, higher numbers are hidden first when space is limited

**Width Calculation with Responsive Hiding:**

1. Calculate available width: `Box.Width - 2 (borders)`
2. Start with all Priority 0 columns (always show)
3. Try adding columns in priority order (1, then 2, then 3, etc.)
4. For each priority level, add all columns at that level if they fit
5. Stop when adding the next priority level would exceed available width
6. Distribute remaining space among visible flexible columns

**Example:** User table with 5 columns on narrow terminal (40 chars wide):

```text
Priority 0: ID (6 chars) + Name (10 chars) = required
Priority 1: Email (15 chars)
Priority 2: Full Name (15 chars)
Priority 3: Location (10 chars)

40 chars available:
- Show ID + Name (16 + separators = 19) ✓
- Try adding Email (19 + 15 + sep = 35) ✓
- Try adding Full Name (35 + 15 + sep = 51) ✗ Too wide!
- Result: Show only ID, Name, Email

80 chars available:
- Show all columns ✓
```

This ensures the most important information is always visible while gracefully degrading on narrow terminals.

### TTableFetchProc

Callback function for fetching data to display.

```pascal
type
  TTableFetchProc = function(
    startIndex: TInt;       { Starting position in dataset (0-based) }
    maxRows: TInt;          { Maximum number of rows to return }
    var rows: TArrayList    { Output: ArrayList of PTableRow }
  ): Boolean;               { Returns True if data was fetched successfully }
```

**Parameters:**

- `startIndex` - The position in the full dataset to start fetching from (0-based index)
- `maxRows` - Maximum number of rows to fetch (typically the number of visible rows)
- `rows` - Output parameter; caller should populate this ArrayList with PTableRow pointers

**Returns:**

- `True` if data was successfully fetched
- `False` if an error occurred or no data is available

**Caller Responsibilities:**

- Initialize the `rows` ArrayList before adding items
- Allocate memory for each TTableRow and its Cells ArrayList
- Populate RecordID and Cells for each row
- Return empty list if startIndex is beyond the dataset
- The Table component will free the row data after use

**Example Implementation:**

```pascal
function FetchUserData(startIndex: TInt; maxRows: TInt; var rows: TArrayList): Boolean;
var
  db: TDatabase;
  user: TUser;
  row: PTableRow;
  cell: PTableCell;
  i, count: TInt;
begin
  InitArrayList(rows, maxRows);

  { Open database and seek to position }
  if not OpenDatabase(db, 'users.db') then
  begin
    FetchUserData := False;
    Exit;
  end;

  { Fetch records starting at startIndex }
  count := 0;
  i := startIndex;
  while (count < maxRows) and GetUserByIndex(db, i, user) do
  begin
    { Allocate row }
    New(row);
    row^.RecordID := user.ID;
    InitArrayList(row^.Cells, 5);

    { Add cells }
    New(cell); cell^ := FormatUserID(user.ID);
    AddArrayListItem(row^.Cells, cell);

    New(cell); cell^ := user.Name;
    AddArrayListItem(row^.Cells, cell);

    New(cell); cell^ := user.FullName;
    AddArrayListItem(row^.Cells, cell);

    New(cell); cell^ := user.Email;
    AddArrayListItem(row^.Cells, cell);

    New(cell); cell^ := user.Location;
    AddArrayListItem(row^.Cells, cell);

    AddArrayListItem(rows, row);

    Inc(count);
    Inc(i);
  end;

  CloseDatabase(db);
  FetchUserData := True;
end;
```

### TTable

The main table component structure.

```pascal
type
  TTable = record
    { Display properties }
    Screen: TScreen;              { Screen context from UI unit }
    Box: TBox;                    { Position and size of table }

    { Appearance }
    BorderType: TBorderType;      { Single or double line border }
    BorderColor: TColor;          { Color for borders and separators }
    HeaderColor: TColor;          { Color for header row }
    RowColor: TColor;             { Color for normal rows }
    AltRowColor: TColor;          { Color for alternating rows (0 = no alternation) }
    SelectedColor: TColor;        { Color for selected row }

    { Column definitions }
    Columns: TArrayList;          { List of PTableColumn }

    { Current data }
    Rows: TArrayList;             { List of PTableRow - current screen only }

    { Navigation state }
    TopIndex: TInt;               { Index in dataset of first visible row (0-based) }
    SelectedIndex: TInt;          { Index in dataset of selected row (0-based) }
    SelectedOffset: TInt;         { Offset of selected row within visible area }
    TotalRecords: TInt;           { Total records in dataset (-1 if unknown) }

    { Data source }
    FetchData: TTableFetchProc;   { Callback to fetch data }

    { Cached layout values }
    VisibleRows: TInt;            { Number of rows that fit in display area }
    VisibleColumns: TArrayList;   { List of indices into Columns for visible columns }
    ColumnWidths: array[0..31] of TInt;  { Calculated column widths (for visible columns only) }
    NeedsRedraw: Boolean;         { Flag indicating table needs to be redrawn }
  end;
```

**Fields:**

**Display Properties:**

- `Screen` - The TScreen context (output stream, dimensions, capabilities)
- `Box` - Position and size of the table on screen

**Appearance:**

- `BorderType` - Single or double line box borders
- `BorderColor` - Color for table borders and column separators
- `HeaderColor` - Background/foreground for header row
- `RowColor` - Background/foreground for normal data rows
- `AltRowColor` - Alternate row color for zebra striping (set to 0 to disable)
- `SelectedColor` - Background/foreground for selected row

**Column Definitions:**

- `Columns` - ArrayList of PTableColumn defining each column

**Current Data:**

- `Rows` - ArrayList of PTableRow containing currently visible data

**Navigation State:**

- `TopIndex` - Index in the full dataset of the first visible row (0-based)
- `SelectedIndex` - Index in the full dataset of the currently selected row (0-based)
- `SelectedOffset` - Position of selected row within visible area (0 = top row)
- `TotalRecords` - Total number of records in the dataset, or -1 if unknown

**Data Source:**

- `FetchData` - Callback function to fetch data when scrolling

**Cached Layout:**

- `VisibleRows` - Number of data rows that fit in the display area (calculated during draw)
- `VisibleColumns` - ArrayList of TInt containing indices into Columns array for columns that are currently visible based on terminal width and priority
- `ColumnWidths` - Calculated width for each visible column (calculated during draw)
- `NeedsRedraw` - Flag set when table needs to be redrawn

## Table Procedures and Functions

### Initialization and Cleanup

#### InitTable

Initialize a table structure.

```pascal
procedure InitTable(var table: TTable; screen: TScreen; box: TBox);
```

**Parameters:**

- `table` - The table structure to initialize
- `screen` - Screen context for drawing
- `box` - Position and size of the table

**Description:**

- Initializes all fields to default values
- Sets up empty Columns and Rows ArrayLists
- Sets default colors (white on black)
- Sets TopIndex and SelectedIndex to 0
- Sets TotalRecords to -1 (unknown)
- Sets NeedsRedraw to True

#### FreeTable

Free all memory associated with a table.

```pascal
procedure FreeTable(var table: TTable);
```

**Description:**

- Frees all column definitions
- Frees all row data (rows and cells)
- Frees the Columns and Rows ArrayLists
- Resets all fields to safe defaults

### Configuration

#### AddTableColumn

Add a column definition to the table.

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

**Parameters:**

- `table` - The table to add the column to
- `title` - Column header text
- `minWidth` - Minimum width in characters
- `maxWidth` - Maximum width (0 = unlimited)
- `alignment` - Text alignment (aLeft, aCenter, aRight)
- `priority` - Display priority (0 = always show, higher values hide first on narrow terminals)

**Description:**

- Creates a new TTableColumn with the given properties
- Adds it to the table's Columns list
- Sets NeedsRedraw flag

**Note:** Must be called before SetTableDataSource.

#### SetTableDataSource

Set the data source callback and total record count.

```pascal
procedure SetTableDataSource(
  var table: TTable;
  fetchProc: TTableFetchProc;
  totalRecords: TInt
);
```

**Parameters:**

- `table` - The table to configure
- `fetchProc` - Callback function to fetch data
- `totalRecords` - Total number of records in dataset (-1 if unknown)

**Description:**

- Assigns the fetch callback
- Stores total record count
- Clears any existing row data
- Performs initial data fetch for first screen
- Sets NeedsRedraw flag

### Display

#### DrawTable

Draw or redraw the entire table.

```pascal
procedure DrawTable(var table: TTable);
```

**Description:**

1. **Calculate Layout:**
   - Determine number of visible rows based on box height
   - Calculate column widths based on box width and column definitions

2. **Draw Border:**
   - Draw outer border around table
   - Include title in top border if provided

3. **Draw Header Row:**
   - Draw column titles with separators
   - Use TopCenter character for separator junctions with top border
   - Apply HeaderColor

4. **Draw Header Separator:**
   - Draw horizontal line between header and data rows
   - Use CenterLeft, Center, and CenterRight characters for junctions

5. **Draw Data Rows:**
   - For each visible row position:
     - Draw row data with column separators
     - Apply RowColor or AltRowColor (alternating)
     - Apply SelectedColor if this is the selected row
     - Truncate cell content to fit column width
     - Apply cell alignment (left/center/right)

6. **Draw Empty Rows:**
   - If fewer rows than visible area, draw empty rows
   - Maintains table structure

7. **Draw Footer:**
   - Draw status message in bottom border (e.g., "10 of 47 Users")
   - Include total record count if known

8. **Clear NeedsRedraw Flag**

**Layout Calculation Details:**

Visible rows calculation:

```text
VisibleRows = Box.Height - 4
  (4 = top border + header + separator + bottom border)
```

Column width calculation:

```text
1. Calculate available width:
   AvailableWidth = Box.Width - 2 (borders) - (ColumnCount - 1) (separators)

2. Calculate total minimum width:
   TotalMinWidth = Sum of all MinWidth values

3. If AvailableWidth < TotalMinWidth:
   - Use MinWidth for all columns
   - Content will be truncated

4. Else distribute extra space:
   ExtraSpace = AvailableWidth - TotalMinWidth
   FlexColumns = Count of columns with MaxWidth = 0

   For each column:
     If MaxWidth = 0:
       ColumnWidth = MinWidth + (ExtraSpace / FlexColumns)
     Else:
       ColumnWidth = Min(MinWidth + proportional share, MaxWidth)
```

### Navigation

#### TableScrollDown

Scroll down one row.

```pascal
procedure TableScrollDown(var table: TTable);
```

**Description:**

- Increments SelectedIndex (if not at end)
- Increments SelectedOffset
- If SelectedOffset exceeds visible area:
  - Increments TopIndex
  - Decrements SelectedOffset to keep selection visible
  - Fetches new data
- Sets NeedsRedraw flag

**Boundary Handling:**

- If at last record, does nothing
- If TotalRecords is known, enforces upper bound
- If TotalRecords is unknown, tries to fetch; stops when no data returned

#### TableScrollUp

Scroll up one row.

```pascal
procedure TableScrollUp(var table: TTable);
```

**Description:**

- Decrements SelectedIndex (if not at top)
- Decrements SelectedOffset
- If SelectedOffset becomes negative:
  - Decrements TopIndex
  - Sets SelectedOffset to 0
  - Fetches new data
- Sets NeedsRedraw flag

**Boundary Handling:**

- If at first record (index 0), does nothing

#### TablePageDown

Scroll down one page.

```pascal
procedure TablePageDown(var table: TTable);
```

**Description:**

- Advances SelectedIndex by VisibleRows
- Advances TopIndex by VisibleRows
- Keeps SelectedOffset constant
- Fetches new data
- Enforces boundaries
- Sets NeedsRedraw flag

#### TablePageUp

Scroll up one page.

```pascal
procedure TablePageUp(var table: TTable);
```

**Description:**

- Decrements SelectedIndex by VisibleRows
- Decrements TopIndex by VisibleRows
- Keeps SelectedOffset constant
- Fetches new data
- Enforces boundaries (stops at TopIndex = 0)
- Sets NeedsRedraw flag

#### TableGoToTop

Jump to first record.

```pascal
procedure TableGoToTop(var table: TTable);
```

**Description:**

- Sets TopIndex to 0
- Sets SelectedIndex to 0
- Sets SelectedOffset to 0
- Fetches data from beginning
- Sets NeedsRedraw flag

#### TableGoToBottom

Jump to last record.

```pascal
procedure TableGoToBottom(var table: TTable);
```

**Description:**

- If TotalRecords is known:
  - Sets SelectedIndex to TotalRecords - 1
  - Calculates TopIndex to show last page
  - Calculates SelectedOffset
- If TotalRecords is unknown:
  - Cannot jump to bottom
- Fetches data
- Sets NeedsRedraw flag

### Data Management

#### RefreshTable

Reload current page of data.

```pascal
procedure RefreshTable(var table: TTable);
```

**Description:**

- Frees existing row data
- Calls FetchData callback with current TopIndex
- Sets NeedsRedraw flag

**Use Cases:**

- After inserting a new record
- After deleting a record
- After updating a record
- After sorting or filtering changes (future enhancement)

#### GetSelectedRecordID

Get the RecordID of the currently selected row.

```pascal
function GetSelectedRecordID(var table: TTable): TLong;
```

**Returns:**

- RecordID of selected row
- -1 if no selection or no data

**Description:**

- Calculates which row in the Rows list is selected
- Returns that row's RecordID
- Used by caller to determine which record user has selected

#### SetSelectedRecordID

Set the selection to a specific RecordID.

```pascal
function SetSelectedRecordID(var table: TTable; recordID: TLong): Boolean;
```

**Parameters:**

- `table` - The table
- `recordID` - RecordID to select

**Returns:**

- True if record was found and selected
- False if record not found

**Description:**

- Searches current visible rows for matching RecordID
- If found, updates SelectedIndex and SelectedOffset
- If not found, does not change selection
- Sets NeedsRedraw flag if selection changed

**Use Case:**

- After inserting a new record, select it
- After updating a record, ensure it stays selected

## Drawing Algorithm Details

### Cell Rendering

For each cell to be drawn:

1. **Get cell value** from row data
2. **Truncate if necessary** to column width
3. **Apply alignment:**
   - Left: Text at left edge, padding on right
   - Right: Text at right edge, padding on left
   - Center: Equal padding on both sides
4. **Draw cell content** with appropriate color
5. **Draw column separator** (except after last column)

**Example:**

```text
Column width: 12
Cell value: "Alice Johnson"
Alignment: Left

Output: "Alice Johnso│"
         (truncated to 12 chars, left aligned)

Cell value: "Alice"
Alignment: Center

Output: "   Alice    │"
         (centered with padding)
```

### Row Coloring

Rows are colored based on:

1. **If row is selected:** Use SelectedColor
2. **Else if AltRowColor is set:** Alternate between RowColor and AltRowColor
3. **Else:** Use RowColor

Alternation is based on row position in dataset (SelectedIndex), not display position, so colors remain consistent as user scrolls.

### Border Drawing

The table uses the box drawing characters defined in the UI unit:

**Top border:**

```text
┌────────┬───────────┬──────────────────┐
```

**Header separator:**

```text
├────────┼───────────┼──────────────────┤
```

**Bottom border:**

```text
└────────┴───────────┴──────────────────┘
```

**Data rows:**

```text
│ 000001 │ sysop     │ System Operator  │
```

Characters used:

- TopLeft, TopCenter, TopRight
- CenterLeft, Center, CenterRight
- BottomLeft, BottomCenter, BottomRight
- Horizontal, Vertical

## Memory Management

### Memory Ownership

The table component follows these ownership rules:

**Table Owns:**

- Column definitions (PTableColumn)
- Current row data (PTableRow and PTableCell)

**Caller Owns:**

- The TTable structure itself
- The TScreen structure
- The fetch callback function

### Memory Lifecycle

**During FetchData callback:**

1. Caller allocates PTableRow for each row
2. Caller allocates TArrayList for Cells
3. Caller allocates PTableCell for each cell
4. Caller populates all values
5. Caller adds rows to output ArrayList

**After FetchData returns:**

1. Table takes ownership of all row/cell memory
2. Table displays the data
3. On next fetch or FreeTable, table frees all row/cell memory

### Memory Allocation Pattern

For a 10-row display with 5 columns:

```text
Memory allocated per screen:
  10 TTableRow structures  = 10 * sizeof(TTableRow)
  10 Cell ArrayLists       = 10 * ArrayList overhead
  50 TTableCell pointers   = 50 * sizeof(Pointer)
  50 TTableCell values     = 50 * 64 bytes = 3,200 bytes

Total: ~4-5 KB per screen of data
```

This scales linearly with visible rows, not with total dataset size.

## Usage Example

### Complete Example: User Table

```pascal
var
  screen: TScreen;
  table: TTable;
  box: TBox;

{ Setup screen }
screen.Output := @Output;
screen.Width := 80;
screen.Height := 25;
screen.IsANSI := True;
screen.IsColor := True;
screen.ScreenType := stANSI;

{ Setup table position }
box.Row := 1;
box.Column := 1;
box.Height := 22;
box.Width := 80;

{ Initialize table }
InitTable(table, screen, box);

{ Configure appearance }
table.BorderType := btSingle;
table.BorderColor := MakeColor(cWhite, cBlack);
table.HeaderColor := MakeColor(cBlack, cCyan);
table.RowColor := MakeColor(cWhite, cBlack);
table.AltRowColor := MakeColor(cWhite, cBlue);
table.SelectedColor := MakeColor(cBlack, cWhite);

{ Define columns with priorities }
AddTableColumn(table, 'ID', 6, 8, aLeft, 0);          { Always show }
AddTableColumn(table, 'Name', 10, 15, aLeft, 0);      { Always show }
AddTableColumn(table, 'Email', 15, 30, aLeft, 1);     { Hide 3rd on narrow }
AddTableColumn(table, 'Full Name', 15, 25, aLeft, 2); { Hide 2nd on narrow }
AddTableColumn(table, 'Location', 10, 20, aLeft, 3);  { Hide 1st on narrow }

{ Set data source }
SetTableDataSource(table, @FetchUserData, GetUserCount());

{ Initial draw }
DrawTable(table);

{ Main loop }
repeat
  key := ReadKey;
  case key of
    KEY_UP, 'k', 'K':
      begin
        TableScrollUp(table);
        if table.NeedsRedraw then
          DrawTable(table);
      end;

    KEY_DOWN, 'j', 'J':
      begin
        TableScrollDown(table);
        if table.NeedsRedraw then
          DrawTable(table);
      end;

    KEY_PGUP:
      begin
        TablePageUp(table);
        if table.NeedsRedraw then
          DrawTable(table);
      end;

    KEY_PGDN:
      begin
        TablePageDown(table);
        if table.NeedsRedraw then
          DrawTable(table);
      end;

    KEY_HOME:
      begin
        TableGoToTop(table);
        if table.NeedsRedraw then
          DrawTable(table);
      end;

    KEY_END:
      begin
        TableGoToBottom(table);
        if table.NeedsRedraw then
          DrawTable(table);
      end;

    KEY_ENTER:
      begin
        recordID := GetSelectedRecordID(table);
        { Do something with selected record }
      end;
  end;
until (key = KEY_ESC) or (key = 'q') or (key = 'Q');

{ Cleanup }
FreeTable(table);
```

## Future Enhancements

The following features are intentionally omitted from the initial implementation but may be added later:

### Sorting

- Select column header to sort by that column
- Arrow indicator showing sort column and direction
- Callback to re-fetch sorted data

### Filtering

- Text filter applied to one or more columns
- Callback to fetch filtered data
- Display filter status in footer

### Searching

- Incremental search by typing
- Jump to next/previous match
- Highlight matching text

### Editing

- In-place cell editing
- Callback to validate and save changes
- Mark modified rows

### Horizontal Scrolling

- Support for tables wider than terminal
- Scroll left/right to view additional columns
- Keep first column(s) frozen

### Column Resizing

- Interactive column width adjustment
- Save/restore column widths

### Multi-Select

- Select multiple rows with Space key
- Bulk operations on selected rows

### Copy to Clipboard

- Export visible data to CSV

## Implementation Notes

### Performance Considerations

- Only one screen of data is loaded at a time
- Column width calculation happens during draw (cached until next draw)
- No string formatting or allocation during navigation (only during draw)
- Redraw only when NeedsRedraw flag is set

### Terminal Compatibility

The table works with all screen types:

- ASCII: Uses +, -, | for borders
- ANSI: Uses CP437 box drawing characters
- VT100: Uses alternate character set

### Thread Safety

The table component is not thread-safe. All operations must be performed from a single thread.

### Error Handling

- If FetchData callback returns False, table displays empty
- If FetchData returns fewer rows than requested, treated as end of data
- If terminal is too narrow for MinWidth of all columns, content is truncated
- If box is too small to display even one row, table draws border only

## Testing Requirements

Implementation should include tests for:

1. **Basic operations:**
   - Initialize and free table
   - Add columns
   - Set data source

2. **Navigation:**
   - Scroll up/down within page
   - Scroll up/down across page boundaries
   - Page up/down
   - Go to top/bottom

3. **Edge cases:**
   - Empty dataset
   - Single row dataset
   - Fewer rows than visible area
   - Exactly visible rows
   - Many more rows than visible area
   - Unknown total record count

4. **Layout:**
   - Narrow terminal (minimum widths)
   - Wide terminal (distributed widths)
   - Mixed fixed and flexible columns
   - Very long cell content (truncation)

5. **Memory:**
   - No memory leaks after free
   - Proper cleanup on refresh
   - Multiple fetch/free cycles

## Dependencies

The Table component depends on:

- **BBSTypes** - Core type definitions (TInt, TLong, Str63, etc.)
- **Lists** - TArrayList for storing columns and rows
- **UI** - TScreen, TBox, TColor, TAlignment, box drawing functions
- **Colors** - Color definitions and functions
- **ANSI** - Terminal control (indirectly through UI)
