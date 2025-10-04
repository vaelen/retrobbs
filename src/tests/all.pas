program AllTests;

{
  Master Test Suite

  Runs all unit test programs for RetroBBS.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  SysUtils, Process;

var
  TotalTests: Integer;
  PassedTests: Integer;
  FailedTests: Integer;

function RunTest(testPath: String; description: String): Boolean;
var
  exitCode: Integer;
begin
  WriteLn;
  WriteLn('Running: ', description);
  WriteLn('  Command: ', testPath);
  WriteLn('  ========================================');

  exitCode := ExecuteProcess(testPath, []);

  WriteLn('  ========================================');
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
  WriteLn('RetroBBS Master Test Suite');
  WriteLn('===========================================');
  WriteLn;
  WriteLn('This suite runs all unit tests.');
  WriteLn;

  TotalTests := 0;
  PassedTests := 0;
  FailedTests := 0;

  { Run all unit tests }
  RunTest('bin/tests/bbstypes/test', 'BBSTypes Unit Tests');
  RunTest('bin/tests/hash/test', 'Hash Unit Tests');
  RunTest('bin/tests/ansi/test', 'ANSI Unit Tests');
  RunTest('bin/tests/btree/test', 'BTree Unit Tests');
  RunTest('bin/tests/path/test', 'Path Unit Tests');
  RunTest('bin/tests/user/test', 'User Unit Tests');
  RunTest('bin/tests/db/test', 'DB Unit Tests');

  WriteLn;
  WriteLn('===========================================');
  WriteLn('Master Test Suite Summary');
  WriteLn('===========================================');
  WriteLn('Total Test Suites:  ', TotalTests);
  WriteLn('Passed:             ', PassedTests);
  WriteLn('Failed:             ', FailedTests);
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
