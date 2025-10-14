program MinWidthTest;

{
  Tests for CalculateTotalMinWidth function in Table unit

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  BBSTypes, Lists, Table, UI, Colors;

var
  tbl: TTable;
  screen: TScreen;
  box: TBox;
  totalWidth: TInt;
  allPassed: Boolean;

procedure TestNoColumns;
begin
  Write('Test 1: No visible columns... ');
  totalWidth := CalculateTotalMinWidth(tbl);
  if totalWidth = 0 then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected 0, got ', totalWidth, ')');
    allPassed := False;
  end;
end;

procedure TestSingleColumn;
begin
  Write('Test 2: Single column with MinWidth=10... ');

  { Add 1 column }
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);

  { Simulate visible columns being populated }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));

  totalWidth := CalculateTotalMinWidth(tbl);
  if totalWidth = 10 then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected 10, got ', totalWidth, ')');
    allPassed := False;
  end;
end;

procedure TestMultipleColumnsAllVisible;
begin
  Write('Test 3: Multiple columns all visible (10+15+20=45)... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add columns with different MinWidths }
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 15, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col3', 20, 0, aLeft, 0);

  { All columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(2)));

  totalWidth := CalculateTotalMinWidth(tbl);
  if totalWidth = 45 then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected 45, got ', totalWidth, ')');
    allPassed := False;
  end;
end;

procedure TestPartialVisibleColumns;
begin
  Write('Test 4: Only some columns visible (10+20=30)... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add columns }
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 15, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col3', 20, 0, aLeft, 0);

  { Only first and third columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(2)));

  totalWidth := CalculateTotalMinWidth(tbl);
  if totalWidth = 30 then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected 30, got ', totalWidth, ')');
    allPassed := False;
  end;
end;

procedure TestMaxWidthDoesNotAffect;
begin
  Write('Test 5: MaxWidth should not affect result (only MinWidth counts)... ');

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

  totalWidth := CalculateTotalMinWidth(tbl);
  if totalWidth = 45 then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected 45, got ', totalWidth, ')');
    allPassed := False;
  end;
end;

procedure TestLargeMinWidths;
begin
  Write('Test 6: Large MinWidth values (100+200+150=450)... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add columns with large MinWidths }
  AddTableColumn(tbl, 'Col1', 100, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 200, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col3', 150, 0, aLeft, 0);

  { All columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(2)));

  totalWidth := CalculateTotalMinWidth(tbl);
  if totalWidth = 450 then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected 450, got ', totalWidth, ')');
    allPassed := False;
  end;
end;

begin
  allPassed := True;

  WriteLn('===========================================');
  WriteLn('CalculateTotalMinWidth Tests');
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
  TestMultipleColumnsAllVisible;
  TestPartialVisibleColumns;
  TestMaxWidthDoesNotAffect;
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
