program TableVisibleColumnsTest;

{
  Table Visible Columns Test

  Tests the DetermineVisibleColumnsByPriority helper procedure.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  BBSTypes, Lists, UI, Colors, Table, SysUtils;

var
  screen: TScreen;
  tbl: TTable;
  box: TBox;
  testsPassed: Boolean;

function GetVisibleColumnCount(var table: TTable): TInt;
begin
  GetVisibleColumnCount := table.VisibleColumns.Count;
end;

function GetVisibleColumnIndex(var table: TTable; pos: TInt): TInt;
begin
  GetVisibleColumnIndex := TInt(PtrUInt(GetArrayListItem(table.VisibleColumns, pos)));
end;

begin
  WriteLn('===========================================');
  WriteLn('Table Visible Columns Test');
  WriteLn('===========================================');
  WriteLn;

  testsPassed := True;

  { Initialize screen and box }
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

  { Test 1: Empty table }
  WriteLn('[Test 1] DetermineVisibleColumnsByPriority - Empty table');
  InitTable(tbl, screen, box);
  DetermineVisibleColumnsByPriority(tbl, 78, 0);
  if GetVisibleColumnCount(tbl) <> 0 then
  begin
    WriteLn('  FAILED: Expected 0 visible columns, got ', GetVisibleColumnCount(tbl));
    testsPassed := False;
  end
  else
    WriteLn('  PASSED');
  FreeTable(tbl);

  { Test 2: Single priority 0 column that fits }
  WriteLn('[Test 2] DetermineVisibleColumnsByPriority - Single column (fits)');
  InitTable(tbl, screen, box);
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);
  DetermineVisibleColumnsByPriority(tbl, 78, 0);
  if GetVisibleColumnCount(tbl) <> 1 then
  begin
    WriteLn('  FAILED: Expected 1 visible column, got ', GetVisibleColumnCount(tbl));
    testsPassed := False;
  end
  else if GetVisibleColumnIndex(tbl, 0) <> 0 then
  begin
    WriteLn('  FAILED: Expected column index 0, got ', GetVisibleColumnIndex(tbl, 0));
    testsPassed := False;
  end
  else
    WriteLn('  PASSED');
  FreeTable(tbl);

  { Test 3: Multiple priority 0 columns that fit }
  WriteLn('[Test 3] DetermineVisibleColumnsByPriority - Multiple priority 0 (all fit)');
  InitTable(tbl, screen, box);
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col3', 10, 0, aLeft, 0);
  { Total width: 10 + 10 + 10 + 2 separators = 32 }
  DetermineVisibleColumnsByPriority(tbl, 78, 0);
  if GetVisibleColumnCount(tbl) <> 3 then
  begin
    WriteLn('  FAILED: Expected 3 visible columns, got ', GetVisibleColumnCount(tbl));
    testsPassed := False;
  end
  else
    WriteLn('  PASSED');
  FreeTable(tbl);

  { Test 4: Priority 0 column too wide (but always shows) }
  WriteLn('[Test 4] DetermineVisibleColumnsByPriority - Priority 0 too wide (forced)');
  InitTable(tbl, screen, box);
  AddTableColumn(tbl, 'Col1', 100, 0, aLeft, 0);
  { Width 100 > 78 available, but priority 0 always shows }
  DetermineVisibleColumnsByPriority(tbl, 78, 0);
  if GetVisibleColumnCount(tbl) <> 1 then
  begin
    WriteLn('  FAILED: Expected 1 visible column (forced), got ', GetVisibleColumnCount(tbl));
    testsPassed := False;
  end
  else
    WriteLn('  PASSED');
  FreeTable(tbl);

  { Test 5: Mixed priorities - all fit }
  WriteLn('[Test 5] DetermineVisibleColumnsByPriority - Priorities 0,1,2 (all fit)');
  InitTable(tbl, screen, box);
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 10, 0, aLeft, 1);
  AddTableColumn(tbl, 'Col3', 10, 0, aLeft, 2);
  { Total width: 10 + 10 + 10 + 2 separators = 32 }
  DetermineVisibleColumnsByPriority(tbl, 78, 2);
  if GetVisibleColumnCount(tbl) <> 3 then
  begin
    WriteLn('  FAILED: Expected 3 visible columns, got ', GetVisibleColumnCount(tbl));
    testsPassed := False;
  end
  else
    WriteLn('  PASSED');
  FreeTable(tbl);

  { Test 6: Mixed priorities - priority 2 doesn't fit }
  WriteLn('[Test 6] DetermineVisibleColumnsByPriority - Priority 2 does not fit');
  InitTable(tbl, screen, box);
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 10, 0, aLeft, 1);
  AddTableColumn(tbl, 'Col3', 30, 0, aLeft, 2);
  { Priority 0: 10, Priority 0+1: 10+10+1sep=21, Priority 0+1+2: 10+10+30+2sep=52 }
  DetermineVisibleColumnsByPriority(tbl, 25, 2);
  if GetVisibleColumnCount(tbl) <> 2 then
  begin
    WriteLn('  FAILED: Expected 2 visible columns, got ', GetVisibleColumnCount(tbl));
    testsPassed := False;
  end
  else if GetVisibleColumnIndex(tbl, 0) <> 0 then
  begin
    WriteLn('  FAILED: Expected column 0 at position 0, got ', GetVisibleColumnIndex(tbl, 0));
    testsPassed := False;
  end
  else if GetVisibleColumnIndex(tbl, 1) <> 1 then
  begin
    WriteLn('  FAILED: Expected column 1 at position 1, got ', GetVisibleColumnIndex(tbl, 1));
    testsPassed := False;
  end
  else
    WriteLn('  PASSED');
  FreeTable(tbl);

  { Test 7: Mixed priorities - priority 1 doesn't fit }
  WriteLn('[Test 7] DetermineVisibleColumnsByPriority - Priority 1 does not fit');
  InitTable(tbl, screen, box);
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 30, 0, aLeft, 1);
  AddTableColumn(tbl, 'Col3', 10, 0, aLeft, 2);
  { Priority 0: 10, Priority 0+1: 10+30+1sep=41 }
  DetermineVisibleColumnsByPriority(tbl, 20, 2);
  if GetVisibleColumnCount(tbl) <> 1 then
  begin
    WriteLn('  FAILED: Expected 1 visible column, got ', GetVisibleColumnCount(tbl));
    testsPassed := False;
  end
  else if GetVisibleColumnIndex(tbl, 0) <> 0 then
  begin
    WriteLn('  FAILED: Expected column 0, got ', GetVisibleColumnIndex(tbl, 0));
    testsPassed := False;
  end
  else
    WriteLn('  PASSED');
  FreeTable(tbl);

  { Test 8: Multiple columns at same priority }
  WriteLn('[Test 8] DetermineVisibleColumnsByPriority - Multiple columns at priority 1');
  InitTable(tbl, screen, box);
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 10, 0, aLeft, 1);
  AddTableColumn(tbl, 'Col3', 10, 0, aLeft, 1);
  AddTableColumn(tbl, 'Col4', 10, 0, aLeft, 2);
  { Priority 0: 10, Priority 0+1: 10+10+10+2sep=32, Priority 0+1+2: 10+10+10+10+3sep=43 }
  DetermineVisibleColumnsByPriority(tbl, 35, 2);
  if GetVisibleColumnCount(tbl) <> 3 then
  begin
    WriteLn('  FAILED: Expected 3 visible columns, got ', GetVisibleColumnCount(tbl));
    testsPassed := False;
  end
  else
    WriteLn('  PASSED');
  FreeTable(tbl);

  { Test 9: Non-sequential priorities }
  WriteLn('[Test 9] DetermineVisibleColumnsByPriority - Non-sequential priorities (0,3,5)');
  InitTable(tbl, screen, box);
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 10, 0, aLeft, 3);
  AddTableColumn(tbl, 'Col3', 10, 0, aLeft, 5);
  { Priority 0: 10, Priority 0-3: 10+10+1sep=21, Priority 0-5: 10+10+10+2sep=32 }
  DetermineVisibleColumnsByPriority(tbl, 78, 5);
  if GetVisibleColumnCount(tbl) <> 3 then
  begin
    WriteLn('  FAILED: Expected 3 visible columns, got ', GetVisibleColumnCount(tbl));
    testsPassed := False;
  end
  else
    WriteLn('  PASSED');
  FreeTable(tbl);

  { Test 10: Exact fit }
  WriteLn('[Test 10] DetermineVisibleColumnsByPriority - Exact fit');
  InitTable(tbl, screen, box);
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 10, 0, aLeft, 1);
  { Total width: 10 + 10 + 1 separator = 21 }
  DetermineVisibleColumnsByPriority(tbl, 21, 1);
  if GetVisibleColumnCount(tbl) <> 2 then
  begin
    WriteLn('  FAILED: Expected 2 visible columns, got ', GetVisibleColumnCount(tbl));
    testsPassed := False;
  end
  else
    WriteLn('  PASSED');
  FreeTable(tbl);

  { Test 11: Off by one (doesn't fit) }
  WriteLn('[Test 11] DetermineVisibleColumnsByPriority - Off by one (does not fit)');
  InitTable(tbl, screen, box);
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 10, 0, aLeft, 1);
  { Total width: 10 + 10 + 1 separator = 21 }
  DetermineVisibleColumnsByPriority(tbl, 20, 1);
  if GetVisibleColumnCount(tbl) <> 1 then
  begin
    WriteLn('  FAILED: Expected 1 visible column, got ', GetVisibleColumnCount(tbl));
    testsPassed := False;
  end
  else
    WriteLn('  PASSED');
  FreeTable(tbl);

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
