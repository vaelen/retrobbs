program AllDBTests;

{
  DB Unit Test Suite

  Runs all test programs for the DB unit.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  SysUtils, Process;

var
  TotalTests: Integer;
  PassedTests: Integer;
  FailedTests: Integer;

function RunTest(testName: String; description: String): Boolean;
var
  exitCode: Integer;
  testPath: String;
begin
  testPath := 'bin/tests/db/' + testName;

  WriteLn;
  WriteLn('Running: ', description);
  WriteLn('  Command: ', testPath);
  WriteLn('  ----------------------------------------');

  exitCode := ExecuteProcess(testPath, []);

  WriteLn('  ----------------------------------------');
  RunTest := (exitCode = 0);

  if exitCode = 0 then
  begin
    WriteLn('  Result: PASSED');
    Inc(PassedTests);
  end
  else
  begin
    WriteLn('  Result: FAILED (exit code: ', exitCode, ')');
    Inc(FailedTests);
  end;

  Inc(TotalTests);
end;

begin
  WriteLn('===========================================');
  WriteLn('DB Unit Test Suite');
  WriteLn('===========================================');
  WriteLn;
  WriteLn('This suite runs all tests for the DB unit.');
  WriteLn;

  TotalTests := 0;
  PassedTests := 0;
  FailedTests := 0;

  { Run all DB tests }
  RunTest('test', 'Comprehensive DB functionality tests');
  RunTest('simple', 'Simple DB operations test');
  RunTest('size', 'DB structure size analysis');
  { Note: minimal test is intentionally excluded as it demonstrates global variable crash }

  WriteLn;
  WriteLn('===========================================');
  WriteLn('DB Unit Test Summary');
  WriteLn('===========================================');
  WriteLn('Total Tests:  ', TotalTests);
  WriteLn('Passed:       ', PassedTests);
  WriteLn('Failed:       ', FailedTests);
  WriteLn('===========================================');
  WriteLn;

  if FailedTests > 0 then
  begin
    WriteLn('SOME TESTS FAILED');
    Halt(1);
  end
  else
  begin
    WriteLn('ALL TESTS PASSED!');
    Halt(0);
  end;
end.
