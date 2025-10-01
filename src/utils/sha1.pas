program SHA1Util;

{
  SHA1 Utility Program

  Calculates SHA-1 hash for files.
  Outputs the result as a hexadecimal number.

  Usage:
    sha1 <filename>    - Calculate SHA-1 hash of file

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  Hash, SysUtils;

const
  BUFFER_SIZE = 4096;

var
  f: File of Byte;
  buffer: array[0..BUFFER_SIZE-1] of Byte;
  bytesRead: Integer;
  ctx: TSHA1Context;
  digest: TSHA1Digest;
  i: Integer;

begin
  if ParamCount <> 1 then
  begin
    WriteLn(StdErr, 'Usage: sha1 <filename>');
    Halt(1);
  end;

  { Initialize SHA-1 context }
  SHA1Start(ctx);

  { Read from file }
  Assign(f, ParamStr(1));
  {$I-}
  Reset(f);
  {$I+}

  if IOResult <> 0 then
  begin
    WriteLn(StdErr, 'Error: Cannot open file ', ParamStr(1));
    Halt(1);
  end;

  while not EOF(f) do
  begin
    bytesRead := 0;
    while (not EOF(f)) and (bytesRead < BUFFER_SIZE) do
    begin
      Read(f, buffer[bytesRead]);
      Inc(bytesRead);
    end;

    { Process buffer }
    SHA1Add(ctx, buffer, bytesRead);
  end;

  Close(f);

  { Finalize and get digest }
  SHA1End(ctx, digest);

  { Output as hexadecimal }
  for i := 0 to 19 do
    Write(LowerCase(IntToHex(digest[i], 2)));
  WriteLn;
end.
