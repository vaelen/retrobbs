program AllListTests;

{
  Lists Test Suite

  Runs all test programs for the Lists unit.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  SysUtils, Process;

function RunTest(testName: String): Boolean;
var
  exitCode: Integer;
begin
  WriteLn('Running ', testName, '...');
  exitCode := ExecuteProcess('bin/tests/lists/' + testName, []);
  RunTest := (exitCode = 0);
  if exitCode = 0 then
    WriteLn('  PASSED')
  else
    WriteLn('  FAILED (exit code: ', exitCode, ')');
  WriteLn;
end;

var
  allPassed: Boolean;

begin
  WriteLn('===========================================');
  WriteLn('Lists Test Suite');
  WriteLn('===========================================');
  WriteLn;

  allPassed := True;

  if not RunTest('arraylst') then
    allPassed := False;

  if not RunTest('linkedl') then
    allPassed := False;

  WriteLn('===========================================');
  if allPassed then
  begin
    WriteLn('All tests PASSED');
    WriteLn('===========================================');
  end
  else
  begin
    WriteLn('Some tests FAILED');
    WriteLn('===========================================');
    Halt(1);
  end;
end.
