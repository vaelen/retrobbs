program PathTest;

{
  Path Unit Test

  Tests the Path unit's functionality for cross-OS path manipulation.
  Tests include:
  - Path separator detection
  - JoinPath with normal inputs
  - JoinPath with empty inputs
  - JoinPath with overflow (>255 chars)
}

uses
  Path, BBSTypes;

var
  result: Str255;
  testsPassed: Integer;
  testsFailed: Integer;

procedure Assert(condition: Boolean; testName: String);
begin
  if condition then
  begin
    WriteLn('  [PASS] ', testName);
    Inc(testsPassed);
  end
  else
  begin
    WriteLn('  [FAIL] ', testName);
    Inc(testsFailed);
  end;
end;

procedure TestPathSeparator;
begin
  WriteLn('Testing PathSeparator constant...');

  {$IFDEF UNIX}
    Assert(PathSeparator = '/', 'PathSeparator should be / on UNIX');
  {$ENDIF}

  {$IFDEF MSDOS}
    Assert(PathSeparator = '\', 'PathSeparator should be \ on DOS');
  {$ENDIF}

  {$IFDEF MACOS}
    Assert(PathSeparator = ':', 'PathSeparator should be : on Mac OS 7');
  {$ENDIF}

  { For the current platform, verify separator is one character }
  Assert(Length(PathSeparator) = 1, 'PathSeparator should be single character');

  WriteLn;
end;

procedure TestJoinPathNormal;
begin
  WriteLn('Testing JoinPath with normal inputs...');

  result := JoinPath('home', 'user');
  {$IFDEF UNIX}
    Assert(result = 'home/user', 'JoinPath(''home'', ''user'') on UNIX');
  {$ENDIF}
  {$IFDEF MSDOS}
    Assert(result = 'home\user', 'JoinPath(''home'', ''user'') on DOS');
  {$ENDIF}
  {$IFDEF MACOS}
    Assert(result = 'home:user', 'JoinPath(''home'', ''user'') on Mac OS 7');
  {$ENDIF}

  result := JoinPath('usr', 'local');
  Assert(Length(result) = 9, 'JoinPath(''usr'', ''local'') length check');

  result := JoinPath('a', 'b');
  Assert(Length(result) = 3, 'JoinPath(''a'', ''b'') length check');

  WriteLn;
end;

procedure TestJoinPathEmpty;
begin
  WriteLn('Testing JoinPath with empty inputs...');

  result := JoinPath('', 'child');
  Assert(result = 'child', 'JoinPath('''', ''child'') should return ''child''');

  result := JoinPath('parent', '');
  Assert(result = 'parent', 'JoinPath(''parent'', '''') should return ''parent''');

  result := JoinPath('', '');
  Assert(result = '', 'JoinPath('''', '''') should return empty string');

  WriteLn;
end;

procedure TestJoinPathOverflow;
var
  longPath: Str255;
  i: Integer;
begin
  WriteLn('Testing JoinPath with overflow (>255 chars)...');

  { Create a 200 character string }
  longPath := '';
  for i := 1 to 200 do
    longPath := longPath + 'x';

  { 200 + 1 (separator) + 55 = 256, should overflow }
  result := JoinPath(longPath, '12345678901234567890123456789012345678901234567890123456789012345');
  Assert(result = '', 'JoinPath should return empty string when result > 255 chars');

  { Test exactly 255 characters: 127 + 1 + 127 = 255 }
  longPath := '';
  for i := 1 to 127 do
    longPath := longPath + 'a';

  result := JoinPath(longPath, longPath);
  Assert(Length(result) = 255, 'JoinPath should handle exactly 255 chars');
  Assert(result <> '', 'JoinPath should not return empty for exactly 255 chars');

  { Test 254 characters: should work }
  longPath := '';
  for i := 1 to 126 do
    longPath := longPath + 'b';

  result := JoinPath(longPath, longPath);
  Assert(Length(result) = 253, 'JoinPath should handle 253 chars');

  WriteLn;
end;

procedure TestJoinPathEdgeCases;
begin
  WriteLn('Testing JoinPath edge cases...');

  { Single character paths }
  result := JoinPath('/', 'x');
  Assert(Length(result) = 3, 'JoinPath with single char parent');

  result := JoinPath('x', '/');
  Assert(Length(result) = 3, 'JoinPath with single char child');

  { Paths with spaces }
  result := JoinPath('my folder', 'sub folder');
  Assert(Length(result) = 20, 'JoinPath with spaces in names');

  { Paths with special characters }
  result := JoinPath('test-dir', 'file.txt');
  Assert(Length(result) = 17, 'JoinPath with dash and dot');

  WriteLn;
end;

begin
  testsPassed := 0;
  testsFailed := 0;

  WriteLn('===========================================');
  WriteLn('Path Unit Tests');
  WriteLn('===========================================');
  WriteLn;

  TestPathSeparator;
  TestJoinPathNormal;
  TestJoinPathEmpty;
  TestJoinPathOverflow;
  TestJoinPathEdgeCases;

  WriteLn('===========================================');
  WriteLn('Test Results:');
  WriteLn('  Passed: ', testsPassed);
  WriteLn('  Failed: ', testsFailed);
  WriteLn('===========================================');

  if testsFailed > 0 then
    Halt(1)
  else
    Halt(0);
end.
