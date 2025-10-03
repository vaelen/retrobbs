program DBSizeTest;

{
  Database Structure Size Analysis

  Calculates and displays the size of TDatabase and all its components.
}

uses
  DB, BTree, BBSTypes;

begin
  WriteLn('========================================');
  WriteLn('Database Structure Size Analysis');
  WriteLn('========================================');
  WriteLn;

  WriteLn('Core Type Sizes:');
  WriteLn('  Str63:           ', SizeOf(Str63):6, ' bytes');
  WriteLn('  LongInt:         ', SizeOf(LongInt):6, ' bytes');
  WriteLn('  Word:            ', SizeOf(Word):6, ' bytes');
  WriteLn('  Byte:            ', SizeOf(Byte):6, ' bytes');
  WriteLn('  Boolean:         ', SizeOf(Boolean):6, ' bytes');
  WriteLn('  File:            ', SizeOf(File):6, ' bytes');
  WriteLn;

  WriteLn('Database Component Sizes:');
  WriteLn('  TDBIndexInfo:    ', SizeOf(TDBIndexInfo):6, ' bytes  (should be 32)');
  WriteLn('  TDBHeader:       ', SizeOf(TDBHeader):6, ' bytes  (should be 512)');
  WriteLn('  TDBFreeList:     ', SizeOf(TDBFreeList):6, ' bytes  (should be 512)');
  WriteLn('  TDBPage:         ', SizeOf(TDBPage):6, ' bytes  (should be 512)');
  WriteLn('  TDBJournalEntry: ', SizeOf(TDBJournalEntry):6, ' bytes  (should be 518)');
  WriteLn('  TBTree:          ', SizeOf(TBTree):6, ' bytes');
  WriteLn;

  WriteLn('TDatabase Record Breakdown:');
  WriteLn('  Name (Str63):           ', SizeOf(Str63):6, ' bytes');
  WriteLn('  Header (TDBHeader):     ', SizeOf(TDBHeader):6, ' bytes');
  WriteLn('  FreeList (TDBFreeList): ', SizeOf(TDBFreeList):6, ' bytes');
  WriteLn('  DataFile (File):        ', SizeOf(File):6, ' bytes');
  WriteLn('  JournalFile (File):     ', SizeOf(File):6, ' bytes');
  WriteLn('  PrimaryIndex (TBTree):  ', SizeOf(TBTree):6, ' bytes');
  WriteLn('  IsOpen (Boolean):       ', SizeOf(Boolean):6, ' bytes');
  WriteLn('  ----------------------------------------');
  WriteLn('  TOTAL TDatabase:        ', SizeOf(TDatabase):6, ' bytes');
  WriteLn;

  WriteLn('TBTree Breakdown:');
  WriteLn('  FileName (String):      ~', SizeOf(String):6, ' bytes');
  WriteLn('  FileHandle (File):      ', SizeOf(File):6, ' bytes');
  WriteLn('  Header (TBTreeHeader):  ', SizeOf(TBTreeHeader):6, ' bytes');
  WriteLn('  IsOpen (Boolean):       ', SizeOf(Boolean):6, ' bytes');
  WriteLn('  ----------------------------------------');
  WriteLn('  TOTAL TBTree:           ', SizeOf(TBTree):6, ' bytes');
  WriteLn;

  WriteLn('TBTreeHeader Breakdown:');
  WriteLn('  Magic (4 chars):        ', 4:6, ' bytes');
  WriteLn('  Version (Word):         ', SizeOf(Word):6, ' bytes');
  WriteLn('  Order (Word):           ', SizeOf(Word):6, ' bytes');
  WriteLn('  RootPage (TPageNum):    ', SizeOf(TPageNum):6, ' bytes');
  WriteLn('  NextFreePage (TPageNum):', SizeOf(TPageNum):6, ' bytes');
  WriteLn('  PageCount (LongInt):    ', SizeOf(LongInt):6, ' bytes');
  WriteLn('  ----------------------------------------');
  WriteLn('  TOTAL TBTreeHeader:     ', SizeOf(TBTreeHeader):6, ' bytes');
  WriteLn;

  WriteLn('Memory Usage Notes:');
  WriteLn('  - TDatabase should be declared locally in procedures');
  WriteLn('  - Avoid global TDatabase variables (may cause initialization issues)');
  WriteLn('  - File handles embedded in records can cause issues when copied');
  WriteLn('  - Consider using pointers for large structures in the future');
  WriteLn;

  WriteLn('========================================');
end.
