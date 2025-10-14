program TablePriorityTest;

{
  Table Priority Test

  Tests the GetMaxColumnPriority helper function.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  BBSTypes, Lists, UI, Colors, Table;

var
  screen: TScreen;
  tbl: TTable;
  box: TBox;
  testsPassed: Boolean;
  maxPriority: TInt;

begin
  WriteLn('===========================================');
  WriteLn('Table Priority Test');
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
  WriteLn('[Test 1] GetMaxColumnPriority - Empty table');
  InitTable(tbl, screen, box);
  maxPriority := GetMaxColumnPriority(tbl);
  if maxPriority <> 0 then
  begin
    WriteLn('  FAILED: Expected 0, got ', maxPriority);
    testsPassed := False;
  end
  else
    WriteLn('  PASSED');

  { Test 2: Single column with priority 0 }
  WriteLn('[Test 2] GetMaxColumnPriority - Single column (priority 0)');
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);
  maxPriority := GetMaxColumnPriority(tbl);
  if maxPriority <> 0 then
  begin
    WriteLn('  FAILED: Expected 0, got ', maxPriority);
    testsPassed := False;
  end
  else
    WriteLn('  PASSED');

  { Test 3: Multiple columns with priority 0 }
  WriteLn('[Test 3] GetMaxColumnPriority - Multiple columns (all priority 0)');
  AddTableColumn(tbl, 'Col2', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col3', 10, 0, aLeft, 0);
  maxPriority := GetMaxColumnPriority(tbl);
  if maxPriority <> 0 then
  begin
    WriteLn('  FAILED: Expected 0, got ', maxPriority);
    testsPassed := False;
  end
  else
    WriteLn('  PASSED');
  FreeTable(tbl);

  { Test 4: Columns with different priorities }
  WriteLn('[Test 4] GetMaxColumnPriority - Mixed priorities (0, 1, 2)');
  InitTable(tbl, screen, box);
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 10, 0, aLeft, 1);
  AddTableColumn(tbl, 'Col3', 10, 0, aLeft, 2);
  maxPriority := GetMaxColumnPriority(tbl);
  if maxPriority <> 2 then
  begin
    WriteLn('  FAILED: Expected 2, got ', maxPriority);
    testsPassed := False;
  end
  else
    WriteLn('  PASSED');
  FreeTable(tbl);

  { Test 5: Columns with non-sequential priorities }
  WriteLn('[Test 5] GetMaxColumnPriority - Non-sequential priorities (0, 3, 1)');
  InitTable(tbl, screen, box);
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 10, 0, aLeft, 3);
  AddTableColumn(tbl, 'Col3', 10, 0, aLeft, 1);
  maxPriority := GetMaxColumnPriority(tbl);
  if maxPriority <> 3 then
  begin
    WriteLn('  FAILED: Expected 3, got ', maxPriority);
    testsPassed := False;
  end
  else
    WriteLn('  PASSED');
  FreeTable(tbl);

  { Test 6: High priority value }
  WriteLn('[Test 6] GetMaxColumnPriority - High priority value (100)');
  InitTable(tbl, screen, box);
  AddTableColumn(tbl, 'Col1', 10, 0, aLeft, 0);
  AddTableColumn(tbl, 'Col2', 10, 0, aLeft, 100);
  AddTableColumn(tbl, 'Col3', 10, 0, aLeft, 5);
  maxPriority := GetMaxColumnPriority(tbl);
  if maxPriority <> 100 then
  begin
    WriteLn('  FAILED: Expected 100, got ', maxPriority);
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