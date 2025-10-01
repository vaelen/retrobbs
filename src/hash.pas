unit Hash;

{
  CRC and Hashing Library

  Implements CRC and hashing functions needed for other parts of the system,
  such as password hashing or file transfers.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

interface

type
  TByteArray = array of Byte;

{ CRC-16/KERMIT (CCITT) Functions }
function CRC16(const data; len: Integer): Word;
function CRC16Start(var crc: Word; const data; len: Integer): Word;
function CRC16Add(var crc: Word; const data; len: Integer): Word;
function CRC16End(var crc: Word): Word;

{ CRC-16/XMODEM (ZMODEM) Functions }
function CRC16X(const data; len: Integer): Word;
function CRC16XStart(var crc: Word; const data; len: Integer): Word;
function CRC16XAdd(var crc: Word; const data; len: Integer): Word;
function CRC16XEnd(var crc: Word): Word;

{ CRC-32/CKSUM (POSIX) Functions }
function CRC32(const data; len: Integer): LongWord;
function CRC32Start(var crc: LongWord; var totalLen: LongWord; const data; len: Integer): LongWord;
function CRC32Add(var crc: LongWord; var totalLen: LongWord; const data; len: Integer): LongWord;
function CRC32End(var crc: LongWord; totalLen: LongWord): LongWord;

{ SHA-1 Hash Functions }
type
  TSHA1Digest = array[0..19] of Byte;
  TSHA1Context = record
    h0, h1, h2, h3, h4: LongWord;
    messageLen: QWord;
    bufferLen: Integer;
    buffer: array[0..63] of Byte;
  end;

function SHA1(const data; len: Integer): TSHA1Digest;
procedure SHA1Start(var ctx: TSHA1Context);
procedure SHA1Add(var ctx: TSHA1Context; const data; len: Integer);
procedure SHA1End(var ctx: TSHA1Context; var digest: TSHA1Digest);

implementation

const
  { CRC-16/KERMIT (CCITT) Table }
  CRC16_KERMIT_TABLE: array[0..255] of Word = (
    $0000, $1189, $2312, $329B, $4624, $57AD, $6536, $74BF,
    $8C48, $9DC1, $AF5A, $BED3, $CA6C, $DBE5, $E97E, $F8F7,
    $1081, $0108, $3393, $221A, $56A5, $472C, $75B7, $643E,
    $9CC9, $8D40, $BFDB, $AE52, $DAED, $CB64, $F9FF, $E876,
    $2102, $308B, $0210, $1399, $6726, $76AF, $4434, $55BD,
    $AD4A, $BCC3, $8E58, $9FD1, $EB6E, $FAE7, $C87C, $D9F5,
    $3183, $200A, $1291, $0318, $77A7, $662E, $54B5, $453C,
    $BDCB, $AC42, $9ED9, $8F50, $FBEF, $EA66, $D8FD, $C974,
    $4204, $538D, $6116, $709F, $0420, $15A9, $2732, $36BB,
    $CE4C, $DFC5, $ED5E, $FCD7, $8868, $99E1, $AB7A, $BAF3,
    $5285, $430C, $7197, $601E, $14A1, $0528, $37B3, $263A,
    $DECD, $CF44, $FDDF, $EC56, $98E9, $8960, $BBFB, $AA72,
    $6306, $728F, $4014, $519D, $2522, $34AB, $0630, $17B9,
    $EF4E, $FEC7, $CC5C, $DDD5, $A96A, $B8E3, $8A78, $9BF1,
    $7387, $620E, $5095, $411C, $35A3, $242A, $16B1, $0738,
    $FFCF, $EE46, $DCDD, $CD54, $B9EB, $A862, $9AF9, $8B70,
    $8408, $9581, $A71A, $B693, $C22C, $D3A5, $E13E, $F0B7,
    $0840, $19C9, $2B52, $3ADB, $4E64, $5FED, $6D76, $7CFF,
    $9489, $8500, $B79B, $A612, $D2AD, $C324, $F1BF, $E036,
    $18C1, $0948, $3BD3, $2A5A, $5EE5, $4F6C, $7DF7, $6C7E,
    $A50A, $B483, $8618, $9791, $E32E, $F2A7, $C03C, $D1B5,
    $2942, $38CB, $0A50, $1BD9, $6F66, $7EEF, $4C74, $5DFD,
    $B58B, $A402, $9699, $8710, $F3AF, $E226, $D0BD, $C134,
    $39C3, $284A, $1AD1, $0B58, $7FE7, $6E6E, $5CF5, $4D7C,
    $C60C, $D785, $E51E, $F497, $8028, $91A1, $A33A, $B2B3,
    $4A44, $5BCD, $6956, $78DF, $0C60, $1DE9, $2F72, $3EFB,
    $D68D, $C704, $F59F, $E416, $90A9, $8120, $B3BB, $A232,
    $5AC5, $4B4C, $79D7, $685E, $1CE1, $0D68, $3FF3, $2E7A,
    $E70E, $F687, $C41C, $D595, $A12A, $B0A3, $8238, $93B1,
    $6B46, $7ACF, $4854, $59DD, $2D62, $3CEB, $0E70, $1FF9,
    $F78F, $E606, $D49D, $C514, $B1AB, $A022, $92B9, $8330,
    $7BC7, $6A4E, $58D5, $495C, $3DE3, $2C6A, $1EF1, $0F78
  );

  { CRC-16/XMODEM (ZMODEM) Table }
  CRC16_XMODEM_TABLE: array[0..255] of Word = (
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
    $6CA6, $7C87, $4CE4, $5CC5, $2C22, $3C03, $0C60, $1C41,
    $EDAE, $FD8F, $CDEC, $DDCD, $AD2A, $BD0B, $8D68, $9D49,
    $7E97, $6EB6, $5ED5, $4EF4, $3E13, $2E32, $1E51, $0E70,
    $FF9F, $EFBE, $DFDD, $CFFC, $BF1B, $AF3A, $9F59, $8F78,
    $9188, $81A9, $B1CA, $A1EB, $D10C, $C12D, $F14E, $E16F,
    $1080, $00A1, $30C2, $20E3, $5004, $4025, $7046, $6067,
    $83B9, $9398, $A3FB, $B3DA, $C33D, $D31C, $E37F, $F35E,
    $02B1, $1290, $22F3, $32D2, $4235, $5214, $6277, $7256,
    $B5EA, $A5CB, $95A8, $8589, $F56E, $E54F, $D52C, $C50D,
    $34E2, $24C3, $14A0, $0481, $7466, $6447, $5424, $4405,
    $A7DB, $B7FA, $8799, $97B8, $E75F, $F77E, $C71D, $D73C,
    $26D3, $36F2, $0691, $16B0, $6657, $7676, $4615, $5634,
    $D94C, $C96D, $F90E, $E92F, $99C8, $89E9, $B98A, $A9AB,
    $5844, $4865, $7806, $6827, $18C0, $08E1, $3882, $28A3,
    $CB7D, $DB5C, $EB3F, $FB1E, $8BF9, $9BD8, $ABBB, $BB9A,
    $4A75, $5A54, $6A37, $7A16, $0AF1, $1AD0, $2AB3, $3A92,
    $FD2E, $ED0F, $DD6C, $CD4D, $BDAA, $AD8B, $9DE8, $8DC9,
    $7C26, $6C07, $5C64, $4C45, $3CA2, $2C83, $1CE0, $0CC1,
    $EF1F, $FF3E, $CF5D, $DF7C, $AF9B, $BFBA, $8FD9, $9FF8,
    $6E17, $7E36, $4E55, $5E74, $2E93, $3EB2, $0ED1, $1EF0
  );

  { CRC-32/CKSUM (POSIX) Table }
  CRC32_TABLE: array[0..255] of LongWord = (
    $00000000, $04C11DB7, $09823B6E, $0D4326D9, $130476DC, $17C56B6B, $1A864DB2, $1E475005,
    $2608EDB8, $22C9F00F, $2F8AD6D6, $2B4BCB61, $350C9B64, $31CD86D3, $3C8EA00A, $384FBDBD,
    $4C11DB70, $48D0C6C7, $4593E01E, $4152FDA9, $5F15ADAC, $5BD4B01B, $569796C2, $52568B75,
    $6A1936C8, $6ED82B7F, $639B0DA6, $675A1011, $791D4014, $7DDC5DA3, $709F7B7A, $745E66CD,
    $9823B6E0, $9CE2AB57, $91A18D8E, $95609039, $8B27C03C, $8FE6DD8B, $82A5FB52, $8664E6E5,
    $BE2B5B58, $BAEA46EF, $B7A96036, $B3687D81, $AD2F2D84, $A9EE3033, $A4AD16EA, $A06C0B5D,
    $D4326D90, $D0F37027, $DDB056FE, $D9714B49, $C7361B4C, $C3F706FB, $CEB42022, $CA753D95,
    $F23A8028, $F6FB9D9F, $FBB8BB46, $FF79A6F1, $E13EF6F4, $E5FFEB43, $E8BCCD9A, $EC7DD02D,
    $34867077, $30476DC0, $3D044B19, $39C556AE, $278206AB, $23431B1C, $2E003DC5, $2AC12072,
    $128E9DCF, $164F8078, $1B0CA6A1, $1FCDBB16, $018AEB13, $054BF6A4, $0808D07D, $0CC9CDCA,
    $7897AB07, $7C56B6B0, $71159069, $75D48DDE, $6B93DDDB, $6F52C06C, $6211E6B5, $66D0FB02,
    $5E9F46BF, $5A5E5B08, $571D7DD1, $53DC6066, $4D9B3063, $495A2DD4, $44190B0D, $40D816BA,
    $ACA5C697, $A864DB20, $A527FDF9, $A1E6E04E, $BFA1B04B, $BB60ADFC, $B6238B25, $B2E29692,
    $8AAD2B2F, $8E6C3698, $832F1041, $87EE0DF6, $99A95DF3, $9D684044, $902B669D, $94EA7B2A,
    $E0B41DE7, $E4750050, $E9362689, $EDF73B3E, $F3B06B3B, $F771768C, $FA325055, $FEF34DE2,
    $C6BCF05F, $C27DEDE8, $CF3ECB31, $CBFFD686, $D5B88683, $D1799B34, $DC3ABDED, $D8FBA05A,
    $690CE0EE, $6DCDFD59, $608EDB80, $644FC637, $7A089632, $7EC98B85, $738AAD5C, $774BB0EB,
    $4F040D56, $4BC510E1, $46863638, $42472B8F, $5C007B8A, $58C1663D, $558240E4, $51435D53,
    $251D3B9E, $21DC2629, $2C9F00F0, $285E1D47, $36194D42, $32D850F5, $3F9B762C, $3B5A6B9B,
    $0315D626, $07D4CB91, $0A97ED48, $0E56F0FF, $1011A0FA, $14D0BD4D, $19939B94, $1D528623,
    $F12F560E, $F5EE4BB9, $F8AD6D60, $FC6C70D7, $E22B20D2, $E6EA3D65, $EBA91BBC, $EF68060B,
    $D727BBB6, $D3E6A601, $DEA580D8, $DA649D6F, $C423CD6A, $C0E2D0DD, $CDA1F604, $C960EBB3,
    $BD3E8D7E, $B9FF90C9, $B4BCB610, $B07DABA7, $AE3AFBA2, $AAFBE615, $A7B8C0CC, $A379DD7B,
    $9B3660C6, $9FF77D71, $92B45BA8, $9675461F, $8832161A, $8CF30BAD, $81B02D74, $857130C3,
    $5D8A9099, $594B8D2E, $5408ABF7, $50C9B640, $4E8EE645, $4A4FFBF2, $470CDD2B, $43CDC09C,
    $7B827D21, $7F436096, $7200464F, $76C15BF8, $68860BFD, $6C47164A, $61043093, $65C52D24,
    $119B4BE9, $155A565E, $18197087, $1CD86D30, $029F3D35, $065E2082, $0B1D065B, $0FDC1BEC,
    $3793A651, $3352BBE6, $3E119D3F, $3AD08088, $2497D08D, $2056CD3A, $2D15EBE3, $29D4F654,
    $C5A92679, $C1683BCE, $CC2B1D17, $C8EA00A0, $D6AD50A5, $D26C4D12, $DF2F6BCB, $DBEE767C,
    $E3A1CBC1, $E760D676, $EA23F0AF, $EEE2ED18, $F0A5BD1D, $F464A0AA, $F9278673, $FDE69BC4,
    $89B8FD09, $8D79E0BE, $803AC667, $84FBDBD0, $9ABC8BD5, $9E7D9662, $933EB0BB, $97FFAD0C,
    $AFB010B1, $AB710D06, $A6322BDF, $A2F33668, $BCB4666D, $B8757BDA, $B5365D03, $B1F740B4
  );

{ Helper functions - not currently used but left for reference }
{
function ReflectByte(b: Byte): Byte;
var
  i: Integer;
  r: Byte;
begin
  r := 0;
  for i := 0 to 7 do
  begin
    if (b and (1 shl i)) <> 0 then
      r := r or (1 shl (7 - i));
  end;
  ReflectByte := r;
end;

function ReflectWord(w: Word): Word;
var
  i: Integer;
  r: Word;
begin
  r := 0;
  for i := 0 to 15 do
  begin
    if (w and (1 shl i)) <> 0 then
      r := r or (1 shl (15 - i));
  end;
  ReflectWord := r;
end;
}

{ CRC-16/KERMIT (CCITT) Implementation }

function CRC16(const data; len: Integer): Word;
var
  crc: Word;
begin
  CRC16Start(crc, data, len);
  CRC16 := CRC16End(crc);
end;

function CRC16Start(var crc: Word; const data; len: Integer): Word;
begin
  crc := $0000;
  CRC16Start := CRC16Add(crc, data, len);
end;

function CRC16Add(var crc: Word; const data; len: Integer): Word;
type
  PByte = ^Byte;
var
  i: Integer;
  idx: Byte;
  p: PByte;
begin
  p := @data;
  for i := 0 to len - 1 do
  begin
    idx := Byte(crc) xor p^;
    crc := (crc shr 8) xor CRC16_KERMIT_TABLE[idx];
    Inc(p);
  end;
  CRC16Add := crc;
end;

function CRC16End(var crc: Word): Word;
begin
  CRC16End := crc;
end;

{ CRC-16/XMODEM (ZMODEM) Implementation }

function CRC16X(const data; len: Integer): Word;
var
  crc: Word;
begin
  CRC16XStart(crc, data, len);
  CRC16X := CRC16XEnd(crc);
end;

function CRC16XStart(var crc: Word; const data; len: Integer): Word;
begin
  crc := $0000;
  CRC16XStart := CRC16XAdd(crc, data, len);
end;

function CRC16XAdd(var crc: Word; const data; len: Integer): Word;
type
  PByte = ^Byte;
var
  i: Integer;
  idx: Byte;
  p: PByte;
begin
  p := @data;
  for i := 0 to len - 1 do
  begin
    idx := Byte(crc shr 8) xor p^;
    crc := (crc shl 8) xor CRC16_XMODEM_TABLE[idx];
    Inc(p);
  end;
  CRC16XAdd := crc;
end;

function CRC16XEnd(var crc: Word): Word;
begin
  CRC16XEnd := crc;
end;

{ CRC-32/CKSUM (POSIX) Implementation }

function CRC32(const data; len: Integer): LongWord;
var
  crc: LongWord;
  totalLen: LongWord;
begin
  CRC32Start(crc, totalLen, data, len);
  CRC32 := CRC32End(crc, totalLen);
end;

function CRC32Start(var crc: LongWord; var totalLen: LongWord; const data; len: Integer): LongWord;
begin
  crc := $00000000;
  totalLen := 0;
  CRC32Start := CRC32Add(crc, totalLen, data, len);
end;

function CRC32Add(var crc: LongWord; var totalLen: LongWord; const data; len: Integer): LongWord;
type
  PByte = ^Byte;
var
  i: Integer;
  idx: Byte;
  p: PByte;
begin
  p := @data;
  for i := 0 to len - 1 do
  begin
    idx := Byte((crc shr 24) xor p^);
    crc := (crc shl 8) xor CRC32_TABLE[idx];
    Inc(p);
  end;
  Inc(totalLen, len);
  CRC32Add := crc;
end;

function CRC32End(var crc: LongWord; totalLen: LongWord): LongWord;
var
  i: Integer;
begin
  { For POSIX cksum, append length }
  for i := 0 to 3 do
  begin
    crc := (crc shl 8) xor CRC32_TABLE[Byte(crc shr 24) xor Byte(totalLen shr (8 * (3 - i)))];
  end;
  CRC32End := not crc;
end;

{ SHA-1 Implementation }

{ Helper function to rotate left }
function RotateLeft(value: LongWord; bits: Integer): LongWord; inline;
begin
  RotateLeft := (value shl bits) or (value shr (32 - bits));
end;

{ Process a 512-bit block }
procedure SHA1ProcessBlock(var ctx: TSHA1Context);
var
  w: array[0..79] of LongWord;
  a, b, c, d, e, f, k, temp: LongWord;
  i, t: Integer;
begin
  { Prepare message schedule }
  for i := 0 to 15 do
  begin
    w[i] := (LongWord(ctx.buffer[i * 4]) shl 24) or
            (LongWord(ctx.buffer[i * 4 + 1]) shl 16) or
            (LongWord(ctx.buffer[i * 4 + 2]) shl 8) or
            LongWord(ctx.buffer[i * 4 + 3]);
  end;

  for i := 16 to 79 do
  begin
    w[i] := RotateLeft(w[i - 3] xor w[i - 8] xor w[i - 14] xor w[i - 16], 1);
  end;

  { Initialize working variables }
  a := ctx.h0;
  b := ctx.h1;
  c := ctx.h2;
  d := ctx.h3;
  e := ctx.h4;

  { Main loop }
  for t := 0 to 79 do
  begin
    if t < 20 then
    begin
      f := (b and c) or ((not b) and d);
      k := $5A827999;
    end
    else if t < 40 then
    begin
      f := b xor c xor d;
      k := $6ED9EBA1;
    end
    else if t < 60 then
    begin
      f := (b and c) or (b and d) or (c and d);
      k := $8F1BBCDC;
    end
    else
    begin
      f := b xor c xor d;
      k := $CA62C1D6;
    end;

    temp := RotateLeft(a, 5) + f + e + k + w[t];
    e := d;
    d := c;
    c := RotateLeft(b, 30);
    b := a;
    a := temp;
  end;

  { Add this chunk's hash to result so far }
  ctx.h0 := ctx.h0 + a;
  ctx.h1 := ctx.h1 + b;
  ctx.h2 := ctx.h2 + c;
  ctx.h3 := ctx.h3 + d;
  ctx.h4 := ctx.h4 + e;
end;

procedure SHA1Start(var ctx: TSHA1Context);
begin
  ctx.h0 := $67452301;
  ctx.h1 := $EFCDAB89;
  ctx.h2 := $98BADCFE;
  ctx.h3 := $10325476;
  ctx.h4 := $C3D2E1F0;
  ctx.messageLen := 0;
  ctx.bufferLen := 0;
end;

procedure SHA1Add(var ctx: TSHA1Context; const data; len: Integer);
type
  PByte = ^Byte;
var
  p: PByte;
  i: Integer;
begin
  p := @data;

  for i := 0 to len - 1 do
  begin
    ctx.buffer[ctx.bufferLen] := p^;
    Inc(ctx.bufferLen);
    Inc(p);

    if ctx.bufferLen = 64 then
    begin
      SHA1ProcessBlock(ctx);
      ctx.bufferLen := 0;
    end;
  end;

  ctx.messageLen := ctx.messageLen + QWord(len) * 8;
end;

procedure SHA1End(var ctx: TSHA1Context; var digest: TSHA1Digest);
var
  i: Integer;
  bitLen: QWord;
begin
  { Append padding }
  ctx.buffer[ctx.bufferLen] := $80;
  Inc(ctx.bufferLen);

  { If not enough room for length, pad and process block }
  if ctx.bufferLen > 56 then
  begin
    while ctx.bufferLen < 64 do
    begin
      ctx.buffer[ctx.bufferLen] := 0;
      Inc(ctx.bufferLen);
    end;
    SHA1ProcessBlock(ctx);
    ctx.bufferLen := 0;
  end;

  { Pad with zeros }
  while ctx.bufferLen < 56 do
  begin
    ctx.buffer[ctx.bufferLen] := 0;
    Inc(ctx.bufferLen);
  end;

  { Append length in bits as 64-bit big-endian }
  bitLen := ctx.messageLen;
  ctx.buffer[56] := Byte(bitLen shr 56);
  ctx.buffer[57] := Byte(bitLen shr 48);
  ctx.buffer[58] := Byte(bitLen shr 40);
  ctx.buffer[59] := Byte(bitLen shr 32);
  ctx.buffer[60] := Byte(bitLen shr 24);
  ctx.buffer[61] := Byte(bitLen shr 16);
  ctx.buffer[62] := Byte(bitLen shr 8);
  ctx.buffer[63] := Byte(bitLen);

  SHA1ProcessBlock(ctx);

  { Produce final hash value (big-endian) }
  for i := 0 to 3 do
  begin
    digest[i] := Byte(ctx.h0 shr (24 - i * 8));
    digest[i + 4] := Byte(ctx.h1 shr (24 - i * 8));
    digest[i + 8] := Byte(ctx.h2 shr (24 - i * 8));
    digest[i + 12] := Byte(ctx.h3 shr (24 - i * 8));
    digest[i + 16] := Byte(ctx.h4 shr (24 - i * 8));
  end;
end;

function SHA1(const data; len: Integer): TSHA1Digest;
var
  ctx: TSHA1Context;
  digest: TSHA1Digest;
begin
  SHA1Start(ctx);
  SHA1Add(ctx, data, len);
  SHA1End(ctx, digest);
  SHA1 := digest;
end;

end.
