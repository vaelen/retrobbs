program CRC16XUtil;

{
  CRC16X Utility Program

  Calculates CRC-16/XMODEM (ZMODEM) checksum for files.
  Outputs the result as a hexadecimal number.

  Usage:
    crc16x <filename>   - Calculate CRC16X of file

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  BBSTypes, Hash, SysUtils;

const
  BUFFER_SIZE = 4096;

var
  f: File of Byte;
  buffer: array[0..BUFFER_SIZE-1] of Byte;
  bytesRead: TInt;
  crc: TWord;
  i: TInt;
  idx: Byte;

const
  { CRC-16/XMODEM (ZMODEM) Table }
  CRC16X_TABLE: array[0..255] of TWord = (
    $0000, $1021, $2042, $3063, $4084, $50A5, $60C6, $70E7,
    $8108, $9129, $A14A, $B16B, $C18C, $D1AD, $E1CE, $F1EF,
    $1231, $0210, $3273, $2252, $52B5, $4294, $72F7, $62D6,
    $9339, $8318, $B37B, $A35A, $D3BD, $C39C, $F3FF, $E3DE,
    $2462, $3443, $0420, $1401, $64E6, $74C7, $44A4, $5485,
    $A56A, $B54B, $8528, $9509, $E5EE, $F5CF, $C5AC, $D58D,
    $3653, $2672, $1611, $0630, $76D7, $66F6, $5695, $46B4,
    $B75B, $A77A, $9719, $8738, $F7DF, $E7FE, $D79D, $C7BC,
    $48C4, $58E5, $6886, $78A7, $0840, $1861, $2802, $3823,
    $C9CC, $D9ED, $E98E, $F9AF, $8948, $9969, $A90A, $B92B,
    $5AF5, $4AD4, $7AB7, $6A96, $1A71, $0A50, $3A33, $2A12,
    $DBFD, $CBDC, $FBBF, $EB9E, $9B79, $8B58, $BB3B, $AB1A,
    $6CAC, $7C8D, $4CEE, $5CCF, $2C28, $3C09, $0C6A, $1C4B,
    $EDA4, $FD85, $CDE6, $DDC7, $AD20, $BD01, $8D62, $9D43,
    $7E9D, $6EBC, $5EDF, $4EFE, $3E19, $2E38, $1E5B, $0E7A,
    $FF95, $EFB4, $DFD7, $CFF6, $BF11, $AF30, $9F53, $8F72,
    $91A8, $8189, $B1EA, $A1CB, $D12C, $C10D, $F16E, $E14F,
    $10A0, $0081, $30E2, $20C3, $5024, $4005, $7066, $6047,
    $83B9, $9398, $A3FB, $B3DA, $C33D, $D31C, $E37F, $F35E,
    $02B1, $1290, $22F3, $32D2, $4235, $5214, $6277, $7256,
    $B5E0, $A5C1, $95A2, $8583, $F564, $E545, $D526, $C507,
    $34E8, $24C9, $14AA, $048B, $746C, $644D, $542E, $440F,
    $A7D1, $B7F0, $8793, $97B2, $E755, $F774, $C717, $D736,
    $26D9, $36F8, $069B, $16BA, $665D, $767C, $461F, $563E,
    $D94C, $C96D, $F90E, $E92F, $99C8, $89E9, $B98A, $A9AB,
    $5844, $4865, $7806, $6827, $18C0, $08E1, $3882, $28A3,
    $CB7D, $DB5C, $EB3F, $FB1E, $8BF9, $9BD8, $ABBB, $BB9A,
    $4A75, $5A54, $6A37, $7A16, $0AF1, $1AD0, $2AB3, $3A92,
    $FD24, $ED05, $DD66, $CD47, $BDA0, $AD81, $9DE2, $8DC3,
    $7C2C, $6C0D, $5C6E, $4C4F, $3CA8, $2C89, $1CEA, $0CCB,
    $EF15, $FF34, $CF57, $DF76, $AF91, $BFB0, $8FD3, $9FF2,
    $6E1D, $7E3C, $4E5F, $5E7E, $2E99, $3EB8, $0EDB, $1EFA
  );

begin
  if ParamCount <> 1 then
  begin
    WriteLn(StdErr, 'Usage: crc16x <filename>');
    Halt(1);
  end;

  { Initialize CRC }
  crc := $0000;

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
    for i := 0 to bytesRead - 1 do
    begin
      idx := Byte(crc shr 8) xor buffer[i];
      crc := (crc shl 8) xor CRC16X_TABLE[idx];
    end;
  end;

  Close(f);

  WriteLn(IntToHex(crc, 4));
end.
