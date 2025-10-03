program TypeTest;

{
  BBSTypes Unit Test

  Tests the custom types and helper functions in the BBSTypes unit.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  BBSTypes, SysUtils;

var
  passed: Integer;
  failed: Integer;

procedure TestEpochConversions;
var
  unixTime, macTime, result: LongInt;
begin
  Write('Unix to Mac Epoch (0): ');
  { Unix epoch 0 = Jan 1, 1970 00:00:00 }
  { Should convert to 2082844800 in Mac epoch }
  macTime := UnixToMacEpoch(0);
  if macTime = 2082844800 then
  begin
    WriteLn('PASS (', macTime, ')');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (expected 2082844800, got ', macTime, ')');
    Inc(failed);
  end;

  Write('Mac to Unix Epoch (2082844800): ');
  { Mac epoch 2082844800 = Jan 1, 1970 00:00:00 }
  { Should convert to 0 in Unix epoch }
  unixTime := MacToUnixEpoch(2082844800);
  if unixTime = 0 then
  begin
    WriteLn('PASS (', unixTime, ')');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (expected 0, got ', unixTime, ')');
    Inc(failed);
  end;

  Write('Round-trip Unix->Mac->Unix: ');
  { Test round-trip conversion }
  unixTime := 1609459200; { Jan 1, 2021 00:00:00 UTC }
  macTime := UnixToMacEpoch(unixTime);
  result := MacToUnixEpoch(macTime);
  if result = unixTime then
  begin
    WriteLn('PASS (', unixTime, ' -> ', macTime, ' -> ', result, ')');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (expected ', unixTime, ', got ', result, ')');
    Inc(failed);
  end;

  Write('Round-trip Mac->Unix->Mac: ');
  { Test reverse round-trip conversion }
  { Mac epoch 2208988800 = Jan 1, 1974 00:00:00 UTC }
  macTime := 2208988800;
  unixTime := MacToUnixEpoch(macTime);
  result := UnixToMacEpoch(unixTime);
  if result = macTime then
  begin
    WriteLn('PASS (', macTime, ' -> ', unixTime, ' -> ', result, ')');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (expected ', macTime, ', got ', result, ')');
    Inc(failed);
  end;
end;

procedure TestTypeDefinitions;
var
  s255: Str255;
  s64: Str63;
  hash: SHA1Hash;
  uid: TUserID;
  ts: TBBSTimestamp;
begin
  Write('Type Str255 assignment: ');
  s255 := 'This is a test string for Str255 type which can hold up to 255 characters';
  if Length(s255) = 73 then
  begin
    WriteLn('PASS (length=', Length(s255), ')');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (expected length 73, got ', Length(s255), ')');
    Inc(failed);
  end;

  Write('Type Str63 assignment: ');
  s64 := 'Short string';
  if Length(s64) = 12 then
  begin
    WriteLn('PASS (length=', Length(s64), ')');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (expected length 12, got ', Length(s64), ')');
    Inc(failed);
  end;

  Write('Type SHA1Hash assignment: ');
  hash := 'da39a3ee5e6b4b0d3255bfef95601890afd80709';
  if Length(hash) = 40 then
  begin
    WriteLn('PASS (length=', Length(hash), ')');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (expected length 40, got ', Length(hash), ')');
    Inc(failed);
  end;

  Write('Type TUserID assignment: ');
  uid := 12345;
  if uid = 12345 then
  begin
    WriteLn('PASS (', uid, ')');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (expected 12345, got ', uid, ')');
    Inc(failed);
  end;

  Write('Type TBBSTimestamp assignment: ');
  ts := 2082844800; { Jan 1, 1970 in Mac epoch }
  if ts = 2082844800 then
  begin
    WriteLn('PASS (', ts, ')');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (expected 2082844800, got ', ts, ')');
    Inc(failed);
  end;
end;

begin
  passed := 0;
  failed := 0;

  WriteLn('BBSTypes Unit Test Suite');
  WriteLn('========================');
  WriteLn;

  { Test type definitions }
  WriteLn('Type Definitions:');
  TestTypeDefinitions;
  WriteLn;

  { Test epoch conversions }
  WriteLn('Epoch Conversions:');
  TestEpochConversions;
  WriteLn;

  { Summary }
  WriteLn('========================');
  WriteLn('Tests passed: ', passed);
  WriteLn('Tests failed: ', failed);

  if failed > 0 then
    Halt(1);
end.
