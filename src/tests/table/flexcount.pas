program FlexCountTest;

{
  Tests for CountFlexibleColumns function in Table unit

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  BBSTypes, Lists, Table, UI, Colors;

var
  tbl: TTable;
  screen: TScreen;
  box: TBox;
  count: TInt;
  allPassed: Boolean;

procedure TestNoColumns;
begin
  Write('Test 1: No columns... ');
  count := CountFlexibleColumns(tbl);
  if count = 0 then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected 0, got ', count, ')');
    allPassed := False;
  end;
end;

procedure TestNoFlexibleColumns;
begin
  Write('Test 2: No flexible columns (all have MaxWidth)... ');

  { Add 3 columns with MaxWidth set }
  AddTableColumn(tbl, 'Col1', 10, 20, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 10, 20, aLeft, 0);
  AddTableColumn(tbl, 'Col3', 10, 20, aLeft, 0);

  { Simulate visible columns being populated }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(2)));

  count := CountFlexibleColumns(tbl);
  if count = 0 then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected 0, got ', count, ')');
    allPassed := False;
  end;
end;

procedure TestAllFlexibleColumns;
begin
  Write('Test 3: All flexible columns (MaxWidth = 0)... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add 3 columns with MaxWidth = 0 }
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col3', 10, 0, aLeft, 0);

  { Simulate visible columns being populated }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(2)));

  count := CountFlexibleColumns(tbl);
  if count = 3 then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected 3, got ', count, ')');
    allPassed := False;
  end;
end;

procedure TestMixedColumns;
begin
  Write('Test 4: Mixed columns (2 flexible, 2 fixed)... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add mixed columns }
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);   { Flexible }
  AddTableColumn(tbl, 'Col2', 10, 20, aLeft, 0);  { Fixed }
  AddTableColumn(tbl, 'Col3', 10, 0, aLeft, 0);   { Flexible }
  AddTableColumn(tbl, 'Col4', 10, 15, aLeft, 0);  { Fixed }

  { Simulate visible columns being populated }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(2)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(3)));

  count := CountFlexibleColumns(tbl);
  if count = 2 then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected 2, got ', count, ')');
    allPassed := False;
  end;
end;

procedure TestPartialVisibleColumns;
begin
  Write('Test 5: Only some columns visible (1 of 2 flexible visible)... ');

  { Clear previous setup }
  FreeTable(tbl);
  InitTable(tbl, screen, box);

  { Add columns }
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);   { Flexible }
  AddTableColumn(tbl, 'Col2', 10, 20, aLeft, 0);  { Fixed }
  AddTableColumn(tbl, 'Col3', 10, 0, aLeft, 0);   { Flexible }

  { Only first two columns visible }
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(0)));
  AddArrayListItem(tbl.VisibleColumns, Pointer(PtrUInt(1)));

  count := CountFlexibleColumns(tbl);
  if count = 1 then
    WriteLn('PASSED')
  else
  begin
    WriteLn('FAILED (expected 1, got ', count, ')');
    allPassed := False;
  end;
end;

begin
  allPassed := True;

  WriteLn('===========================================');
  WriteLn('CountFlexibleColumns Tests');
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
  TestNoFlexibleColumns;
  TestAllFlexibleColumns;
  TestMixedColumns;
  TestPartialVisibleColumns;

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
