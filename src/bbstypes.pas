unit BBSTypes;

{
  Custom Type Definitions

  Defines common types and helper functions used throughout RetroBBS.
  All other units rely on this unit.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

interface

{ Custom String Types }
type
  Str255 = String[255];  { Used for long strings }
  Str63 = String[63];    { Used for medium strings }
  Str31 = String[31];    { Used for short strings }
  SHA1Hash = String[41]; { Hex string of a SHA-1 hash (40 chars + null) }

{ User and System Types }
type
  TUserID = Word;        { Unique user identifier (0-65535) }
  TBBSTimestamp = LongInt;  { Seconds since 1/1/1904 (Mac Epoch) }

{ Epoch Conversion Constants }
const
  { Seconds between Mac epoch (1/1/1904) and Unix epoch (1/1/1970) }
  { 66 years * 365.25 days/year * 24 hours/day * 60 min/hour * 60 sec/min }
  { Actual: 24107 days = 2082844800 seconds }
  EPOCH_DELTA = 2082844800;

{ Helper Functions }

{ Converts Unix epoch timestamp (1/1/1970) to Mac epoch timestamp (1/1/1904) }
function UnixToMacEpoch(unixTime: LongInt): LongInt;

{ Converts Mac epoch timestamp (1/1/1904) to Unix epoch timestamp (1/1/1970) }
function MacToUnixEpoch(macTime: LongInt): LongInt;

implementation

function UnixToMacEpoch(unixTime: LongInt): LongInt;
begin
  UnixToMacEpoch := unixTime + EPOCH_DELTA;
end;

function MacToUnixEpoch(macTime: LongInt): LongInt;
begin
  MacToUnixEpoch := macTime - EPOCH_DELTA;
end;

end.
