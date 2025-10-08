program TableComponentTest;

{
  Basic Table Component Test

  Tests initialization, configuration, and basic drawing of the table component.
}

uses
  BBSTypes, Lists, UI, Colors, Table, SysUtils;

var
  screen: TScreen;
  tbl: TTable;
  box: TBox;
  testsPassed: Boolean;

{ Mock data fetch function }
function FetchTestData(startIndex: TInt; maxRows: TInt; var rows: TArrayList): Boolean;
var
  i, count: TInt;
  row: PTableRow;
  cell: PTableCell;
begin
  count := 0;
  for i := startIndex to startIndex + maxRows - 1 do
  begin
    if i >= 100 then { Simulate 100 total records }
      break;

    New(row);
    row^.RecordID := i + 1;
    InitArrayList(row^.Cells, 0);

    { Column 0: ID }
    New(cell);
    cell^ := IntToStr(i + 1);
    AddArrayListItem(row^.Cells, cell);

    { Column 1: Name }
    New(cell);
    cell^ := 'User' + IntToStr(i + 1);
    AddArrayListItem(row^.Cells, cell);

    { Column 2: Email }
    New(cell);
    cell^ := 'user' + IntToStr(i + 1) + '@example.com';
    AddArrayListItem(row^.Cells, cell);

    AddArrayListItem(rows, row);
    Inc(count);
  end;

  FetchTestData := count > 0;
end;

begin
  WriteLn('===========================================');
  WriteLn('Table Component Basic Test');
  WriteLn('===========================================');
  WriteLn;

  testsPassed := True;

  { Test 1: Initialize table }
  WriteLn('[Test 1] InitTable');
  screen.Output := @Output;
  screen.Width := 80;
  screen.Height := 25;
  screen.IsANSI := False;
  screen.IsColor := False;
  screen.ScreenType := stASCII;

  box.Row := 1;
  box.Column := 1;
  box.Height := 20;
  box.Width := 80;

  InitTable(tbl, screen, box);
  if (tbl.Columns.Count <> 0) or (tbl.Rows.Count <> 0) then
  begin
    WriteLn('  FAILED: Table not initialized correctly');
    testsPassed := False;
  end
  else
    WriteLn('  PASSED');

  { Test 2: Add columns }
  WriteLn('[Test 2] AddTableColumn');
  AddTableColumn(tbl, 'ID', 6, 8, aLeft, 0);
  AddTableColumn(tbl, 'Name', 10, 15, aLeft, 0);
  AddTableColumn(tbl, 'Email', 15, 30, aLeft, 1);

  if tbl.Columns.Count <> 3 then
  begin
    WriteLn('  FAILED: Expected 3 columns, got ', tbl.Columns.Count);
    testsPassed := False;
  end
  else
    WriteLn('  PASSED');

  { Test 3: Set data source }
  WriteLn('[Test 3] SetTableDataSource');
  SetTableDataSource(tbl, FetchTestData, 100);

  if tbl.TotalRecords <> 100 then
  begin
    WriteLn('  FAILED: TotalRecords should be 100, got ', tbl.TotalRecords);
    testsPassed := False;
  end
  else
    WriteLn('  PASSED');

  { Test 4: Calculate layout }
  WriteLn('[Test 4] Calculate layout (via DrawTable)');
  DrawTable(tbl);

  if tbl.VisibleRows <= 0 then
  begin
    WriteLn('  FAILED: VisibleRows should be > 0, got ', tbl.VisibleRows);
    testsPassed := False;
  end
  else
    WriteLn('  PASSED (VisibleRows=', tbl.VisibleRows, ')');

  { Test 5: Navigation }
  WriteLn('[Test 5] TableScrollDown');
  tbl.SelectedIndex := 0;
  tbl.SelectedOffset := 0;
  TableScrollDown(tbl);

  if tbl.SelectedIndex <> 1 then
  begin
    WriteLn('  FAILED: SelectedIndex should be 1, got ', tbl.SelectedIndex);
    testsPassed := False;
  end
  else
    WriteLn('  PASSED');

  { Test 6: GetSelectedRecordID }
  WriteLn('[Test 6] GetSelectedRecordID');
  if tbl.Rows.Count > 1 then
  begin
    tbl.SelectedOffset := 1;
    if GetSelectedRecordID(tbl) <> 2 then
    begin
      WriteLn('  FAILED: Expected RecordID 2');
      testsPassed := False;
    end
    else
      WriteLn('  PASSED');
  end
  else
    WriteLn('  SKIPPED (not enough rows)');

  { Test 7: Free table }
  WriteLn('[Test 7] FreeTable');
  FreeTable(tbl);
  WriteLn('  PASSED (no crash)');

  WriteLn;
  WriteLn('===========================================');
  if testsPassed then
  begin
    WriteLn('All tests PASSED');
    Halt(0);
  end
  else
  begin
    WriteLn('Some tests FAILED');
    Halt(1);
  end;
end.
