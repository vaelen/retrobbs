program AssignMinTest;

{
  Tests for AssignMinimumWidths procedure in Table unit

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  BBSTypes, Lists, Table, UI, Colors;

var
  tbl: TTable;
  screen: TScreen;
  box: TBox;
  allPassed: Boolean;

procedure TestNoColumns;
begin
  Write('Test 1: No visible columns (no crash)... ');
  AssignMinimumWidths(tbl);
  WriteLn('PASSED');
end;

procedure TestSingleColumn;
begin
  Write('Test 2: Single column (MinWidth=10)... ');

  { Add 1 column }
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);

  { Simulate visible columns being populated }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));

  AssignMinimumWidths(tbl);

  if tbl.ColumnWidths[0] = 10 then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected 10, got ', tbl.ColumnWidths[0], ')');
    allPassed := False;
  end;
end;

procedure TestMultipleColumns;
begin
  Write('Test 3: Multiple columns with different MinWidths... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add columns with different MinWidths }
  AddTableColumn(tbl, 'Col1', 8, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 15, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col3', 20, 0, aLeft, 0);

  { All columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(2)));

  AssignMinimumWidths(tbl);

  if (tbl.ColumnWidths[0] = 8) and
     (tbl.ColumnWidths[1] = 15) and
     (tbl.ColumnWidths[2] = 20) then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected [8,15,20], got [',
            tbl.ColumnWidths[0], ',',
            tbl.ColumnWidths[1], ',',
            tbl.ColumnWidths[2], '])');
    allPassed := False;
  end;
end;

procedure TestMaxWidthIgnored;
begin
  Write('Test 4: MaxWidth is ignored (only MinWidth used)... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add columns with various MaxWidths }
  AddTableColumn(tbl, 'Col1', 10, 50, aLeft, 0);  { MinWidth=10, MaxWidth=50 }
  AddTableColumn(tbl, 'Col2', 15, 0, aLeft, 0);   { MinWidth=15, MaxWidth=0 }
  AddTableColumn(tbl, 'Col3', 20, 30, aLeft, 0);  { MinWidth=20, MaxWidth=30 }

  { All columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(2)));

  AssignMinimumWidths(tbl);

  { Should assign MinWidth values, ignoring MaxWidth }
  if (tbl.ColumnWidths[0] = 10) and
     (tbl.ColumnWidths[1] = 15) and
     (tbl.ColumnWidths[2] = 20) then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected [10,15,20], got [',
            tbl.ColumnWidths[0], ',',
            tbl.ColumnWidths[1], ',',
            tbl.ColumnWidths[2], '])');
    allPassed := False;
  end;
end;

procedure TestPartialVisibleColumns;
begin
  Write('Test 5: Only some columns visible... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add 4 columns }
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 15, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col3', 20, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col4', 25, 0, aLeft, 0);

  { Only columns 0 and 2 visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(2)));

  AssignMinimumWidths(tbl);

  { Should assign MinWidth to visible columns at indices 0 and 1 }
  if (tbl.ColumnWidths[0] = 10) and
     (tbl.ColumnWidths[1] = 20) then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected [10,20], got [',
            tbl.ColumnWidths[0], ',',
            tbl.ColumnWidths[1], '])');
    allPassed := False;
  end;
end;

procedure TestOverwritesPreviousWidths;
begin
  Write('Test 6: Overwrites previously set ColumnWidths... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add columns }
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 15, 0, aLeft, 0);

  { All columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));

  { Set some initial widths }
  tbl.ColumnWidths[0] := 100;
  tbl.ColumnWidths[1] := 200;

  { Call AssignMinimumWidths - should overwrite }
  AssignMinimumWidths(tbl);

  if (tbl.ColumnWidths[0] = 10) and
     (tbl.ColumnWidths[1] = 15) then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected [10,15], got [',
            tbl.ColumnWidths[0], ',',
            tbl.ColumnWidths[1], '])');
    allPassed := False;
  end;
end;

procedure TestLargeMinWidths;
begin
  Write('Test 7: Large MinWidth values... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add columns with large MinWidths }
  AddTableColumn(tbl, 'Col1', 100, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 200, 0, aLeft, 0);

  { All columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));

  AssignMinimumWidths(tbl);

  if (tbl.ColumnWidths[0] = 100) and
     (tbl.ColumnWidths[1] = 200) then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected [100,200], got [',
            tbl.ColumnWidths[0], ',',
            tbl.ColumnWidths[1], '])');
    allPassed := False;
  end;
end;

begin
  allPassed := True;

  WriteLn('===========================================');
  WriteLn('AssignMinimumWidths Tests');
  WriteLn('===========================================');
  WriteLn;

  { Initialize screen and table }
  screen.Output := @Output;
  screen.Width := 80;
  screen.Height := 24;
  screen.IsANSI := False;
  screen.IsColor := False;
  screen.ScreenType := stASCII;

  box.Row := 1;
  box.Column := 1;
  box.Width := 80;
  box.Height := 24;
  InitTable(tbl, screen, box);

  { Run tests }
  TestNoColumns;
  TestSingleColumn;
  TestMultipleColumns;
  TestMaxWidthIgnored;
  TestPartialVisibleColumns;
  TestOverwritesPreviousWidths;
  TestLargeMinWidths;

  { Cleanup }
  FreeTable(tbl);

  WriteLn;
  WriteLn('===========================================');
  if allPassed then
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
