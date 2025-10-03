program SizeTest;

uses
  DB, BTree;

begin
  WriteLn('TDatabase size: ', SizeOf(TDatabase));
  WriteLn('TBTree size: ', SizeOf(TBTree));
  WriteLn('TDBHeader size: ', SizeOf(TDBHeader));
  WriteLn('TDBFreeList size: ', SizeOf(TDBFreeList));
end.
