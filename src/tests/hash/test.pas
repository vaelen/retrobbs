program HashTest;

{
  Hash Library Test Suite

  Tests the CRC functions in the Hash unit against known test vectors.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  Hash, SysUtils;

var
  passed: Integer;
  failed: Integer;

{ Helper to convert static array to dynamic array }
procedure CopyToDynamic(const src: array of Byte; var dest: TByteArray; len: Integer);
var
  i: Integer;
begin
  for i := 0 to len - 1 do
    dest[i] := src[i];
end;

procedure TestCRC16;
const
  testVec1: array[0..14] of Byte = ($54, $68, $69, $73, $20, $69, $73, $20,
                                     $61, $20, $74, $65, $73, $74, $0A);
  testVec2: array[0..8] of Byte = ($31, $32, $33, $34, $35, $36, $37, $38, $39);
var
  crc: Word;
  data: array[0..14] of Byte;
  i: Integer;
begin
  Write('CRC16 (CRC-16/KERMIT): ');

  { Copy test vector }
  for i := 0 to 14 do
    data[i] := testVec1[i];

  crc := CRC16(data, 15);

  if crc = $FADF then
  begin
    WriteLn('PASS (0x', IntToHex(crc, 4), ')');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (expected 0xFADF, got 0x', IntToHex(crc, 4), ')');
    Inc(failed);
  end;

  { Test check value: 0x2189 }
  Write('CRC16 Check Value: ');
  for i := 0 to 8 do
    data[i] := testVec2[i];

  crc := CRC16(data, 9);

  if crc = $2189 then
  begin
    WriteLn('PASS (0x', IntToHex(crc, 4), ')');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (expected 0x2189, got 0x', IntToHex(crc, 4), ')');
    Inc(failed);
  end;
end;

procedure TestCRC16X;
const
  testVec1: array[0..14] of Byte = ($54, $68, $69, $73, $20, $69, $73, $20,
                                     $61, $20, $74, $65, $73, $74, $0A);
  testVec2: array[0..8] of Byte = ($31, $32, $33, $34, $35, $36, $37, $38, $39);
var
  crc: Word;
  data: array[0..14] of Byte;
  i: Integer;
begin
  Write('CRC16X (CRC-16/XMODEM): ');

  { Copy test vector }
  for i := 0 to 14 do
    data[i] := testVec1[i];

  crc := CRC16X(data, 15);

  if crc = $88FB then
  begin
    WriteLn('PASS (0x', IntToHex(crc, 4), ')');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (expected 0x88FB, got 0x', IntToHex(crc, 4), ')');
    Inc(failed);
  end;

  { Test check value: 0x31C3 }
  Write('CRC16X Check Value: ');
  for i := 0 to 8 do
    data[i] := testVec2[i];

  crc := CRC16X(data, 9);

  if crc = $31C3 then
  begin
    WriteLn('PASS (0x', IntToHex(crc, 4), ')');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (expected 0x31C3, got 0x', IntToHex(crc, 4), ')');
    Inc(failed);
  end;
end;

procedure TestCRC16Incremental;
const
  part1Const: array[0..4] of Byte = ($31, $32, $33, $34, $35);
  part2Const: array[0..3] of Byte = ($36, $37, $38, $39);
var
  crc: Word;
  part1: array[0..4] of Byte;
  part2: array[0..3] of Byte;
  i: Integer;
begin
  Write('CRC16 Incremental: ');

  { Copy data }
  for i := 0 to 4 do
    part1[i] := part1Const[i];
  for i := 0 to 3 do
    part2[i] := part2Const[i];

  CRC16Start(crc, part1, 5);
  CRC16Add(crc, part2, 4);
  CRC16End(crc);

  if crc = $2189 then
  begin
    WriteLn('PASS (0x', IntToHex(crc, 4), ')');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (expected 0x2189, got 0x', IntToHex(crc, 4), ')');
    Inc(failed);
  end;
end;

procedure TestCRC16XIncremental;
const
  part1Const: array[0..4] of Byte = ($31, $32, $33, $34, $35);
  part2Const: array[0..3] of Byte = ($36, $37, $38, $39);
var
  crc: Word;
  part1: array[0..4] of Byte;
  part2: array[0..3] of Byte;
  i: Integer;
begin
  Write('CRC16X Incremental: ');

  { Copy data }
  for i := 0 to 4 do
    part1[i] := part1Const[i];
  for i := 0 to 3 do
    part2[i] := part2Const[i];

  CRC16XStart(crc, part1, 5);
  CRC16XAdd(crc, part2, 4);
  CRC16XEnd(crc);

  if crc = $31C3 then
  begin
    WriteLn('PASS (0x', IntToHex(crc, 4), ')');
    Inc(passed);
  end
  else
  begin
    WriteLn('FAIL (expected 0x31C3, got 0x', IntToHex(crc, 4), ')');
    Inc(failed);
  end;
end;

procedure TestSHA1;
const
  { "The quick brown fox jumps over the lazy dog" - 43 bytes }
  testVec1: array[0..42] of Byte = (
    $54, $68, $65, $20, $71, $75, $69, $63, $6B, $20, $62, $72, $6F, $77, $6E, $20,
    $66, $6F, $78, $20, $6A, $75, $6D, $70, $73, $20, $6F, $76, $65, $72, $20, $74,
    $68, $65, $20, $6C, $61, $7A, $79, $20, $64, $6F, $67
  );
  { Expected: 2fd4e1c67a2d28fced849ee1bb76e7391b93eb12 }
  expectedVec1: array[0..19] of Byte = (
    $2F, $D4, $E1, $C6, $7A, $2D, $28, $FC, $ED, $84,
    $9E, $E1, $BB, $76, $E7, $39, $1B, $93, $EB, $12
  );
  { Empty string }
  { Expected: da39a3ee5e6b4b0d3255bfef95601890afd80709 }
  expectedEmpty: array[0..19] of Byte = (
    $DA, $39, $A3, $EE, $5E, $6B, $4B, $0D, $32, $55,
    $BF, $EF, $95, $60, $18, $90, $AF, $D8, $07, $09
  );
var
  digest: TSHA1Digest;
  data: array[0..42] of Byte;
  i: Integer;
  match: Boolean;
begin
  Write('SHA1 Test Vector 1: ');

  { Copy test vector }
  for i := 0 to 42 do
    data[i] := testVec1[i];

  digest := SHA1(data, 43);

  match := True;
  for i := 0 to 19 do
    if digest[i] <> expectedVec1[i] then
      match := False;

  if match then
  begin
    Write('PASS (');
    for i := 0 to 19 do
      Write(LowerCase(IntToHex(digest[i], 2)));
    WriteLn(')');
    Inc(passed);
  end
  else
  begin
    Write('FAIL (expected 2fd4e1c67a2d28fced849ee1bb76e7391b93eb12, got ');
    for i := 0 to 19 do
      Write(LowerCase(IntToHex(digest[i], 2)));
    WriteLn(')');
    Inc(failed);
  end;

  { Test empty string }
  Write('SHA1 Empty String: ');
  digest := SHA1(data, 0);

  match := True;
  for i := 0 to 19 do
    if digest[i] <> expectedEmpty[i] then
      match := False;

  if match then
  begin
    Write('PASS (');
    for i := 0 to 19 do
      Write(LowerCase(IntToHex(digest[i], 2)));
    WriteLn(')');
    Inc(passed);
  end
  else
  begin
    Write('FAIL (expected da39a3ee5e6b4b0d3255bfef95601890afd80709, got ');
    for i := 0 to 19 do
      Write(LowerCase(IntToHex(digest[i], 2)));
    WriteLn(')');
    Inc(failed);
  end;
end;

procedure TestSHA1Incremental;
const
  { "The quick brown fox jumps over the lazy dog" split in two }
  { Part 1: "The quick brown fox " - 20 bytes }
  part1Const: array[0..19] of Byte = (
    $54, $68, $65, $20, $71, $75, $69, $63, $6B, $20,
    $62, $72, $6F, $77, $6E, $20, $66, $6F, $78, $20
  );
  { Part 2: "jumps over the lazy dog" - 23 bytes }
  part2Const: array[0..22] of Byte = (
    $6A, $75, $6D, $70, $73, $20, $6F, $76, $65, $72, $20, $74,
    $68, $65, $20, $6C, $61, $7A, $79, $20, $64, $6F, $67
  );
  { Expected for "The quick brown fox jumps over the lazy dog": }
  { 2fd4e1c67a2d28fced849ee1bb76e7391b93eb12 }
  expected: array[0..19] of Byte = (
    $2F, $D4, $E1, $C6, $7A, $2D, $28, $FC, $ED, $84,
    $9E, $E1, $BB, $76, $E7, $39, $1B, $93, $EB, $12
  );
var
  ctx: TSHA1Context;
  digest: TSHA1Digest;
  part1: array[0..19] of Byte;
  part2: array[0..22] of Byte;
  i: Integer;
  match: Boolean;
begin
  Write('SHA1 Incremental: ');

  { Copy data }
  for i := 0 to 19 do
    part1[i] := part1Const[i];
  for i := 0 to 22 do
    part2[i] := part2Const[i];

  SHA1Start(ctx);
  SHA1Add(ctx, part1, 20);
  SHA1Add(ctx, part2, 23);
  SHA1End(ctx, digest);

  match := True;
  for i := 0 to 19 do
    if digest[i] <> expected[i] then
      match := False;

  if match then
  begin
    Write('PASS (');
    for i := 0 to 19 do
      Write(LowerCase(IntToHex(digest[i], 2)));
    WriteLn(')');
    Inc(passed);
  end
  else
  begin
    Write('FAIL (expected 2fd4e1c67a2d28fced849ee1bb76e7391b93eb12, got ');
    for i := 0 to 19 do
      Write(LowerCase(IntToHex(digest[i], 2)));
    WriteLn(')');
    Inc(failed);
  end;
end;

begin
  passed := 0;
  failed := 0;

  WriteLn('Hash Library Test Suite');
  WriteLn('========================');
  WriteLn;

  { Test CRC16 }
  TestCRC16;
  TestCRC16Incremental;
  WriteLn;

  { Test CRC16X }
  TestCRC16X;
  TestCRC16XIncremental;
  WriteLn;

  { Test SHA1 }
  TestSHA1;
  TestSHA1Incremental;
  WriteLn;

  { Summary }
  WriteLn('========================');
  WriteLn('Tests passed: ', passed);
  WriteLn('Tests failed: ', failed);

  if failed > 0 then
    Halt(1);
end.
