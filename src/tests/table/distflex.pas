program DistributeFlexTest;

{
  Tests for DistributeWidthToFlexibleColumns procedure in Table unit

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

procedure TestAllFlexibleEvenDistribution;
begin
  Write('Test 1: All flexible columns, even distribution (30 extra / 3 cols)... ');

  { Add 3 flexible columns }
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col3', 10, 0, aLeft, 0);

  { All columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(2)));

  { Distribute 30 extra pixels among 3 columns = 10 each }
  DistributeWidthToFlexibleColumns(tbl, 30);

  if (tbl.ColumnWidths[0] = 20) and
     (tbl.ColumnWidths[1] = 20) and
     (tbl.ColumnWidths[2] = 20) then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected [20,20,20], got [',
            tbl.ColumnWidths[0], ',',
            tbl.ColumnWidths[1], ',',
            tbl.ColumnWidths[2], '])');
    allPassed := False;
  end;
end;

procedure TestAllFlexibleWithRemainder;
begin
  Write('Test 2: All flexible columns, with remainder (31 extra / 3 cols)... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add 3 flexible columns }
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col3', 10, 0, aLeft, 0);

  { All columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(2)));

  { Distribute 31 extra pixels: 10 each + 1 extra to first column }
  DistributeWidthToFlexibleColumns(tbl, 31);

  if (tbl.ColumnWidths[0] = 21) and
     (tbl.ColumnWidths[1] = 20) and
     (tbl.ColumnWidths[2] = 20) then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected [21,20,20], got [',
            tbl.ColumnWidths[0], ',',
            tbl.ColumnWidths[1], ',',
            tbl.ColumnWidths[2], '])');
    allPassed := False;
  end;
end;

procedure TestMixedColumnsFlexAndFixed;
begin
  Write('Test 3: Mixed flexible and fixed columns... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add mixed columns }
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);   { Flexible }
  AddTableColumn(tbl, 'Col2', 15, 20, aLeft, 0);  { Fixed (MaxWidth=20) }
  AddTableColumn(tbl, 'Col3', 10, 0, aLeft, 0);   { Flexible }

  { All columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(2)));

  { Distribute 30 extra pixels: 2 flexible columns get 15 each, fixed gets MinWidth }
  DistributeWidthToFlexibleColumns(tbl, 30);

  if (tbl.ColumnWidths[0] = 25) and
     (tbl.ColumnWidths[1] = 15) and
     (tbl.ColumnWidths[2] = 25) then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected [25,15,25], got [',
            tbl.ColumnWidths[0], ',',
            tbl.ColumnWidths[1], ',',
            tbl.ColumnWidths[2], '])');
    allPassed := False;
  end;
end;

procedure TestNoFlexibleColumns;
begin
  Write('Test 4: No flexible columns (all should get MinWidth)... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add fixed columns only }
  AddTableColumn(tbl, 'Col1', 10, 20, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 15, 25, aLeft, 0);

  { All columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));

  { Distribute 30 extra pixels - should all go unused, columns get MinWidth }
  DistributeWidthToFlexibleColumns(tbl, 30);

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

procedure TestSingleFlexibleColumn;
begin
  Write('Test 5: Single flexible column gets all extra space... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add 1 flexible and 1 fixed column }
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);   { Flexible }
  AddTableColumn(tbl, 'Col2', 15, 20, aLeft, 0);  { Fixed }

  { All columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));

  { Distribute 50 extra pixels - all should go to flexible column }
  DistributeWidthToFlexibleColumns(tbl, 50);

  if (tbl.ColumnWidths[0] = 60) and
     (tbl.ColumnWidths[1] = 15) then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected [60,15], got [',
            tbl.ColumnWidths[0], ',',
            tbl.ColumnWidths[1], '])');
    allPassed := False;
  end;
end;

procedure TestZeroExtraSpace;
begin
  Write('Test 6: Zero extra space (columns get MinWidth)... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add flexible columns }
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 15, 0, aLeft, 0);

  { All columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));

  { Distribute 0 extra pixels }
  DistributeWidthToFlexibleColumns(tbl, 0);

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

procedure TestRemainderDistribution;
begin
  Write('Test 7: Remainder distributed to first columns (32 extra / 3 cols)... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add 3 flexible columns }
  AddTableColumn(tbl, 'Col1', 5, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 5, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col3', 5, 0, aLeft, 0);

  { All columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(2)));

  { Distribute 32 extra: 10 each + 2 remainder to first 2 columns }
  DistributeWidthToFlexibleColumns(tbl, 32);

  if (tbl.ColumnWidths[0] = 16) and
     (tbl.ColumnWidths[1] = 16) and
     (tbl.ColumnWidths[2] = 15) then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected [16,16,15], got [',
            tbl.ColumnWidths[0], ',',
            tbl.ColumnWidths[1], ',',
            tbl.ColumnWidths[2], '])');
    allPassed := False;
  end;
end;

procedure TestDifferentMinWidths;
begin
  Write('Test 8: Flexible columns with different MinWidths... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add flexible columns with different MinWidths }
  AddTableColumn(tbl, 'Col1', 5, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col3', 20, 0, aLeft, 0);

  { All columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(2)));

  { Distribute 30 extra: each gets +10 }
  DistributeWidthToFlexibleColumns(tbl, 30);

  if (tbl.ColumnWidths[0] = 15) and
     (tbl.ColumnWidths[1] = 20) and
     (tbl.ColumnWidths[2] = 30) then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected [15,20,30], got [',
            tbl.ColumnWidths[0], ',',
            tbl.ColumnWidths[1], ',',
            tbl.ColumnWidths[2], '])');
    allPassed := False;
  end;
end;

begin
  allPassed := True;

  WriteLn('===========================================');
  WriteLn('DistributeWidthToFlexibleColumns Tests');
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
  TestAllFlexibleEvenDistribution;
  TestAllFlexibleWithRemainder;
  TestMixedColumnsFlexAndFixed;
  TestNoFlexibleColumns;
  TestSingleFlexibleColumn;
  TestZeroExtraSpace;
  TestRemainderDistribution;
  TestDifferentMinWidths;

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
