program TestArray;
type
  TByteArray = array of Byte;
var
  data: TByteArray;
begin
  SetLength(data, 10);
  WriteLn('Success');
end.
