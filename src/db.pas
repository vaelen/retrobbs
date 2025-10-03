unit DB;

{
  Database Library

  A simple file-based database system for RetroBBS.
  Uses fixed-size records with B-Tree indexes and journaling.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

interface

uses
  BBSTypes, Hash, BTree;

{ Phase 1: Constants, Enums, and Record Types }

const
  PAGE_SIZE = 512;
  PAGE_DATA_SIZE = 506;  { 512 - 4 byte ID - 1 byte Status - 1 byte reserved }
  DB_SIGNATURE = 'RETRODB' + #0;
  DB_VERSION = 1;
  MAX_INDEXES = 15;

type
  { Enumeration Types }
  TDBIndexType = (itID, itString);
  TDBPageStatus = (psEmpty, psActive, psContinuation);
  TDBJournalOp = (joNone, joUpdate, joDelete, joAdd);

  { Index Information - 32 bytes }
  TDBIndexInfo = record
    FieldName: String[29];   { 30 bytes }
    IndexType: Byte;         { 1 byte }
    IndexNumber: Byte;       { 1 byte }
  end;

  { Database Header - 512 bytes (page 0) }
  TDBHeader = record
    Signature: array[0..7] of Char;         { 8 bytes }
    Version: TWord;                          { 2 bytes }
    PageSize: TWord;                         { 2 bytes }
    RecordSize: TWord;                       { 2 bytes }
    RecordCount: TLong;                   { 4 bytes }
    NextRecordID: TLong;                  { 4 bytes }
    LastCompacted: TBBSTimestamp;           { 4 bytes }
    JournalPending: Boolean;                { 1 byte }
    IndexCount: Byte;                       { 1 byte }
    Reserved: array[0..3] of Byte;          { 4 bytes }
    Indexes: array[0..14] of TDBIndexInfo;  { 480 bytes }
  end;

  { Free Page List - 512 bytes (page 1) }
  TDBFreeList = record
    FreePageCount: TWord;                  { 2 bytes }
    FreePageListLen: TWord;                { 2 bytes }
    FreePages: array[0..126] of TLong;  { 508 bytes }
  end;

  { Database Page - 512 bytes }
  TDBPage = record
    ID: TLong;                     { 4 bytes - Record ID }
    Status: Byte;                    { 1 byte - Page status }
    Reserved: Byte;                  { 1 byte - Reserved for alignment }
    Data: array[0..505] of Byte;     { 506 bytes }
  end;

  { Journal Entry - 518 bytes }
  TDBJournalEntry = record
    Operation: Byte;                 { 1 byte }
    PageNum: TLong;                { 4 bytes }
    RecordID: TLong;               { 4 bytes }
    Data: array[0..506] of Byte;     { 507 bytes }
    Checksum: TWord;                  { 2 bytes }
  end;

  { Database Structure }
  TDatabase = record
    Name: Str63;
    Header: TDBHeader;
    FreeList: TDBFreeList;
    DataFile: File;
    JournalFile: File;
    PrimaryIndex: ^TBTree;
    IsOpen: Boolean;
  end;

{ Phase 2: Low-Level File Operations }

{ Read a page from the data file }
function ReadPage(var db: TDatabase; pageNum: TLong; var page: TDBPage): Boolean;

{ Write a page to the data file }
function WritePage(var db: TDatabase; pageNum: TLong; const page: TDBPage): Boolean;

{ Read the database header }
function ReadHeader(var db: TDatabase): Boolean;

{ Write the database header }
function WriteHeader(var db: TDatabase): Boolean;

{ Read the free page list }
function ReadFreeList(var db: TDatabase): Boolean;

{ Write the free page list }
function WriteFreeList(var db: TDatabase): Boolean;

{ Calculate pages needed for a record }
function CalculatePagesNeeded(recordSize: TWord): TInt;

{ Read a multi-page record }
function ReadRecord(var db: TDatabase; firstPageNum: TLong; var data: array of Byte): Boolean;

{ Write a multi-page record }
function WriteRecord(var db: TDatabase; firstPageNum: TLong; recordID: TLong; const data: array of Byte): Boolean;

{ Phase 3: Free Space Management }

{ Find consecutive free pages }
function FindConsecutiveFreePages(var db: TDatabase; count: TInt; var firstPage: TLong): Boolean;

{ Allocate pages for a record }
function AllocatePages(var db: TDatabase; count: TInt; var firstPage: TLong): Boolean;

{ Free pages from a deleted record }
function FreePages(var db: TDatabase; firstPage: TLong; count: TInt): Boolean;

{ Update the free page list by scanning the database }
function UpdateFreePages(var db: TDatabase): Boolean;

{ Phase 4: Index Management }

{ Get index file name }
function GetIndexFileName(baseName: Str63; indexNum: TInt): String;

{ Open an index file }
function OpenIndexFile(var tree: TBTree; baseName: Str63; indexNum: TInt): Boolean;

{ Create an index file }
function CreateIndexFile(baseName: Str63; indexNum: TInt): Boolean;

{ Generate index key from value }
function GenerateIndexKey(indexType: TDBIndexType; const value: array of Byte): TLong;

{ Insert into an index }
function InsertIntoIndex(var tree: TBTree; key: TLong; value: TLong): Boolean;

{ Delete from an index }
function DeleteFromIndex(var tree: TBTree; key: TLong; value: TLong): Boolean;

{ Find in an index }
function FindInIndex(var tree: TBTree; key: TLong; var values: array of TLong; var count: TInt): Boolean;

{ Phase 5: Journal/Transaction System }

{ Calculate journal entry checksum }
function CalculateJournalChecksum(const entry: TDBJournalEntry): TWord;

{ Write journal entry }
function WriteJournalEntry(var db: TDatabase; const entry: TDBJournalEntry): Boolean;

{ Read journal entry }
function ReadJournalEntry(var db: TDatabase; entryNum: TInt; var entry: TDBJournalEntry): Boolean;

{ Begin transaction }
function BeginTransaction(var db: TDatabase): Boolean;

{ Commit transaction }
function CommitTransaction(var db: TDatabase): Boolean;

{ Rollback transaction }
function RollbackTransaction(var db: TDatabase): Boolean;

{ Replay journal for recovery }
function ReplayJournal(var db: TDatabase): Boolean;

{ Phase 6: Database Operations }

{ Create a new database }
function CreateDatabase(name: Str63; recordSize: TWord): Boolean;

{ Open an existing database }
function OpenDatabase(name: Str63; var db: TDatabase): Boolean;

{ Close a database }
procedure CloseDatabase(var db: TDatabase);

{ Phase 7: Record Operations }

{ Add a new record }
function AddRecord(var db: TDatabase; const data: array of Byte; var recordID: TLong): Boolean;

{ Find record by ID }
function FindRecordByID(var db: TDatabase; id: TLong; var data: array of Byte): Boolean;

{ Find record by string field }
function FindRecordByString(var db: TDatabase; fieldName: Str63; value: Str63; var data: array of Byte; var recordID: TLong): Boolean;

{ Update a record }
function UpdateRecord(var db: TDatabase; id: TLong; const data: array of Byte): Boolean;

{ Delete a record }
function DeleteRecord(var db: TDatabase; id: TLong): Boolean;

{ Phase 8: Index Maintenance }

{ Add a secondary index }
function AddIndex(var db: TDatabase; fieldName: String; indexType: TDBIndexType): Boolean;

{ Rebuild a single index }
function RebuildIndex(var db: TDatabase; indexNumber: TInt): Boolean;

{ Rebuild all indexes }
function RebuildAllIndexes(var db: TDatabase): Boolean;

{ Phase 9: Maintenance Operations }

{ Compact the database }
function CompactDatabase(var db: TDatabase): Boolean;

{ Validate the database }
function ValidateDatabase(var db: TDatabase): Boolean;

implementation

uses
  SysUtils;

{ Helper function - inline min }
function MinInt(a, b: TInt): TInt;
begin
  if a < b then
    MinInt := a
  else
    MinInt := b;
end;

{ Helper function to get file size in pages }
function GetFileSize(var f: File): TLong;
var
  currentPos: TLong;
  size: TLong;
begin
  currentPos := FilePos(f);
  Seek(f, FileSize(f));
  size := FilePos(f);
  Seek(f, currentPos);
  GetFileSize := size;
end;

{ Phase 2: Low-Level File Operations Implementation }

function ReadPage(var db: TDatabase; pageNum: TLong; var page: TDBPage): Boolean;
var
  bytesRead: TInt;
begin
  ReadPage := False;

  if not db.IsOpen then
    Exit;

  {$I-}
  Seek(db.DataFile, pageNum * PAGE_SIZE);
  BlockRead(db.DataFile, page, PAGE_SIZE, bytesRead);
  {$I+}

  if IOResult = 0 then
    ReadPage := (bytesRead = PAGE_SIZE);
end;

function WritePage(var db: TDatabase; pageNum: TLong; const page: TDBPage): Boolean;
var
  bytesWritten: TInt;
begin
  WritePage := False;

  if not db.IsOpen then
    Exit;

  {$I-}
  Seek(db.DataFile, pageNum * PAGE_SIZE);
  BlockWrite(db.DataFile, page, PAGE_SIZE, bytesWritten);
  {$I+}

  if IOResult = 0 then
    WritePage := (bytesWritten = PAGE_SIZE);
end;

function ReadHeader(var db: TDatabase): Boolean;
var
  page: array[0..PAGE_SIZE-1] of Byte;
  bytesRead: TInt;
  i: TInt;
begin
  ReadHeader := False;

  if not db.IsOpen then
    Exit;

  {$I-}
  Seek(db.DataFile, 0 * PAGE_SIZE);
  BlockRead(db.DataFile, page, PAGE_SIZE, bytesRead);
  {$I+}

  if (IOResult <> 0) or (bytesRead <> PAGE_SIZE) then
    Exit;

  { Read header fields }
  Move(page[0], db.Header.Signature, 8);
  Move(page[8], db.Header.Version, 2);
  Move(page[10], db.Header.PageSize, 2);
  Move(page[12], db.Header.RecordSize, 2);
  Move(page[14], db.Header.RecordCount, 4);
  Move(page[18], db.Header.NextRecordID, 4);
  Move(page[22], db.Header.LastCompacted, 4);
  Move(page[26], db.Header.JournalPending, 1);
  Move(page[27], db.Header.IndexCount, 1);
  Move(page[28], db.Header.Reserved, 4);
  Move(page[32], db.Header.Indexes, 480);

  { Validate signature }
  for i := 0 to 7 do
    if db.Header.Signature[i] <> DB_SIGNATURE[i+1] then
      Exit;

  { Validate version }
  if db.Header.Version <> DB_VERSION then
    Exit;

  ReadHeader := True;
end;

function WriteHeader(var db: TDatabase): Boolean;
var
  page: array[0..PAGE_SIZE-1] of Byte;
  bytesWritten: TInt;
begin
  WriteHeader := False;

  if not db.IsOpen then
    Exit;

  FillChar(page, PAGE_SIZE, 0);

  { Write header fields }
  Move(db.Header.Signature, page[0], 8);
  Move(db.Header.Version, page[8], 2);
  Move(db.Header.PageSize, page[10], 2);
  Move(db.Header.RecordSize, page[12], 2);
  Move(db.Header.RecordCount, page[14], 4);
  Move(db.Header.NextRecordID, page[18], 4);
  Move(db.Header.LastCompacted, page[22], 4);
  Move(db.Header.JournalPending, page[26], 1);
  Move(db.Header.IndexCount, page[27], 1);
  Move(db.Header.Reserved, page[28], 4);
  Move(db.Header.Indexes, page[32], 480);

  {$I-}
  Seek(db.DataFile, 0 * PAGE_SIZE);
  BlockWrite(db.DataFile, page, PAGE_SIZE, bytesWritten);
  {$I+}

  if IOResult = 0 then
    WriteHeader := (bytesWritten = PAGE_SIZE);
end;

function ReadFreeList(var db: TDatabase): Boolean;
var
  page: array[0..PAGE_SIZE-1] of Byte;
  bytesRead: TInt;
begin
  ReadFreeList := False;

  if not db.IsOpen then
    Exit;

  {$I-}
  Seek(db.DataFile, 1 * PAGE_SIZE);
  BlockRead(db.DataFile, page, PAGE_SIZE, bytesRead);
  {$I+}

  if (IOResult <> 0) or (bytesRead <> PAGE_SIZE) then
    Exit;

  Move(page[0], db.FreeList.FreePageCount, 2);
  Move(page[2], db.FreeList.FreePageListLen, 2);
  Move(page[4], db.FreeList.FreePages, 508);

  ReadFreeList := True;
end;

function WriteFreeList(var db: TDatabase): Boolean;
var
  page: array[0..PAGE_SIZE-1] of Byte;
  bytesWritten: TInt;
begin
  WriteFreeList := False;

  if not db.IsOpen then
    Exit;

  FillChar(page, PAGE_SIZE, 0);

  Move(db.FreeList.FreePageCount, page[0], 2);
  Move(db.FreeList.FreePageListLen, page[2], 2);
  Move(db.FreeList.FreePages, page[4], 508);

  {$I-}
  Seek(db.DataFile, 1 * PAGE_SIZE);
  BlockWrite(db.DataFile, page, PAGE_SIZE, bytesWritten);
  {$I+}

  if IOResult = 0 then
    WriteFreeList := (bytesWritten = PAGE_SIZE);
end;

function CalculatePagesNeeded(recordSize: TWord): TInt;
begin
  { Calculate ceiling of recordSize / PAGE_DATA_SIZE }
  CalculatePagesNeeded := (recordSize + PAGE_DATA_SIZE - 1) div PAGE_DATA_SIZE;
end;

function ReadRecord(var db: TDatabase; firstPageNum: TLong; var data: array of Byte): Boolean;
var
  page: TDBPage;
  pagesNeeded: TInt;
  i, offset, bytesToCopy: TInt;
  recordID: TLong;
begin
  ReadRecord := False;

  if not db.IsOpen then
    Exit;

  pagesNeeded := CalculatePagesNeeded(db.Header.RecordSize);

  { Read first page to get record ID }
  if not ReadPage(db, firstPageNum, page) then
    Exit;

  recordID := page.ID;

  { Verify first page status }
  if page.Status <> Ord(psActive) then
    Exit;

  { Copy data from first page }
  if db.Header.RecordSize <= PAGE_DATA_SIZE then
    bytesToCopy := db.Header.RecordSize
  else
    bytesToCopy := PAGE_DATA_SIZE;

  Move(page.Data, data[0], bytesToCopy);
  offset := bytesToCopy;

  { Read remaining pages }
  for i := 1 to pagesNeeded - 1 do
  begin
    if not ReadPage(db, firstPageNum + i, page) then
      Exit;

    { Verify record ID matches }
    if page.ID <> recordID then
      Exit;

    { Verify continuation status }
    if page.Status <> Ord(psContinuation) then
      Exit;

    { Copy data }
    bytesToCopy := db.Header.RecordSize - offset;
    if bytesToCopy > PAGE_DATA_SIZE then
      bytesToCopy := PAGE_DATA_SIZE;

    Move(page.Data, data[offset], bytesToCopy);
    Inc(offset, bytesToCopy);
  end;

  ReadRecord := True;
end;

function WriteRecord(var db: TDatabase; firstPageNum: TLong; recordID: TLong; const data: array of Byte): Boolean;
var
  page: TDBPage;
  pagesNeeded: TInt;
  i, offset, bytesToCopy: TInt;
begin
  WriteRecord := False;

  if not db.IsOpen then
    Exit;

  pagesNeeded := CalculatePagesNeeded(db.Header.RecordSize);
  offset := 0;

  for i := 0 to pagesNeeded - 1 do
  begin
    FillChar(page, SizeOf(page), 0);

    page.ID := recordID;

    if i = 0 then
      page.Status := Ord(psActive)
    else
      page.Status := Ord(psContinuation);

    { Calculate bytes to copy }
    bytesToCopy := db.Header.RecordSize - offset;
    if bytesToCopy > PAGE_DATA_SIZE then
      bytesToCopy := PAGE_DATA_SIZE;

    Move(data[offset], page.Data, bytesToCopy);

    if not WritePage(db, firstPageNum + i, page) then
      Exit;

    Inc(offset, bytesToCopy);
  end;

  WriteRecord := True;
end;

{ Phase 3: Free Space Management Implementation }

function FindConsecutiveFreePages(var db: TDatabase; count: TInt; var firstPage: TLong): Boolean;
var
  i, j, consecutive: TInt;
  startPage: TLong;
begin
  FindConsecutiveFreePages := False;

  if count <= 0 then
    Exit;

  if count = 1 then
  begin
    { Single page - just find any free page }
    if db.FreeList.FreePageListLen > 0 then
    begin
      firstPage := db.FreeList.FreePages[0];
      FindConsecutiveFreePages := True;
    end;
    Exit;
  end;

  { Need consecutive pages }
  for i := 0 to db.FreeList.FreePageListLen - 1 do
  begin
    startPage := db.FreeList.FreePages[i];
    consecutive := 1;

    for j := i + 1 to db.FreeList.FreePageListLen - 1 do
    begin
      if db.FreeList.FreePages[j] = startPage + consecutive then
      begin
        Inc(consecutive);
        if consecutive = count then
        begin
          firstPage := startPage;
          FindConsecutiveFreePages := True;
          Exit;
        end;
      end
      else
        Break;
    end;
  end;
end;

function AllocatePages(var db: TDatabase; count: TInt; var firstPage: TLong): Boolean;
var
  fileSizeInPages: TLong;
  i, j: TInt;
  found: Boolean;
begin
  AllocatePages := False;

  if count <= 0 then
    Exit;

  { Try to find consecutive free pages first }
  if (db.FreeList.FreePageCount >= count) and (db.FreeList.FreePageListLen > 0) then
  begin
    if FindConsecutiveFreePages(db, count, firstPage) then
    begin
      { Remove allocated pages from free list }
      found := False;
      for i := 0 to db.FreeList.FreePageListLen - 1 do
      begin
        if db.FreeList.FreePages[i] = firstPage then
        begin
          { Shift remaining entries }
          for j := i to db.FreeList.FreePageListLen - count - 1 do
            db.FreeList.FreePages[j] := db.FreeList.FreePages[j + count];
          Dec(db.FreeList.FreePageListLen, count);
          Dec(db.FreeList.FreePageCount, count);
          found := True;
          Break;
        end;
      end;

      if found then
      begin
        WriteFreeList(db);
        AllocatePages := True;
        Exit;
      end;
    end;
  end;

  { If free list is empty or couldn't find consecutive pages, refresh it }
  if (db.FreeList.FreePageListLen = 0) and (db.FreeList.FreePageCount > 0) then
  begin
    if UpdateFreePages(db) then
    begin
      { Try again after refresh }
      if FindConsecutiveFreePages(db, count, firstPage) then
      begin
        { Remove from free list }
        for i := 0 to db.FreeList.FreePageListLen - 1 do
        begin
          if db.FreeList.FreePages[i] = firstPage then
          begin
            for j := i to db.FreeList.FreePageListLen - count - 1 do
              db.FreeList.FreePages[j] := db.FreeList.FreePages[j + count];
            Dec(db.FreeList.FreePageListLen, count);
            Dec(db.FreeList.FreePageCount, count);
            WriteFreeList(db);
            AllocatePages := True;
            Exit;
          end;
        end;
      end;
    end;
  end;

  { Append to end of file }
  fileSizeInPages := GetFileSize(db.DataFile) div PAGE_SIZE;
  firstPage := fileSizeInPages;
  AllocatePages := True;
end;

function FreePages(var db: TDatabase; firstPage: TLong; count: TInt): Boolean;
var
  page: TDBPage;
  i: TInt;
begin
  FreePages := False;

  if count <= 0 then
    Exit;

  { Mark all pages as empty }
  for i := 0 to count - 1 do
  begin
    if ReadPage(db, firstPage + i, page) then
    begin
      page.Status := Ord(psEmpty);
      if not WritePage(db, firstPage + i, page) then
        Exit;
    end;
  end;

  { Update free list }
  Inc(db.FreeList.FreePageCount, count);

  { Add to free list array if there's room }
  if db.FreeList.FreePageListLen < 127 then
  begin
    db.FreeList.FreePages[db.FreeList.FreePageListLen] := firstPage;
    Inc(db.FreeList.FreePageListLen);
  end;

  FreePages := WriteFreeList(db);
end;

function UpdateFreePages(var db: TDatabase): Boolean;
var
  page: TDBPage;
  pageNum: TLong;
  fileSizeInPages: TLong;
  freeCount: TWord;
begin
  UpdateFreePages := False;

  if not db.IsOpen then
    Exit;

  fileSizeInPages := GetFileSize(db.DataFile) div PAGE_SIZE;
  freeCount := 0;
  db.FreeList.FreePageListLen := 0;

  { Scan all pages starting from page 2 (skip header and free list) }
  for pageNum := 2 to fileSizeInPages - 1 do
  begin
    if ReadPage(db, pageNum, page) then
    begin
      if page.Status = Ord(psEmpty) then
      begin
        Inc(freeCount);

        { Add to array if there's room }
        if db.FreeList.FreePageListLen < 127 then
        begin
          db.FreeList.FreePages[db.FreeList.FreePageListLen] := pageNum;
          Inc(db.FreeList.FreePageListLen);
        end;
      end;
    end;
  end;

  db.FreeList.FreePageCount := freeCount;
  UpdateFreePages := WriteFreeList(db);
end;

{ Phase 4: Index Management Implementation }

function GetIndexFileName(baseName: Str63; indexNum: TInt): String;
begin
  if indexNum = -1 then
    GetIndexFileName := baseName + '.idx'
  else if (indexNum >= 0) and (indexNum <= 14) then
  begin
    if indexNum < 10 then
      GetIndexFileName := baseName + '.i0' + Chr(Ord('0') + indexNum)
    else
      GetIndexFileName := baseName + '.i1' + Chr(Ord('0') + (indexNum - 10));
  end
  else
    GetIndexFileName := '';
end;

function OpenIndexFile(var tree: TBTree; baseName: Str63; indexNum: TInt): Boolean;
var
  fileName: String;
begin
  fileName := GetIndexFileName(baseName, indexNum);
  if fileName = '' then
  begin
    OpenIndexFile := False;
    Exit;
  end;

  OpenIndexFile := OpenBTree(tree, fileName);
end;

function CreateIndexFile(baseName: Str63; indexNum: TInt): Boolean;
var
  fileName: String;
begin
  fileName := GetIndexFileName(baseName, indexNum);
  if fileName = '' then
  begin
    CreateIndexFile := False;
    Exit;
  end;

  CreateIndexFile := CreateBTree(fileName);
end;

function GenerateIndexKey(indexType: TDBIndexType; const value: array of Byte): TLong;
var
  str: Str63;
  i: TInt;
  len: Byte;
  result: TLong;
begin
  if indexType = itID then
  begin
    { First 4 bytes as TLong }
    Move(value[0], result, 4);
    GenerateIndexKey := result;
  end
  else { itString }
  begin
    { Extract string from byte array }
    len := value[0];
    if len > 63 then
      len := 63;

    str := '';
    for i := 1 to len do
      str := str + Chr(value[i]);

    { Use BTree's StringKey function }
    GenerateIndexKey := StringKey(str);
  end;
end;

function InsertIntoIndex(var tree: TBTree; key: TLong; value: TLong): Boolean;
begin
  InsertIntoIndex := Insert(tree, key, value);
end;

function DeleteFromIndex(var tree: TBTree; key: TLong; value: TLong): Boolean;
begin
  DeleteFromIndex := DeleteValue(tree, key, value);
end;

function FindInIndex(var tree: TBTree; key: TLong; var values: array of TLong; var count: TInt): Boolean;
begin
  FindInIndex := Find(tree, key, values, count);
end;

{ Phase 5: Journal/Transaction System Implementation }

function CalculateJournalChecksum(const entry: TDBJournalEntry): TWord;
var
  buffer: array[0..514] of Byte;
begin
  { Build buffer: Operation + PageNum + RecordID + Data }
  buffer[0] := entry.Operation;
  Move(entry.PageNum, buffer[1], 4);
  Move(entry.RecordID, buffer[5], 4);
  Move(entry.Data, buffer[9], 507);

  CalculateJournalChecksum := CRC16(buffer, 516);
end;

function WriteJournalEntry(var db: TDatabase; const entry: TDBJournalEntry): Boolean;
var
  modEntry: TDBJournalEntry;
  bytesWritten: TInt;
begin
  WriteJournalEntry := False;

  if not db.IsOpen then
    Exit;

  { Copy entry and calculate checksum }
  modEntry := entry;
  modEntry.Checksum := CalculateJournalChecksum(entry);

  {$I-}
  { Seek to end of journal file }
  Seek(db.JournalFile, GetFileSize(db.JournalFile));
  BlockWrite(db.JournalFile, modEntry, SizeOf(TDBJournalEntry), bytesWritten);
  {$I+}

  if IOResult = 0 then
    WriteJournalEntry := (bytesWritten = SizeOf(TDBJournalEntry));
end;

function ReadJournalEntry(var db: TDatabase; entryNum: TInt; var entry: TDBJournalEntry): Boolean;
var
  bytesRead: TInt;
begin
  ReadJournalEntry := False;

  if not db.IsOpen then
    Exit;

  {$I-}
  Seek(db.JournalFile, entryNum * SizeOf(TDBJournalEntry));
  BlockRead(db.JournalFile, entry, SizeOf(TDBJournalEntry), bytesRead);
  {$I+}

  if IOResult = 0 then
    ReadJournalEntry := (bytesRead = SizeOf(TDBJournalEntry));
end;

function BeginTransaction(var db: TDatabase): Boolean;
begin
  BeginTransaction := False;

  if not db.IsOpen then
    Exit;

  db.Header.JournalPending := True;
  BeginTransaction := WriteHeader(db);
end;

function CommitTransaction(var db: TDatabase): Boolean;
begin
  CommitTransaction := False;

  if not db.IsOpen then
    Exit;

  db.Header.JournalPending := False;

  if not WriteHeader(db) then
    Exit;

  {$I-}
  { Truncate journal file }
  Seek(db.JournalFile, 0);
  Truncate(db.JournalFile);
  {$I+}

  CommitTransaction := (IOResult = 0);
end;

function RollbackTransaction(var db: TDatabase): Boolean;
begin
  RollbackTransaction := False;

  if not db.IsOpen then
    Exit;

  db.Header.JournalPending := False;

  if not WriteHeader(db) then
    Exit;

  {$I-}
  { Truncate journal file }
  Seek(db.JournalFile, 0);
  Truncate(db.JournalFile);
  {$I+}

  RollbackTransaction := (IOResult = 0);
end;

function ReplayJournal(var db: TDatabase): Boolean;
var
  journalSize: TLong;
  entryCount: TInt;
  i: TInt;
  entry: TDBJournalEntry;
  checksum: TWord;
  page: TDBPage;
begin
  ReplayJournal := False;

  if not db.IsOpen then
    Exit;

  journalSize := GetFileSize(db.JournalFile);
  entryCount := journalSize div SizeOf(TDBJournalEntry);

  { Replay each journal entry }
  for i := 0 to entryCount - 1 do
  begin
    if ReadJournalEntry(db, i, entry) then
    begin
      { Verify checksum }
      checksum := CalculateJournalChecksum(entry);
      if checksum = entry.Checksum then
      begin
        case TDBJournalOp(entry.Operation) of
          joUpdate:
            begin
              { Write data to page }
              FillChar(page, SizeOf(page), 0);
              page.ID := entry.RecordID;
              page.Status := Ord(psActive);
              Move(entry.Data, page.Data, PAGE_DATA_SIZE);
              WritePage(db, entry.PageNum, page);
            end;
          joDelete:
            begin
              { Mark page as empty }
              if ReadPage(db, entry.PageNum, page) then
              begin
                page.Status := Ord(psEmpty);
                WritePage(db, entry.PageNum, page);
              end;
            end;
          joAdd:
            begin
              { Write new page }
              FillChar(page, SizeOf(page), 0);
              page.ID := entry.RecordID;
              page.Status := Ord(psActive);
              Move(entry.Data, page.Data, PAGE_DATA_SIZE);
              WritePage(db, entry.PageNum, page);
            end;
        end;
      end;
    end;
  end;

  { Rebuild all indexes }
  if not RebuildAllIndexes(db) then
    Exit;

  { Clear journal }
  db.Header.JournalPending := False;
  if not WriteHeader(db) then
    Exit;

  {$I-}
  Seek(db.JournalFile, 0);
  Truncate(db.JournalFile);
  {$I+}

  ReplayJournal := (IOResult = 0);
end;

{ Phase 6: Database Operations Implementation }

function CreateDatabase(name: Str63; recordSize: TWord): Boolean;
var
  f, jf: File;
  header: TDBHeader;
  freeList: TDBFreeList;
  page: array[0..PAGE_SIZE-1] of Byte;
  bytesWritten: TInt;
  i: TInt;
begin
  CreateDatabase := False;

  if (recordSize = 0) or (recordSize > 65535) then
    Exit;

  { Create data file }
  Assign(f, name + '.dat');
  {$I-}
  Rewrite(f, 1);
  {$I+}

  if IOResult <> 0 then
    Exit;

  { Initialize header }
  FillChar(header, SizeOf(header), 0);
  for i := 1 to Length(DB_SIGNATURE) do
    header.Signature[i-1] := DB_SIGNATURE[i];
  header.Version := DB_VERSION;
  header.PageSize := PAGE_SIZE;
  header.RecordSize := recordSize;
  header.RecordCount := 0;
  header.NextRecordID := 1;
  header.LastCompacted := 0;
  header.JournalPending := False;
  header.IndexCount := 0;

  { Write header to page 0 }
  FillChar(page, PAGE_SIZE, 0);
  Move(header.Signature, page[0], 8);
  Move(header.Version, page[8], 2);
  Move(header.PageSize, page[10], 2);
  Move(header.RecordSize, page[12], 2);
  Move(header.RecordCount, page[14], 4);
  Move(header.NextRecordID, page[18], 4);
  Move(header.LastCompacted, page[22], 4);
  Move(header.JournalPending, page[26], 1);
  Move(header.IndexCount, page[27], 1);
  Move(header.Reserved, page[28], 4);
  Move(header.Indexes, page[32], 480);

  BlockWrite(f, page, PAGE_SIZE, bytesWritten);
  if bytesWritten <> PAGE_SIZE then
  begin
    Close(f);
    Exit;
  end;

  { Initialize and write free list to page 1 }
  FillChar(freeList, SizeOf(freeList), 0);
  freeList.FreePageCount := 0;
  freeList.FreePageListLen := 0;

  FillChar(page, PAGE_SIZE, 0);
  Move(freeList.FreePageCount, page[0], 2);
  Move(freeList.FreePageListLen, page[2], 2);
  Move(freeList.FreePages, page[4], 508);

  BlockWrite(f, page, PAGE_SIZE, bytesWritten);
  if bytesWritten <> PAGE_SIZE then
  begin
    Close(f);
    Exit;
  end;

  Close(f);

  { Create primary index }
  if not CreateIndexFile(name, -1) then
    Exit;

  { Create journal file }
  Assign(jf, name + '.jnl');
  {$I-}
  Rewrite(jf, 1);
  Close(jf);
  {$I+}

  if IOResult <> 0 then
    Exit;

  CreateDatabase := True;
end;

function OpenDatabase(name: Str63; var db: TDatabase): Boolean;
var
  f, jf: File;
begin
  OpenDatabase := False;

  { Initialize pointer fields }
  db.PrimaryIndex := nil;

  { Open data file }
  Assign(f, name + '.dat');
  {$I-}
  Reset(f, 1);
  {$I+}

  if IOResult <> 0 then
    Exit;

  db.DataFile := f;
  db.Name := name;
  db.IsOpen := True;

  { Read header }
  if not ReadHeader(db) then
  begin
    Close(db.DataFile);
    db.IsOpen := False;
    Exit;
  end;

  { Open journal file }
  Assign(jf, name + '.jnl');
  {$I-}
  Reset(jf, 1);
  {$I+}

  if IOResult <> 0 then
  begin
    Close(db.DataFile);
    db.IsOpen := False;
    Exit;
  end;

  db.JournalFile := jf;

  { Check if journal recovery is needed }
  if db.Header.JournalPending then
  begin
    if not ReplayJournal(db) then
    begin
      Close(db.JournalFile);
      Close(db.DataFile);
      db.IsOpen := False;
      Exit;
    end;
  end;

  { Read free list }
  if not ReadFreeList(db) then
  begin
    Close(db.JournalFile);
    Close(db.DataFile);
    db.IsOpen := False;
    Exit;
  end;

  { Allocate primary index }
  New(db.PrimaryIndex);

  { Open primary index }
  if not OpenIndexFile(db.PrimaryIndex^, name, -1) then
  begin
    Dispose(db.PrimaryIndex);
    Close(db.JournalFile);
    Close(db.DataFile);
    db.IsOpen := False;
    Exit;
  end;

  { Open secondary indexes }
  { TODO: Implement when AddIndex is complete }

  OpenDatabase := True;
end;

procedure CloseDatabase(var db: TDatabase);
begin
  if not db.IsOpen then
    Exit;

  { Write header and free list }
  WriteHeader(db);
  WriteFreeList(db);

  { Close indexes }
  if db.PrimaryIndex <> nil then
  begin
    CloseBTree(db.PrimaryIndex^);
    Dispose(db.PrimaryIndex);
    db.PrimaryIndex := nil;
  end;
  { TODO: Close secondary indexes }

  { Close files }
  Close(db.JournalFile);
  Close(db.DataFile);

  db.IsOpen := False;
end;

{ Phase 7: Record Operations Implementation }

function AddRecord(var db: TDatabase; const data: array of Byte; var recordID: TLong): Boolean;
var
  pagesNeeded: TInt;
  firstPage: TLong;
  entry: TDBJournalEntry;
  i: TInt;
begin
  AddRecord := False;

  if not db.IsOpen then
    Exit;

  { Begin transaction }
  if not BeginTransaction(db) then
    Exit;

  { Assign record ID }
  recordID := db.Header.NextRecordID;
  Inc(db.Header.NextRecordID);

  { Calculate pages needed }
  pagesNeeded := CalculatePagesNeeded(db.Header.RecordSize);

  { Allocate pages }
  if not AllocatePages(db, pagesNeeded, firstPage) then
  begin
    RollbackTransaction(db);
    Exit;
  end;

  { Create journal entries for each page }
  for i := 0 to pagesNeeded - 1 do
  begin
    FillChar(entry, SizeOf(entry), 0);
    entry.Operation := Ord(joAdd);
    entry.PageNum := firstPage + i;
    entry.RecordID := recordID;

    { Copy appropriate portion of data }
    if i = 0 then
    begin
      if db.Header.RecordSize <= PAGE_DATA_SIZE then
        Move(data[0], entry.Data, db.Header.RecordSize)
      else
        Move(data[0], entry.Data, PAGE_DATA_SIZE);
    end
    else
    begin
      Move(data[i * PAGE_DATA_SIZE], entry.Data,
           MinInt(PAGE_DATA_SIZE, db.Header.RecordSize - i * PAGE_DATA_SIZE));
    end;

    if not WriteJournalEntry(db, entry) then
    begin
      RollbackTransaction(db);
      Exit;
    end;
  end;

  { Write record }
  if not WriteRecord(db, firstPage, recordID, data) then
  begin
    RollbackTransaction(db);
    Exit;
  end;

  { Insert into primary index }
  if not InsertIntoIndex(db.PrimaryIndex^, recordID, firstPage) then
  begin
    RollbackTransaction(db);
    Exit;
  end;

  { TODO: Insert into secondary indexes }

  { Update record count }
  Inc(db.Header.RecordCount);

  { Commit transaction }
  if not CommitTransaction(db) then
    Exit;

  AddRecord := True;
end;

function FindRecordByID(var db: TDatabase; id: TLong; var data: array of Byte): Boolean;
var
  values: array[0..9] of TLong;
  count: TInt;
  firstPage: TLong;
begin
  FindRecordByID := False;

  if not db.IsOpen then
    Exit;

  { Search primary index }
  if not FindInIndex(db.PrimaryIndex^, id, values, count) then
    Exit;

  if count = 0 then
    Exit;

  firstPage := values[0];

  { Read record }
  FindRecordByID := ReadRecord(db, firstPage, data);
end;

function FindRecordByString(var db: TDatabase; fieldName: Str63; value: Str63; var data: array of Byte; var recordID: TLong): Boolean;
begin
  { TODO: Implement secondary index search }
  FindRecordByString := False;
end;

function UpdateRecord(var db: TDatabase; id: TLong; const data: array of Byte): Boolean;
var
  oldData: array[0..65535] of Byte;
  values: array[0..9] of TLong;
  count: TInt;
  firstPage: TLong;
  entry: TDBJournalEntry;
  pagesNeeded: TInt;
  i: TInt;
begin
  UpdateRecord := False;

  if not db.IsOpen then
    Exit;

  { Find existing record }
  if not FindRecordByID(db, id, oldData) then
    Exit;

  { Get first page from index }
  if not FindInIndex(db.PrimaryIndex^, id, values, count) then
    Exit;

  if count = 0 then
    Exit;

  firstPage := values[0];

  { Begin transaction }
  if not BeginTransaction(db) then
    Exit;

  { Calculate pages needed }
  pagesNeeded := CalculatePagesNeeded(db.Header.RecordSize);

  { Create journal entries }
  for i := 0 to pagesNeeded - 1 do
  begin
    FillChar(entry, SizeOf(entry), 0);
    entry.Operation := Ord(joUpdate);
    entry.PageNum := firstPage + i;
    entry.RecordID := id;

    { Copy appropriate portion of data }
    if i = 0 then
    begin
      if db.Header.RecordSize <= PAGE_DATA_SIZE then
        Move(data[0], entry.Data, db.Header.RecordSize)
      else
        Move(data[0], entry.Data, PAGE_DATA_SIZE);
    end
    else
    begin
      Move(data[i * PAGE_DATA_SIZE], entry.Data,
           MinInt(PAGE_DATA_SIZE, db.Header.RecordSize - i * PAGE_DATA_SIZE));
    end;

    if not WriteJournalEntry(db, entry) then
    begin
      RollbackTransaction(db);
      Exit;
    end;
  end;

  { TODO: Update secondary indexes }

  { Write updated record }
  if not WriteRecord(db, firstPage, id, data) then
  begin
    RollbackTransaction(db);
    Exit;
  end;

  { Commit transaction }
  if not CommitTransaction(db) then
    Exit;

  UpdateRecord := True;
end;

function DeleteRecord(var db: TDatabase; id: TLong): Boolean;
var
  data: array[0..65535] of Byte;
  values: array[0..9] of TLong;
  count: TInt;
  firstPage: TLong;
  pagesNeeded: TInt;
  entry: TDBJournalEntry;
  i: TInt;
begin
  DeleteRecord := False;

  if not db.IsOpen then
    Exit;

  { Find record }
  if not FindRecordByID(db, id, data) then
    Exit;

  { Get first page from index }
  if not FindInIndex(db.PrimaryIndex^, id, values, count) then
    Exit;

  if count = 0 then
    Exit;

  firstPage := values[0];

  { Begin transaction }
  if not BeginTransaction(db) then
    Exit;

  { Calculate pages needed }
  pagesNeeded := CalculatePagesNeeded(db.Header.RecordSize);

  { Create journal entry }
  FillChar(entry, SizeOf(entry), 0);
  entry.Operation := Ord(joDelete);
  entry.PageNum := firstPage;
  entry.RecordID := id;

  if not WriteJournalEntry(db, entry) then
  begin
    RollbackTransaction(db);
    Exit;
  end;

  { Free pages }
  if not FreePages(db, firstPage, pagesNeeded) then
  begin
    RollbackTransaction(db);
    Exit;
  end;

  { Delete from primary index }
  if not DeleteFromIndex(db.PrimaryIndex^, id, firstPage) then
  begin
    RollbackTransaction(db);
    Exit;
  end;

  { TODO: Delete from secondary indexes }

  { Update record count }
  Dec(db.Header.RecordCount);

  { Commit transaction }
  if not CommitTransaction(db) then
    Exit;

  DeleteRecord := True;
end;

{ Phase 8: Index Maintenance Implementation }

function AddIndex(var db: TDatabase; fieldName: String; indexType: TDBIndexType): Boolean;
var
  indexNum: TInt;
  i: TInt;
begin
  AddIndex := False;

  if not db.IsOpen then
    Exit;

  { Check if we have room for another index }
  if db.Header.IndexCount >= MAX_INDEXES then
    Exit;

  { Validate field name length }
  if Length(fieldName) > 29 then
    Exit;

  { Find next available index number }
  indexNum := 0;
  for i := 0 to db.Header.IndexCount - 1 do
  begin
    if db.Header.Indexes[i].IndexNumber >= indexNum then
      indexNum := db.Header.Indexes[i].IndexNumber + 1;
  end;

  if indexNum >= MAX_INDEXES then
    Exit;

  { Create index file }
  if not CreateIndexFile(db.Name, indexNum) then
    Exit;

  { Add to header }
  db.Header.Indexes[db.Header.IndexCount].FieldName := fieldName;
  db.Header.Indexes[db.Header.IndexCount].IndexType := Ord(indexType);
  db.Header.Indexes[db.Header.IndexCount].IndexNumber := indexNum;
  Inc(db.Header.IndexCount);

  { Write updated header }
  if not WriteHeader(db) then
  begin
    Dec(db.Header.IndexCount);
    Exit;
  end;

  { TODO: Open the new index }
  { Secondary indexes not yet fully implemented }

  { TODO: Build the index from existing records }
  { For now, just create empty index file }

  AddIndex := True;
end;

function RebuildIndex(var db: TDatabase; indexNumber: TInt): Boolean;
var
  page: TDBPage;
  pageNum: TLong;
  fileSize: TLong;
  recordID: TLong;
  firstPage: TLong;
  tree: ^TBTree;
begin
  RebuildIndex := False;

  if not db.IsOpen then
    Exit;

  { Open the index file }
  if indexNumber = -1 then
    tree := db.PrimaryIndex
  else if (indexNumber >= 0) and (indexNumber < MAX_INDEXES) then
  begin
    New(tree);
    if not OpenIndexFile(tree^, db.Name, indexNumber) then
    begin
      Dispose(tree);
      Exit;
    end;
  end
  else
    Exit;

  { Close and recreate the index to clear it }
  CloseBTree(tree^);
  if not CreateIndexFile(db.Name, indexNumber) then
  begin
    if indexNumber <> -1 then
      Dispose(tree);
    Exit;
  end;
  if not OpenIndexFile(tree^, db.Name, indexNumber) then
  begin
    if indexNumber <> -1 then
      Dispose(tree);
    Exit;
  end;

  fileSize := GetFileSize(db.DataFile) div PAGE_SIZE;

  { Scan all active records }
  for pageNum := 2 to fileSize - 1 do
  begin
    if ReadPage(db, pageNum, page) then
    begin
      if page.Status = Ord(psActive) then
      begin
        recordID := page.ID;
        firstPage := pageNum;

        if indexNumber = -1 then
        begin
          { Primary index: recordID -> pageNum }
          Insert(tree^, recordID, firstPage);
        end
        else
        begin
          { Secondary index: fieldValue -> recordID }
          { TODO: Extract field value and insert }
          { For now, just insert recordID -> recordID as placeholder }
          Insert(tree^, recordID, recordID);
        end;
      end;
    end;
  end;

  { Close tree if it's a secondary index }
  if indexNumber <> -1 then
  begin
    CloseBTree(tree^);
    Dispose(tree);
  end;

  RebuildIndex := True;
end;

function RebuildAllIndexes(var db: TDatabase): Boolean;
var
  i: TInt;
begin
  RebuildAllIndexes := False;

  { Rebuild primary index }
  if not RebuildIndex(db, -1) then
    Exit;

  { Rebuild secondary indexes }
  for i := 0 to db.Header.IndexCount - 1 do
  begin
    if not RebuildIndex(db, db.Header.Indexes[i].IndexNumber) then
      Exit;
  end;

  RebuildAllIndexes := True;
end;

{ Phase 9: Maintenance Operations Implementation }

function CompactDatabase(var db: TDatabase): Boolean;
var
  page: TDBPage;
  pageNum, newPageNum: TLong;
  fileSize: TLong;
  recordID: TLong;
  data: array[0..65535] of Byte;
  pagesNeeded: TInt;
  i: TInt;
  mapping: array[0..10000] of record
    oldPage: TLong;
    newPage: TLong;
  end;
  mapCount: TInt;
begin
  CompactDatabase := False;

  if not db.IsOpen then
    Exit;

  { Begin transaction }
  if not BeginTransaction(db) then
    Exit;

  fileSize := GetFileSize(db.DataFile) div PAGE_SIZE;
  newPageNum := 2;  { Start after header and free list }
  mapCount := 0;

  { Scan all active records and create mapping }
  pageNum := 2;
  while pageNum < fileSize do
  begin
    if ReadPage(db, pageNum, page) then
    begin
      if page.Status = Ord(psActive) then
      begin
        recordID := page.ID;
        pagesNeeded := CalculatePagesNeeded(db.Header.RecordSize);

        { Read entire record }
        if ReadRecord(db, pageNum, data) then
        begin
          { Write to new location }
          if WriteRecord(db, newPageNum, recordID, data) then
          begin
            { Save mapping }
            if mapCount < 10000 then
            begin
              mapping[mapCount].oldPage := pageNum;
              mapping[mapCount].newPage := newPageNum;
              Inc(mapCount);
            end;

            Inc(newPageNum, pagesNeeded);
          end;
        end;

        { Skip the continuation pages }
        Inc(pageNum, pagesNeeded);
      end
      else
        Inc(pageNum);
    end
    else
      Inc(pageNum);
  end;

  { Truncate file to remove unused pages }
  {$I-}
  Seek(db.DataFile, newPageNum * PAGE_SIZE);
  Truncate(db.DataFile);
  {$I+}

  if IOResult <> 0 then
  begin
    RollbackTransaction(db);
    Exit;
  end;

  { Rebuild all indexes with new page numbers }
  if not RebuildAllIndexes(db) then
  begin
    RollbackTransaction(db);
    Exit;
  end;

  { Clear free list }
  db.FreeList.FreePageCount := 0;
  db.FreeList.FreePageListLen := 0;
  WriteFreeList(db);

  { Update last compacted timestamp }
  { TODO: Get current timestamp }
  db.Header.LastCompacted := 0;

  { Commit transaction }
  if not CommitTransaction(db) then
    Exit;

  CompactDatabase := True;
end;

function ValidateDatabase(var db: TDatabase): Boolean;
var
  i: TInt;
  page: TDBPage;
  pageNum: TLong;
  fileSize: TLong;
  activeCount: TLong;
  freeCount: TLong;
  recordID: TLong;
  values: array[0..9] of TLong;
  count: TInt;
  valid: Boolean;
begin
  ValidateDatabase := False;

  if not db.IsOpen then
    Exit;

  valid := True;

  { Verify signature }
  for i := 0 to 7 do
  begin
    if db.Header.Signature[i] <> DB_SIGNATURE[i+1] then
    begin
      WriteLn('ERROR: Invalid signature');
      valid := False;
    end;
  end;

  { Verify version }
  if db.Header.Version <> DB_VERSION then
  begin
    WriteLn('ERROR: Invalid version');
    valid := False;
  end;

  { Count active and free pages }
  fileSize := GetFileSize(db.DataFile) div PAGE_SIZE;
  activeCount := 0;
  freeCount := 0;

  for pageNum := 2 to fileSize - 1 do
  begin
    if ReadPage(db, pageNum, page) then
    begin
      if page.Status = Ord(psActive) then
        Inc(activeCount)
      else if page.Status = Ord(psEmpty) then
        Inc(freeCount);
    end;
  end;

  { Verify record count (approximate - counts pages not records) }
  if activeCount <> db.Header.RecordCount * CalculatePagesNeeded(db.Header.RecordSize) then
  begin
    WriteLn('WARNING: Record count mismatch');
    WriteLn('  Active pages: ', activeCount);
    WriteLn('  Expected: ', db.Header.RecordCount * CalculatePagesNeeded(db.Header.RecordSize));
  end;

  { Verify free page count }
  if freeCount <> db.FreeList.FreePageCount then
  begin
    WriteLn('WARNING: Free page count mismatch');
    WriteLn('  Actual: ', freeCount);
    WriteLn('  Recorded: ', db.FreeList.FreePageCount);
  end;

  { Verify primary index }
  for pageNum := 2 to fileSize - 1 do
  begin
    if ReadPage(db, pageNum, page) then
    begin
      if page.Status = Ord(psActive) then
      begin
        recordID := page.ID;

        { Check if record exists in primary index }
        if FindInIndex(db.PrimaryIndex^, recordID, values, count) then
        begin
          if count = 0 then
          begin
            WriteLn('ERROR: Record ', recordID, ' not in primary index');
            valid := False;
          end;
        end
        else
        begin
          WriteLn('ERROR: Failed to search index for record ', recordID);
          valid := False;
        end;
      end;
    end;
  end;

  { TODO: Verify secondary indexes }

  if valid then
    WriteLn('Database validation PASSED')
  else
    WriteLn('Database validation FAILED');

  ValidateDatabase := valid;
end;

end.
