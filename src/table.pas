unit Table;

{
  Table Component

  Provides a scrollable, paginated table display for viewing tabular data.
  Uses callback-based data loading to minimize memory usage.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

interface

uses
  BBSTypes, Lists, UI, Colors;

type
  { TTableCell - A single cell value in the table }
  TTableCell = Str63;
  PTableCell = ^TTableCell;

  { TTableRow - A single row containing cells and metadata }
  TTableRow = record
    RecordID: TLong;        { Unique identifier (e.g., database record ID) }
    Cells: TArrayList;      { List of PTableCell - one per column }
  end;
  PTableRow = ^TTableRow;

  { TTableColumn - Column definition }
  TTableColumn = record
    Title: Str31;           { Column header text }
    MinWidth: TInt;         { Minimum width in characters }
    MaxWidth: TInt;         { Maximum width (0 = unlimited) }
    Alignment: TAlignment;  { Left, Right, or Center alignment }
    Priority: TInt;         { Display priority (0 = always show, higher = hide first) }
  end;
  PTableColumn = ^TTableColumn;

  { TTableFetchProc - Callback function for fetching data }
  TTableFetchProc = function(
    startIndex: TInt;       { Starting position in dataset (0-based) }
    maxRows: TInt;          { Maximum number of rows to return }
    var rows: TArrayList    { Output: ArrayList of PTableRow }
  ): Boolean;               { Returns True if data was fetched successfully }

  { TTable - Main table component structure }
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
    ColumnWidths: array[0..31] of TInt;  { Calculated column widths }
    NeedsRedraw: Boolean;         { Flag indicating table needs to be redrawn }
  end;

{ Initialization and Cleanup }
procedure InitTable(var table: TTable; screen: TScreen; box: TBox);
procedure FreeTable(var table: TTable);

{ Configuration }
procedure AddTableColumn(
  var table: TTable;
  title: Str31;
  minWidth: TInt;
  maxWidth: TInt;
  alignment: TAlignment;
  priority: TInt
);
procedure SetTableDataSource(
  var table: TTable;
  fetchProc: TTableFetchProc;
  totalRecords: TInt
);

{ Display }
procedure DrawTable(var table: TTable);

{ Navigation }
procedure TableScrollDown(var table: TTable);
procedure TableScrollUp(var table: TTable);
procedure TablePageDown(var table: TTable);
procedure TablePageUp(var table: TTable);
procedure TableGoToTop(var table: TTable);
procedure TableGoToBottom(var table: TTable);

{ Data Management }
procedure RefreshTable(var table: TTable);
function GetSelectedRecordID(var table: TTable): TLong;
function SetSelectedRecordID(var table: TTable; recordID: TLong): Boolean;

implementation

uses
  ANSI;

{ Screen drawing helpers }

procedure MoveCursor(var screen: TScreen; row, col: TInt);
begin
  CursorPosition(screen.Output^, row, col);
end;

procedure SetColor(var screen: TScreen; color: TColor);
begin
  if screen.IsColor then
    ANSI.SetColor(screen.Output^, color.FG, color.BG);
end;

procedure WriteText(var screen: TScreen; text: Str63);
begin
  Write(screen.Output^, text);
end;

{ Internal Helper Functions }

function CalculateVisibleRows(var table: TTable): TInt;
{
  Calculate how many data rows fit in the display area.
  Formula: Box.Height - 4
  (4 = top border + header + separator + bottom border)
}
var
  rows: TInt;
begin
  rows := table.Box.Height - 4;
  if rows < 0 then
    rows := 0;
  CalculateVisibleRows := rows;
end;

procedure CalculateColumnWidths(var table: TTable);
{
  Calculate column widths based on terminal width and priority-based hiding.

  Step 1: Determine Visible Columns (Responsive Hiding)
  - Add all Priority 0 columns (always show)
  - For each priority level (1, 2, 3, etc.):
    - Try adding all columns at this priority
    - If they fit: add to VisibleColumns, continue
    - If they don't fit: stop

  Step 2: Calculate Widths for Visible Columns
  - Distribute available width among visible columns
  - Respect MinWidth and MaxWidth constraints
}
var
  availWidth, totalMinWidth, extraSpace, flexCount: TInt;
  priority, currentPriority, i, j, colIdx, visIdx: TInt;
  col: PTableColumn;
  tempWidthNeeded, widthPerFlex, proportionalShare: TInt;
  maxPriority: TInt;
  tryColumns: TArrayList;
  canFit: Boolean;
begin
  { Clear previous visible columns }
  ClearArrayList(table.VisibleColumns);

  if table.Columns.Count = 0 then
    Exit;

  { Calculate available width }
  availWidth := table.Box.Width - 2; { Subtract borders }

  { Step 1: Determine Visible Columns based on Priority }

  { Find maximum priority }
  maxPriority := 0;
  for i := 0 to table.Columns.Count - 1 do
  begin
    col := PTableColumn(GetArrayListItem(table.Columns, i));
    if col^.Priority > maxPriority then
      maxPriority := col^.Priority;
  end;

  { Add columns by priority level }
  currentPriority := 0;
  while currentPriority <= maxPriority do
  begin
    { Create temporary list of columns to try }
    InitArrayList(tryColumns, 0);

    { Copy existing visible columns }
    for i := 0 to table.VisibleColumns.Count - 1 do
      AddArrayListItem(tryColumns, GetArrayListItem(table.VisibleColumns, i));

    { Add all columns at current priority level }
    for i := 0 to table.Columns.Count - 1 do
    begin
      col := PTableColumn(GetArrayListItem(table.Columns, i));
      if col^.Priority = currentPriority then
        AddArrayListItem(tryColumns, Pointer(PtrUInt(i)));
    end;

    { Calculate width needed for these columns }
    tempWidthNeeded := 0;
    for i := 0 to tryColumns.Count - 1 do
    begin
      colIdx := TInt(PtrUInt(GetArrayListItem(tryColumns, i)));
      col := PTableColumn(GetArrayListItem(table.Columns, colIdx));
      tempWidthNeeded := tempWidthNeeded + col^.MinWidth;
    end;
    { Add separators }
    if tryColumns.Count > 0 then
      tempWidthNeeded := tempWidthNeeded + (tryColumns.Count - 1);

    { Check if they fit }
    canFit := (tempWidthNeeded <= availWidth) or (currentPriority = 0);

    if canFit then
    begin
      { Accept these columns }
      ClearArrayList(table.VisibleColumns);
      for i := 0 to tryColumns.Count - 1 do
        AddArrayListItem(table.VisibleColumns, GetArrayListItem(tryColumns, i));
    end;

    FreeArrayList(tryColumns);

    { If didn't fit and not priority 0, stop }
    if not canFit then
      break;

    Inc(currentPriority);
  end;

  { Step 2: Calculate Widths for Visible Columns }

  if table.VisibleColumns.Count = 0 then
    Exit;

  { Recalculate available width with separators }
  availWidth := table.Box.Width - 2 - (table.VisibleColumns.Count - 1);

  { Calculate total minimum width }
  totalMinWidth := 0;
  for i := 0 to table.VisibleColumns.Count - 1 do
  begin
    colIdx := TInt(PtrUInt(GetArrayListItem(table.VisibleColumns, i)));
    col := PTableColumn(GetArrayListItem(table.Columns, colIdx));
    totalMinWidth := totalMinWidth + col^.MinWidth;
  end;

  if availWidth <= totalMinWidth then
  begin
    { Not enough space - use minimum widths }
    for i := 0 to table.VisibleColumns.Count - 1 do
    begin
      colIdx := TInt(PtrUInt(GetArrayListItem(table.VisibleColumns, i)));
      col := PTableColumn(GetArrayListItem(table.Columns, colIdx));
      table.ColumnWidths[i] := col^.MinWidth;
    end;
  end
  else
  begin
    { Extra space available - distribute it }
    extraSpace := availWidth - totalMinWidth;

    { Count flexible columns (MaxWidth = 0) }
    flexCount := 0;
    for i := 0 to table.VisibleColumns.Count - 1 do
    begin
      colIdx := TInt(PtrUInt(GetArrayListItem(table.VisibleColumns, i)));
      col := PTableColumn(GetArrayListItem(table.Columns, colIdx));
      if col^.MaxWidth = 0 then
        Inc(flexCount);
    end;

    if flexCount > 0 then
    begin
      { Distribute extra space among flexible columns }
      widthPerFlex := extraSpace div flexCount;

      for i := 0 to table.VisibleColumns.Count - 1 do
      begin
        colIdx := TInt(PtrUInt(GetArrayListItem(table.VisibleColumns, i)));
        col := PTableColumn(GetArrayListItem(table.Columns, colIdx));

        if col^.MaxWidth = 0 then
          table.ColumnWidths[i] := col^.MinWidth + widthPerFlex
        else
          table.ColumnWidths[i] := col^.MinWidth;
      end;
    end
    else
    begin
      { No flexible columns - distribute proportionally }
      for i := 0 to table.VisibleColumns.Count - 1 do
      begin
        colIdx := TInt(PtrUInt(GetArrayListItem(table.VisibleColumns, i)));
        col := PTableColumn(GetArrayListItem(table.Columns, colIdx));

        proportionalShare := (col^.MinWidth * extraSpace) div totalMinWidth;
        table.ColumnWidths[i] := col^.MinWidth + proportionalShare;

        { Respect MaxWidth if set }
        if (col^.MaxWidth > 0) and (table.ColumnWidths[i] > col^.MaxWidth) then
          table.ColumnWidths[i] := col^.MaxWidth;
      end;
    end;
  end;
end;

{ Phase 5: Cell and Row Rendering Helpers }

function FormatCell(cellText: TTableCell; width: TInt; alignment: TAlignment): Str63;
{
  Format a cell's text content with padding and alignment.
}
var
  i, padLeft, padRight, textLen: TInt;
  formatted: Str63;
begin
  textLen := Length(cellText);

  { Truncate if necessary }
  if textLen > width then
  begin
    formatted := Copy(cellText, 1, width);
    FormatCell := formatted;
    Exit;
  end;

  { Apply alignment }
  case alignment of
    aLeft:
      begin
        formatted := cellText;
        for i := textLen + 1 to width do
          formatted := formatted + ' ';
      end;

    aRight:
      begin
        formatted := '';
        for i := 1 to width - textLen do
          formatted := formatted + ' ';
        formatted := formatted + cellText;
      end;

    aCenter:
      begin
        padLeft := (width - textLen) div 2;
        padRight := width - textLen - padLeft;

        formatted := '';
        for i := 1 to padLeft do
          formatted := formatted + ' ';
        formatted := formatted + cellText;
        for i := 1 to padRight do
          formatted := formatted + ' ';
      end;
  end;

  FormatCell := formatted;
end;

function GetRowColor(var table: TTable; rowIndex: TInt): TColor;
{
  Determine the color to use for a given row.
}
begin
  { Selected row uses SelectedColor }
  if rowIndex = table.SelectedIndex then
  begin
    GetRowColor := table.SelectedColor;
    Exit;
  end;

  { Alternating colors if AltRowColor is set }
  if (table.AltRowColor.FG <> 0) or (table.AltRowColor.BG <> 0) then
  begin
    if (rowIndex mod 2) = 0 then
      GetRowColor := table.RowColor
    else
      GetRowColor := table.AltRowColor;
  end
  else
  begin
    { No alternation }
    GetRowColor := table.RowColor;
  end;
end;

{ Phase 6: Drawing Implementation }

procedure DrawTableBorder(var table: TTable);
{
  Draw the outer border of the table.
}
var
  chars: TBoxChars;
  i, row, col, currentCol: TInt;
begin
  { Get appropriate box characters for terminal type }
  chars := UI.GetBoxChars(table.Screen.ScreenType, table.BorderType);

  { Enable box drawing mode }
  UI.EnableBoxDrawing(table.Screen);

  { Draw top border with column junctions }
  MoveCursor(table.Screen, table.Box.Row, table.Box.Column);
  SetColor(table.Screen, table.BorderColor);
  UI.WriteBoxChar(table.Screen, chars.TopLeft);

  currentCol := table.Box.Column + 1;
  for i := 0 to table.VisibleColumns.Count - 1 do
  begin
    { Draw horizontal line for this column }
    for col := 1 to table.ColumnWidths[i] do
      UI.WriteBoxChar(table.Screen, chars.Horizontal);
    currentCol := currentCol + table.ColumnWidths[i];

    { Draw junction or right corner }
    if i < table.VisibleColumns.Count - 1 then
    begin
      UI.WriteBoxChar(table.Screen, chars.TopCenter);
      Inc(currentCol);
    end
    else
      UI.WriteBoxChar(table.Screen, chars.TopRight);
  end;

  { Draw side borders }
  for row := 1 to table.Box.Height - 2 do
  begin
    MoveCursor(table.Screen, table.Box.Row + row, table.Box.Column);
    UI.WriteBoxChar(table.Screen, chars.Vertical);
    MoveCursor(table.Screen, table.Box.Row + row, table.Box.Column + table.Box.Width - 1);
    UI.WriteBoxChar(table.Screen, chars.Vertical);
  end;

  { Draw bottom border with column junctions }
  MoveCursor(table.Screen, table.Box.Row + table.Box.Height - 1, table.Box.Column);
  UI.WriteBoxChar(table.Screen, chars.BottomLeft);

  currentCol := table.Box.Column + 1;
  for i := 0 to table.VisibleColumns.Count - 1 do
  begin
    { Draw horizontal line for this column }
    for col := 1 to table.ColumnWidths[i] do
      UI.WriteBoxChar(table.Screen, chars.Horizontal);
    currentCol := currentCol + table.ColumnWidths[i];

    { Draw junction or right corner }
    if i < table.VisibleColumns.Count - 1 then
    begin
      UI.WriteBoxChar(table.Screen, chars.BottomCenter);
      Inc(currentCol);
    end
    else
      UI.WriteBoxChar(table.Screen, chars.BottomRight);
  end;

  { Disable box drawing mode }
  UI.DisableBoxDrawing(table.Screen);
end;

procedure DrawTableHeader(var table: TTable);
{
  Draw the header row with column titles.
}
var
  chars: TBoxChars;
  i, col, colIdx, currentCol: TInt;
  column: PTableColumn;
  formatted: Str63;
begin
  chars := UI.GetBoxChars(table.Screen.ScreenType, table.BorderType);

  { Enable box drawing mode }
  UI.EnableBoxDrawing(table.Screen);

  { Position at header row }
  MoveCursor(table.Screen, table.Box.Row + 1, table.Box.Column + 1);
  SetColor(table.Screen, table.HeaderColor);

  { Draw column headers }
  currentCol := table.Box.Column + 1;
  for i := 0 to table.VisibleColumns.Count - 1 do
  begin
    colIdx := TInt(PtrUInt(GetArrayListItem(table.VisibleColumns, i)));
    column := PTableColumn(GetArrayListItem(table.Columns, colIdx));

    { Draw separator before column (except first) }
    if i > 0 then
    begin
      MoveCursor(table.Screen, table.Box.Row + 1, currentCol);
      SetColor(table.Screen, table.BorderColor);
      UI.WriteBoxChar(table.Screen, chars.Vertical);
      Inc(currentCol);
    end;

    { Draw column title (centered) }
    formatted := FormatCell(column^.Title, table.ColumnWidths[i], aCenter);
    MoveCursor(table.Screen, table.Box.Row + 1, currentCol);
    SetColor(table.Screen, table.HeaderColor);
    WriteText(table.Screen, formatted);
    currentCol := currentCol + table.ColumnWidths[i];
  end;

  { Draw header separator line }
  MoveCursor(table.Screen, table.Box.Row + 2, table.Box.Column);
  SetColor(table.Screen, table.BorderColor);
  UI.WriteBoxChar(table.Screen, chars.CenterLeft);

  currentCol := table.Box.Column + 1;
  for i := 0 to table.VisibleColumns.Count - 1 do
  begin
    { Draw separator junction (except first) }
    if i > 0 then
    begin
      MoveCursor(table.Screen, table.Box.Row + 2, currentCol);
      UI.WriteBoxChar(table.Screen, chars.Center);
      Inc(currentCol);
    end;

    { Draw horizontal line }
    for col := 1 to table.ColumnWidths[i] do
      UI.WriteBoxChar(table.Screen, chars.Horizontal);
    currentCol := currentCol + table.ColumnWidths[i];
  end;

  MoveCursor(table.Screen, table.Box.Row + 2, table.Box.Column + table.Box.Width - 1);
  UI.WriteBoxChar(table.Screen, chars.CenterRight);

  { Disable box drawing mode }
  UI.DisableBoxDrawing(table.Screen);
end;

procedure DrawTableRow(var table: TTable; row: PTableRow; rowPosition: TInt; rowIndex: TInt);
{
  Draw a single data row.
}
var
  chars: TBoxChars;
  i, colIdx, currentCol: TInt;
  column: PTableColumn;
  cell: PTableCell;
  cellText: TTableCell;
  formatted: Str63;
  rowColor: TColor;
begin
  chars := UI.GetBoxChars(table.Screen.ScreenType, table.BorderType);
  rowColor := GetRowColor(table, rowIndex);

  { Enable box drawing mode }
  UI.EnableBoxDrawing(table.Screen);

  { Position at row }
  MoveCursor(table.Screen, table.Box.Row + rowPosition, table.Box.Column + 1);

  { Draw cells }
  currentCol := table.Box.Column + 1;
  for i := 0 to table.VisibleColumns.Count - 1 do
  begin
    colIdx := TInt(PtrUInt(GetArrayListItem(table.VisibleColumns, i)));
    column := PTableColumn(GetArrayListItem(table.Columns, colIdx));

    { Draw separator before column (except first) }
    if i > 0 then
    begin
      MoveCursor(table.Screen, table.Box.Row + rowPosition, currentCol);
      SetColor(table.Screen, table.BorderColor);
      UI.WriteBoxChar(table.Screen, chars.Vertical);
      Inc(currentCol);
    end;

    { Get cell value }
    if colIdx < row^.Cells.Count then
    begin
      cell := PTableCell(GetArrayListItem(row^.Cells, colIdx));
      if cell <> nil then
        cellText := cell^
      else
        cellText := '';
    end
    else
      cellText := '';

    { Format and draw cell }
    formatted := FormatCell(cellText, table.ColumnWidths[i], column^.Alignment);
    MoveCursor(table.Screen, table.Box.Row + rowPosition, currentCol);
    SetColor(table.Screen, rowColor);
    WriteText(table.Screen, formatted);
    currentCol := currentCol + table.ColumnWidths[i];
  end;

  { Disable box drawing mode }
  UI.DisableBoxDrawing(table.Screen);
end;

procedure DrawTableEmptyRow(var table: TTable; rowPosition: TInt);
{
  Draw an empty row (when there are fewer data rows than visible rows).
}
var
  chars: TBoxChars;
  i, col, colIdx, currentCol: TInt;
begin
  chars := UI.GetBoxChars(table.Screen.ScreenType, table.BorderType);

  { Enable box drawing mode }
  UI.EnableBoxDrawing(table.Screen);

  { Position at row }
  MoveCursor(table.Screen, table.Box.Row + rowPosition, table.Box.Column + 1);
  SetColor(table.Screen, table.RowColor);

  { Draw empty cells }
  currentCol := table.Box.Column + 1;
  for i := 0 to table.VisibleColumns.Count - 1 do
  begin
    colIdx := TInt(PtrUInt(GetArrayListItem(table.VisibleColumns, i)));

    { Draw separator before column (except first) }
    if i > 0 then
    begin
      MoveCursor(table.Screen, table.Box.Row + rowPosition, currentCol);
      SetColor(table.Screen, table.BorderColor);
      UI.WriteBoxChar(table.Screen, chars.Vertical);
      Inc(currentCol);
    end;

    { Draw spaces }
    MoveCursor(table.Screen, table.Box.Row + rowPosition, currentCol);
    SetColor(table.Screen, table.RowColor);
    for col := 1 to table.ColumnWidths[i] do
      WriteText(table.Screen, ' ');
    currentCol := currentCol + table.ColumnWidths[i];
  end;

  { Disable box drawing mode }
  UI.DisableBoxDrawing(table.Screen);
end;

procedure DrawTableFooter(var table: TTable);
{
  Draw the bottom border with status message.
}
var
  chars: TBoxChars;
  i, row: TInt;
  statusMsg: Str63;
begin
  chars := UI.GetBoxChars(table.Screen.ScreenType, table.BorderType);
  row := table.Box.Row + table.Box.Height - 1;

  { Enable box drawing mode }
  UI.EnableBoxDrawing(table.Screen);

  { Draw bottom border }
  MoveCursor(table.Screen, row, table.Box.Column);
  SetColor(table.Screen, table.BorderColor);
  UI.WriteBoxChar(table.Screen, chars.BottomLeft);
  for i := 1 to table.Box.Width - 2 do
    UI.WriteBoxChar(table.Screen, chars.Horizontal);
  UI.WriteBoxChar(table.Screen, chars.BottomRight);

  { Disable box drawing mode }
  UI.DisableBoxDrawing(table.Screen);

  { TODO: Add status message if TotalRecords is known }
  { This will be implemented later to show "N of T Records" }
end;

{ Initialization and Cleanup }

procedure InitTable(var table: TTable; screen: TScreen; box: TBox);
begin
  { Display properties }
  table.Screen := screen;
  table.Box := box;

  { Appearance }
  table.BorderType := btSingle;
  table.BorderColor := pWhiteOnBlack;
  table.HeaderColor := pWhiteOnBlack;
  table.RowColor := pWhiteOnBlack;
  table.AltRowColor.FG := 0;
  table.AltRowColor.BG := 0;
  table.SelectedColor := pBlackOnBWhite;

  { Column definitions }
  InitArrayList(table.Columns, 0);

  { Current data }
  InitArrayList(table.Rows, 0);

  { Navigation state }
  table.TopIndex := 0;
  table.SelectedIndex := 0;
  table.SelectedOffset := 0;
  table.TotalRecords := -1;

  { Data source }
  table.FetchData := nil;

  { Cached layout values }
  table.VisibleRows := 0;
  InitArrayList(table.VisibleColumns, 0);
  FillChar(table.ColumnWidths, SizeOf(table.ColumnWidths), 0);
  table.NeedsRedraw := True;
end;

procedure FreeTable(var table: TTable);
var
  i, j: TInt;
  col: PTableColumn;
  row: PTableRow;
  cell: PTableCell;
begin
  { Free all columns }
  for i := 0 to table.Columns.Count - 1 do
  begin
    col := PTableColumn(GetArrayListItem(table.Columns, i));
    if col <> nil then
      Dispose(col);
  end;
  FreeArrayList(table.Columns);

  { Free all rows }
  for i := 0 to table.Rows.Count - 1 do
  begin
    row := PTableRow(GetArrayListItem(table.Rows, i));
    if row <> nil then
    begin
      { Free all cells in this row }
      for j := 0 to row^.Cells.Count - 1 do
      begin
        cell := PTableCell(GetArrayListItem(row^.Cells, j));
        if cell <> nil then
          Dispose(cell);
      end;
      FreeArrayList(row^.Cells);
      Dispose(row);
    end;
  end;
  FreeArrayList(table.Rows);

  { Free VisibleColumns }
  FreeArrayList(table.VisibleColumns);

  { Reset fields }
  table.FetchData := nil;
  table.TopIndex := 0;
  table.SelectedIndex := 0;
  table.SelectedOffset := 0;
  table.TotalRecords := -1;
  table.VisibleRows := 0;
  table.NeedsRedraw := False;
end;

{ Configuration }

procedure AddTableColumn(
  var table: TTable;
  title: Str31;
  minWidth: TInt;
  maxWidth: TInt;
  alignment: TAlignment;
  priority: TInt
);
var
  col: PTableColumn;
begin
  New(col);
  col^.Title := title;
  col^.MinWidth := minWidth;
  col^.MaxWidth := maxWidth;
  col^.Alignment := alignment;
  col^.Priority := priority;
  AddArrayListItem(table.Columns, col);
  table.NeedsRedraw := True;
end;

procedure SetTableDataSource(
  var table: TTable;
  fetchProc: TTableFetchProc;
  totalRecords: TInt
);
var
  i, j: TInt;
  row: PTableRow;
  cell: PTableCell;
begin
  { Assign callback and total }
  table.FetchData := fetchProc;
  table.TotalRecords := totalRecords;

  { Free existing row data }
  for i := 0 to table.Rows.Count - 1 do
  begin
    row := PTableRow(GetArrayListItem(table.Rows, i));
    if row <> nil then
    begin
      for j := 0 to row^.Cells.Count - 1 do
      begin
        cell := PTableCell(GetArrayListItem(row^.Cells, j));
        if cell <> nil then
          Dispose(cell);
      end;
      FreeArrayList(row^.Cells);
      Dispose(row);
    end;
  end;
  ClearArrayList(table.Rows);

  { Fetch initial data - will be called properly after CalculateVisibleRows }
  { For now, just clear the rows }
  { fetchProc will be called when DrawTable is first invoked }

  table.NeedsRedraw := True;
end;

{ Display }

procedure DrawTable(var table: TTable);
var
  i, rowPosition, rowIndex: TInt;
  row: PTableRow;
begin
  { Calculate layout }
  table.VisibleRows := CalculateVisibleRows(table);
  CalculateColumnWidths(table);

  { Draw border }
  DrawTableBorder(table);

  { Draw header if we have columns }
  if table.VisibleColumns.Count > 0 then
    DrawTableHeader(table);

  { Draw data rows }
  rowPosition := 3; { Start after header }
  for i := 0 to table.VisibleRows - 1 do
  begin
    if i < table.Rows.Count then
    begin
      { Draw data row }
      row := PTableRow(GetArrayListItem(table.Rows, i));
      rowIndex := table.TopIndex + i;
      DrawTableRow(table, row, rowPosition, rowIndex);
    end
    else
    begin
      { Draw empty row }
      DrawTableEmptyRow(table, rowPosition);
    end;
    Inc(rowPosition);
  end;

  { Draw footer }
  DrawTableFooter(table);

  table.NeedsRedraw := False;
end;

{ Navigation }

procedure TableScrollDown(var table: TTable);
begin
  { Don't scroll if at last record }
  if (table.TotalRecords >= 0) and (table.SelectedIndex >= table.TotalRecords - 1) then
    Exit;

  { Move selection down }
  Inc(table.SelectedIndex);
  Inc(table.SelectedOffset);

  { Check if we need to fetch new data }
  if table.SelectedOffset >= table.VisibleRows then
  begin
    Inc(table.TopIndex);
    Dec(table.SelectedOffset);

    { Fetch new data if callback is available }
    if Assigned(table.FetchData) then
      RefreshTable(table);
  end;

  table.NeedsRedraw := True;
end;

procedure TableScrollUp(var table: TTable);
begin
  { Don't scroll if at first record }
  if table.SelectedIndex <= 0 then
    Exit;

  { Move selection up }
  Dec(table.SelectedIndex);
  Dec(table.SelectedOffset);

  { Check if we need to fetch new data }
  if table.SelectedOffset < 0 then
  begin
    Dec(table.TopIndex);
    table.SelectedOffset := 0;

    { Fetch new data if callback is available }
    if Assigned(table.FetchData) then
      RefreshTable(table);
  end;

  table.NeedsRedraw := True;
end;

procedure TablePageDown(var table: TTable);
var
  pageSize: TInt;
begin
  pageSize := table.VisibleRows;
  if pageSize = 0 then
    Exit;

  { Advance by page size }
  table.SelectedIndex := table.SelectedIndex + pageSize;
  table.TopIndex := table.TopIndex + pageSize;

  { Enforce boundaries }
  if (table.TotalRecords >= 0) and (table.SelectedIndex >= table.TotalRecords) then
  begin
    table.SelectedIndex := table.TotalRecords - 1;
    table.TopIndex := table.TotalRecords - table.VisibleRows;
    if table.TopIndex < 0 then
      table.TopIndex := 0;
  end;

  { Fetch new data }
  if Assigned(table.FetchData) then
    RefreshTable(table);

  table.NeedsRedraw := True;
end;

procedure TablePageUp(var table: TTable);
var
  pageSize: TInt;
begin
  pageSize := table.VisibleRows;
  if pageSize = 0 then
    Exit;

  { Go back by page size }
  table.SelectedIndex := table.SelectedIndex - pageSize;
  table.TopIndex := table.TopIndex - pageSize;

  { Enforce boundaries }
  if table.SelectedIndex < 0 then
    table.SelectedIndex := 0;
  if table.TopIndex < 0 then
    table.TopIndex := 0;

  { Fetch new data }
  if Assigned(table.FetchData) then
    RefreshTable(table);

  table.NeedsRedraw := True;
end;

procedure TableGoToTop(var table: TTable);
begin
  table.TopIndex := 0;
  table.SelectedIndex := 0;
  table.SelectedOffset := 0;

  { Fetch new data }
  if Assigned(table.FetchData) then
    RefreshTable(table);

  table.NeedsRedraw := True;
end;

procedure TableGoToBottom(var table: TTable);
begin
  { Can only go to bottom if total is known }
  if table.TotalRecords < 0 then
    Exit;

  { Set to last record }
  table.SelectedIndex := table.TotalRecords - 1;

  { Calculate top index to show last page }
  if table.VisibleRows > 0 then
  begin
    table.TopIndex := table.TotalRecords - table.VisibleRows;
    if table.TopIndex < 0 then
      table.TopIndex := 0;
  end
  else
    table.TopIndex := table.SelectedIndex;

  { Calculate selected offset }
  table.SelectedOffset := table.SelectedIndex - table.TopIndex;

  { Fetch new data }
  if Assigned(table.FetchData) then
    RefreshTable(table);

  table.NeedsRedraw := True;
end;

{ Data Management }

procedure RefreshTable(var table: TTable);
var
  i, j: TInt;
  row: PTableRow;
  cell: PTableCell;
begin
  { Free existing row data }
  for i := 0 to table.Rows.Count - 1 do
  begin
    row := PTableRow(GetArrayListItem(table.Rows, i));
    if row <> nil then
    begin
      { Free all cells in this row }
      for j := 0 to row^.Cells.Count - 1 do
      begin
        cell := PTableCell(GetArrayListItem(row^.Cells, j));
        if cell <> nil then
          Dispose(cell);
      end;
      FreeArrayList(row^.Cells);
      Dispose(row);
    end;
  end;
  ClearArrayList(table.Rows);

  { Fetch new data }
  if Assigned(table.FetchData) then
  begin
    if not table.FetchData(table.TopIndex, table.VisibleRows, table.Rows) then
    begin
      { Fetch failed - keep current data }
    end;
  end;

  table.NeedsRedraw := True;
end;

function GetSelectedRecordID(var table: TTable): TLong;
var
  rowIndex: TInt;
  row: PTableRow;
begin
  { Calculate which row in Rows list is selected }
  rowIndex := table.SelectedOffset;

  { Check if valid }
  if (rowIndex >= 0) and (rowIndex < table.Rows.Count) then
  begin
    row := PTableRow(GetArrayListItem(table.Rows, rowIndex));
    if row <> nil then
    begin
      GetSelectedRecordID := row^.RecordID;
      Exit;
    end;
  end;

  { Invalid or no data }
  GetSelectedRecordID := -1;
end;

function SetSelectedRecordID(var table: TTable; recordID: TLong): Boolean;
var
  i: TInt;
  row: PTableRow;
begin
  { Search through current rows for matching RecordID }
  for i := 0 to table.Rows.Count - 1 do
  begin
    row := PTableRow(GetArrayListItem(table.Rows, i));
    if (row <> nil) and (row^.RecordID = recordID) then
    begin
      { Found it - update selection }
      table.SelectedOffset := i;
      table.SelectedIndex := table.TopIndex + i;
      table.NeedsRedraw := True;
      SetSelectedRecordID := True;
      Exit;
    end;
  end;

  { Not found }
  SetSelectedRecordID := False;
end;

end.
