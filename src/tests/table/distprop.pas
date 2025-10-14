program DistributeProportionallyTest;

{
  Tests for DistributeWidthProportionally procedure in Table unit

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

procedure TestEqualMinWidths;
begin
  Write('Test 1: Equal MinWidths (10 each, 30 extra / 3 cols = 10 each)... ');

  { Add 3 columns with equal MinWidths }
  AddTableColumn(tbl, 'Col1', 10, 20, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 10, 20, aLeft, 0);
  AddTableColumn(tbl, 'Col3', 10, 20, aLeft, 0);

  { All columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(2)));

  { Total MinWidth = 30, distribute 30 extra proportionally }
  DistributeWidthProportionally(tbl, 30, 30);

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

procedure TestDifferentMinWidths;
begin
  Write('Test 2: Different MinWidths (5,10,15, 30 extra proportionally)... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add columns with different MinWidths }
  AddTableColumn(tbl, 'Col1', 5, 20, aLeft, 0);   { 5/30 = 16.67% }
  AddTableColumn(tbl, 'Col2', 10, 20, aLeft, 0);  { 10/30 = 33.33% }
  AddTableColumn(tbl, 'Col3', 15, 20, aLeft, 0);  { 15/30 = 50% }

  { All columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(2)));

  { Total MinWidth = 30, distribute 30 extra proportionally }
  { Col1: 5 + (5*30/30) = 10, Col2: 10 + (10*30/30) = 20, Col3: 15 + (15*30/30) = 30 }
  DistributeWidthProportionally(tbl, 30, 30);

  if (tbl.ColumnWidths[0] = 10) and
     (tbl.ColumnWidths[1] = 20) and
     (tbl.ColumnWidths[2] = 20) then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected [10,20,20], got [',
            tbl.ColumnWidths[0], ',',
            tbl.ColumnWidths[1], ',',
            tbl.ColumnWidths[2], '])');
    allPassed := False;
  end;
end;

procedure TestMaxWidthConstraint;
begin
  Write('Test 3: MaxWidth constraint respected (column capped at MaxWidth)... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add columns where one would exceed MaxWidth }
  AddTableColumn(tbl, 'Col1', 10, 15, aLeft, 0);  { MaxWidth = 15 }
  AddTableColumn(tbl, 'Col2', 10, 50, aLeft, 0);  { MaxWidth = 50 }

  { All columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));

  { Total MinWidth = 20, distribute 20 extra }
  { Col1: 10 + 10 = 20, but MaxWidth=15, so capped at 15 (5 lost) }
  { Col2: 10 + 10 = 20, plus 5 remainder = 25 }
  DistributeWidthProportionally(tbl, 20, 20);

  if (tbl.ColumnWidths[0] = 15) and
     (tbl.ColumnWidths[1] = 25) then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected [15,25], got [',
            tbl.ColumnWidths[0], ',',
            tbl.ColumnWidths[1], '])');
    allPassed := False;
  end;
end;

procedure TestRemainderToLastColumn;
begin
  Write('Test 4: Remainder goes to last column... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add columns }
  AddTableColumn(tbl, 'Col1', 10, 50, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 10, 50, aLeft, 0);
  AddTableColumn(tbl, 'Col3', 10, 50, aLeft, 0);

  { All columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(2)));

  { Total MinWidth = 30, distribute 31 extra (1 remainder) }
  { Each gets 10, last gets +1 }
  DistributeWidthProportionally(tbl, 31, 30);

  if (tbl.ColumnWidths[0] = 20) and
     (tbl.ColumnWidths[1] = 20) and
     (tbl.ColumnWidths[2] = 21) then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected [20,20,21], got [',
            tbl.ColumnWidths[0], ',',
            tbl.ColumnWidths[1], ',',
            tbl.ColumnWidths[2], '])');
    allPassed := False;
  end;
end;

procedure TestLastColumnAtMaxWidth;
begin
  Write('Test 5: Last column at MaxWidth cannot take remainder... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add columns where last has MaxWidth }
  AddTableColumn(tbl, 'Col1', 10, 50, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 10, 20, aLeft, 0);  { MaxWidth = 20 }

  { All columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));

  { Total MinWidth = 20, distribute 21 extra }
  { Each gets 10, but Col2 would be 21 which exceeds MaxWidth=20 }
  DistributeWidthProportionally(tbl, 21, 20);

  if (tbl.ColumnWidths[0] = 20) and
     (tbl.ColumnWidths[1] = 20) then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected [20,20], got [',
            tbl.ColumnWidths[0], ',',
            tbl.ColumnWidths[1], '])');
    allPassed := False;
  end;
end;

procedure TestZeroExtraSpace;
begin
  Write('Test 6: Zero extra space (all get MinWidth)... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add columns }
  AddTableColumn(tbl, 'Col1', 10, 20, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 15, 25, aLeft, 0);

  { All columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));

  { Total MinWidth = 25, distribute 0 extra }
  DistributeWidthProportionally(tbl, 0, 25);

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

procedure TestSingleColumn;
begin
  Write('Test 7: Single column gets all extra space... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add single column }
  AddTableColumn(tbl, 'Col1', 10, 50, aLeft, 0);

  { Column visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));

  { Total MinWidth = 10, distribute 20 extra }
  DistributeWidthProportionally(tbl, 20, 10);

  if tbl.ColumnWidths[0] = 30 then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected 30, got ', tbl.ColumnWidths[0], ')');
    allPassed := False;
  end;
end;

procedure TestLargeProportionalDifference;
begin
  Write('Test 8: Large proportional difference (1,9,90 MinWidths)... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add columns with very different MinWidths }
  AddTableColumn(tbl, 'Col1', 1, 50, aLeft, 0);   { 1/100 = 1% }
  AddTableColumn(tbl, 'Col2', 9, 50, aLeft, 0);   { 9/100 = 9% }
  AddTableColumn(tbl, 'Col3', 90, 200, aLeft, 0); { 90/100 = 90% }

  { All columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(2)));

  { Total MinWidth = 100, distribute 100 extra }
  { Col1: 1 + 1 = 2, Col2: 9 + 9 = 18, Col3: 90 + 90 = 180 }
  DistributeWidthProportionally(tbl, 100, 100);

  if (tbl.ColumnWidths[0] = 2) and
     (tbl.ColumnWidths[1] = 18) and
     (tbl.ColumnWidths[2] = 180) then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected [2,18,180], got [',
            tbl.ColumnWidths[0], ',',
            tbl.ColumnWidths[1], ',',
            tbl.ColumnWidths[2], '])');
    allPassed := False;
  end;
end;

begin
  allPassed := True;

  WriteLn('===========================================');
  WriteLn('DistributeWidthProportionally Tests');
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
  TestEqualMinWidths;
  TestDifferentMinWidths;
  TestMaxWidthConstraint;
  TestRemainderToLastColumn;
  TestLastColumnAtMaxWidth;
  TestZeroExtraSpace;
  TestSingleColumn;
  TestLargeProportionalDifference;

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
