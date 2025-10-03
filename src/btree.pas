unit BTree;

{
  File-Based B-Tree Implementation

  A B-Tree index stored in a file using 512-byte pages.
  Keys and values are both LongInt (4 bytes).
  Supports overflow pages when a key has many values.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

interface

uses
  BBSTypes, Hash;

const
  PAGE_SIZE = 512;
  MAX_KEYS = 60;        { Maximum keys per node }
  MAX_VALUES = 60;      { Maximum values per key in a leaf }
  MAX_OVERFLOW = 120;   { Maximum values in an overflow page }

type
  TPageNum = LongInt;
  TKeyValue = LongInt;

  { Page types }
  TPageType = (ptNone, ptHeader, ptInternal, ptLeaf, ptOverflow);

  { B-Tree header (stored in page 0) }
  TBTreeHeader = record
    Magic: array[0..3] of Char;  { 'BTRE' magic number }
    Version: Word;                { Format version }
    Order: Word;                  { B-Tree order (max children) }
    RootPage: TPageNum;          { Root node page number }
    NextFreePage: TPageNum;      { Next available page }
    PageCount: LongInt;          { Total pages in file }
  end;

  { Internal node entry }
  TInternalEntry = record
    Key: TKeyValue;
    ChildPage: TPageNum;
  end;

  { Leaf entry with overflow support }
  TLeafEntry = record
    Key: TKeyValue;
    ValueCount: Word;
    Values: array[0..MAX_VALUES-1] of TKeyValue;
    OverflowPage: TPageNum;  { 0 if no overflow }
  end;

  { B-Tree structure }
  TBTree = record
    FileName: String;
    FileHandle: File;
    Header: TBTreeHeader;
    IsOpen: Boolean;
  end;

{ Tree Operations }

{ Create a new B-Tree file }
function CreateBTree(fileName: String): Boolean;

{ Open an existing B-Tree }
function OpenBTree(var tree: TBTree; fileName: String): Boolean;

{ Close a B-Tree }
procedure CloseBTree(var tree: TBTree);

{ Insert a key-value pair }
function Insert(var tree: TBTree; key: TKeyValue; value: TKeyValue): Boolean;

{ Find all values for a key }
function Find(var tree: TBTree; key: TKeyValue; var values: array of TKeyValue;
              var count: Integer): Boolean;

{ Delete a key and all its values }
function Delete(var tree: TBTree; key: TKeyValue): Boolean;

{ Delete a specific key-value pair }
function DeleteValue(var tree: TBTree; key: TKeyValue; value: TKeyValue): Boolean;

{ Utility Functions }

{ Generate a B-Tree key from a string using CRC16 }
function StringKey(s: Str255): TKeyValue;

implementation

uses
  SysUtils;

const
  MAGIC = 'BTRE';
  VERSION = 1;
  ORDER = 61;  { Max 60 keys, 61 children }

{ Internal node structure in memory }
type
  PInternalNode = ^TInternalNode;
  TInternalNode = record
    PageType: TPageType;
    KeyCount: Word;
    Keys: array[0..MAX_KEYS-1] of TKeyValue;
    Children: array[0..MAX_KEYS] of TPageNum;  { n+1 children for n keys }
  end;

  PLeafNode = ^TLeafNode;
  TLeafNode = record
    PageType: TPageType;
    KeyCount: Word;
    NextLeaf: TPageNum;  { For range queries }
    Entries: array[0..MAX_KEYS-1] of TLeafEntry;
  end;

  POverflowPage = ^TOverflowPage;
  TOverflowPage = record
    PageType: TPageType;
    ValueCount: Word;
    NextOverflow: TPageNum;
    Values: array[0..MAX_OVERFLOW-1] of TKeyValue;
  end;

{ Low-level page I/O }

function AllocatePage(var tree: TBTree): TPageNum;
begin
  AllocatePage := tree.Header.NextFreePage;
  Inc(tree.Header.NextFreePage);
  Inc(tree.Header.PageCount);
end;

procedure WriteHeader(var tree: TBTree);
var
  page: array[0..PAGE_SIZE-1] of Byte;
  i: Integer;
begin
  FillChar(page, PAGE_SIZE, 0);

  { Write header to page 0 }
  for i := 0 to 3 do
    page[i] := Ord(tree.Header.Magic[i]);

  Move(tree.Header.Version, page[4], 2);
  Move(tree.Header.Order, page[6], 2);
  Move(tree.Header.RootPage, page[8], 4);
  Move(tree.Header.NextFreePage, page[12], 4);
  Move(tree.Header.PageCount, page[16], 4);

  Seek(tree.FileHandle, 0);
  BlockWrite(tree.FileHandle, page, PAGE_SIZE);
end;

procedure ReadHeader(var tree: TBTree);
var
  page: array[0..PAGE_SIZE-1] of Byte;
  i: Integer;
begin
  Seek(tree.FileHandle, 0);
  BlockRead(tree.FileHandle, page, PAGE_SIZE);

  for i := 0 to 3 do
    tree.Header.Magic[i] := Chr(page[i]);

  Move(page[4], tree.Header.Version, 2);
  Move(page[6], tree.Header.Order, 2);
  Move(page[8], tree.Header.RootPage, 4);
  Move(page[12], tree.Header.NextFreePage, 4);
  Move(page[16], tree.Header.PageCount, 4);
end;

procedure WriteLeafNode(var tree: TBTree; pageNum: TPageNum; var node: TLeafNode);
var
  page: array[0..PAGE_SIZE-1] of Byte;
  offset: Integer;
  i, j: Integer;
begin
  FillChar(page, PAGE_SIZE, 0);

  page[0] := Ord(ptLeaf);
  Move(node.KeyCount, page[1], 2);
  Move(node.NextLeaf, page[3], 4);

  offset := 7;
  for i := 0 to node.KeyCount - 1 do
  begin
    Move(node.Entries[i].Key, page[offset], 4);
    Inc(offset, 4);
    Move(node.Entries[i].ValueCount, page[offset], 2);
    Inc(offset, 2);

    for j := 0 to node.Entries[i].ValueCount - 1 do
    begin
      Move(node.Entries[i].Values[j], page[offset], 4);
      Inc(offset, 4);
    end;

    Move(node.Entries[i].OverflowPage, page[offset], 4);
    Inc(offset, 4);
  end;

  Seek(tree.FileHandle, pageNum * PAGE_SIZE);
  BlockWrite(tree.FileHandle, page, PAGE_SIZE);
end;

procedure ReadLeafNode(var tree: TBTree; pageNum: TPageNum; var node: TLeafNode);
var
  page: array[0..PAGE_SIZE-1] of Byte;
  offset: Integer;
  i, j: Integer;
begin
  Seek(tree.FileHandle, pageNum * PAGE_SIZE);
  BlockRead(tree.FileHandle, page, PAGE_SIZE);

  node.PageType := TPageType(page[0]);
  Move(page[1], node.KeyCount, 2);
  Move(page[3], node.NextLeaf, 4);

  offset := 7;
  for i := 0 to node.KeyCount - 1 do
  begin
    Move(page[offset], node.Entries[i].Key, 4);
    Inc(offset, 4);
    Move(page[offset], node.Entries[i].ValueCount, 2);
    Inc(offset, 2);

    for j := 0 to node.Entries[i].ValueCount - 1 do
    begin
      Move(page[offset], node.Entries[i].Values[j], 4);
      Inc(offset, 4);
    end;

    Move(page[offset], node.Entries[i].OverflowPage, 4);
    Inc(offset, 4);
  end;
end;

{ Tree Operations }

function CreateBTree(fileName: String): Boolean;
var
  f: File;
  tree: TBTree;
  rootNode: TLeafNode;
begin
  CreateBTree := False;

  Assign(f, fileName);
  {$I-}
  Rewrite(f, 1);
  {$I+}

  if IOResult <> 0 then
    Exit;

  tree.FileHandle := f;
  tree.FileName := fileName;

  { Initialize header }
  tree.Header.Magic := MAGIC;
  tree.Header.Version := VERSION;
  tree.Header.Order := ORDER;
  tree.Header.RootPage := 1;
  tree.Header.NextFreePage := 2;
  tree.Header.PageCount := 2;

  { Write header }
  WriteHeader(tree);

  { Create empty root leaf node }
  FillChar(rootNode, SizeOf(rootNode), 0);
  rootNode.PageType := ptLeaf;
  rootNode.KeyCount := 0;
  rootNode.NextLeaf := 0;

  WriteLeafNode(tree, 1, rootNode);

  Close(tree.FileHandle);
  CreateBTree := True;
end;

function OpenBTree(var tree: TBTree; fileName: String): Boolean;
var
  f: File;
begin
  OpenBTree := False;

  Assign(f, fileName);
  {$I-}
  Reset(f, 1);
  {$I+}

  if IOResult <> 0 then
    Exit;

  tree.FileHandle := f;
  tree.FileName := fileName;
  tree.IsOpen := True;

  ReadHeader(tree);

  { Verify magic number }
  if tree.Header.Magic <> MAGIC then
  begin
    Close(tree.FileHandle);
    tree.IsOpen := False;
    Exit;
  end;

  OpenBTree := True;
end;

procedure CloseBTree(var tree: TBTree);
begin
  if tree.IsOpen then
  begin
    WriteHeader(tree);
    Close(tree.FileHandle);
    tree.IsOpen := False;
  end;
end;

{ Simple insert - assumes root is a leaf (no splitting yet) }
function Insert(var tree: TBTree; key: TKeyValue; value: TKeyValue): Boolean;
var
  rootNode: TLeafNode;
  i, j: Integer;
  found: Boolean;
begin
  Insert := False;

  if not tree.IsOpen then
    Exit;

  ReadLeafNode(tree, tree.Header.RootPage, rootNode);

  { Find key or insertion point }
  found := False;
  i := 0;
  while (i < rootNode.KeyCount) and (rootNode.Entries[i].Key < key) do
    Inc(i);

  if (i < rootNode.KeyCount) and (rootNode.Entries[i].Key = key) then
  begin
    { Key exists, add value }
    found := True;
    if rootNode.Entries[i].ValueCount < MAX_VALUES then
    begin
      rootNode.Entries[i].Values[rootNode.Entries[i].ValueCount] := value;
      Inc(rootNode.Entries[i].ValueCount);
    end
    else
    begin
      { Need overflow page - simplified: just fail for now }
      Exit;
    end;
  end
  else
  begin
    { Insert new key }
    if rootNode.KeyCount >= MAX_KEYS then
      Exit; { Need to split - not implemented yet }

    { Shift entries to make room }
    for j := rootNode.KeyCount downto i + 1 do
      rootNode.Entries[j] := rootNode.Entries[j - 1];

    { Insert new entry }
    rootNode.Entries[i].Key := key;
    rootNode.Entries[i].ValueCount := 1;
    rootNode.Entries[i].Values[0] := value;
    rootNode.Entries[i].OverflowPage := 0;
    Inc(rootNode.KeyCount);
  end;

  WriteLeafNode(tree, tree.Header.RootPage, rootNode);
  Insert := True;
end;

function Find(var tree: TBTree; key: TKeyValue; var values: array of TKeyValue;
              var count: Integer): Boolean;
var
  rootNode: TLeafNode;
  i, j: Integer;
begin
  Find := False;
  count := 0;

  if not tree.IsOpen then
    Exit;

  ReadLeafNode(tree, tree.Header.RootPage, rootNode);

  { Linear search in root }
  for i := 0 to rootNode.KeyCount - 1 do
  begin
    if rootNode.Entries[i].Key = key then
    begin
      { Copy values }
      for j := 0 to rootNode.Entries[i].ValueCount - 1 do
      begin
        if count < High(values) then
        begin
          values[count] := rootNode.Entries[i].Values[j];
          Inc(count);
        end;
      end;
      Find := True;
      Exit;
    end;
  end;
end;

function Delete(var tree: TBTree; key: TKeyValue): Boolean;
var
  rootNode: TLeafNode;
  i, j: Integer;
begin
  Delete := False;

  if not tree.IsOpen then
    Exit;

  ReadLeafNode(tree, tree.Header.RootPage, rootNode);

  { Find key }
  for i := 0 to rootNode.KeyCount - 1 do
  begin
    if rootNode.Entries[i].Key = key then
    begin
      { Shift entries left }
      for j := i to rootNode.KeyCount - 2 do
        rootNode.Entries[j] := rootNode.Entries[j + 1];

      Dec(rootNode.KeyCount);
      WriteLeafNode(tree, tree.Header.RootPage, rootNode);
      Delete := True;
      Exit;
    end;
  end;
end;

function DeleteValue(var tree: TBTree; key: TKeyValue; value: TKeyValue): Boolean;
var
  rootNode: TLeafNode;
  i, j, k: Integer;
begin
  DeleteValue := False;

  if not tree.IsOpen then
    Exit;

  ReadLeafNode(tree, tree.Header.RootPage, rootNode);

  { Find key }
  for i := 0 to rootNode.KeyCount - 1 do
  begin
    if rootNode.Entries[i].Key = key then
    begin
      { Find value }
      for j := 0 to rootNode.Entries[i].ValueCount - 1 do
      begin
        if rootNode.Entries[i].Values[j] = value then
        begin
          { Shift values left }
          for k := j to rootNode.Entries[i].ValueCount - 2 do
            rootNode.Entries[i].Values[k] := rootNode.Entries[i].Values[k + 1];

          Dec(rootNode.Entries[i].ValueCount);

          { If no values left, delete the key }
          if rootNode.Entries[i].ValueCount = 0 then
          begin
            for k := i to rootNode.KeyCount - 2 do
              rootNode.Entries[k] := rootNode.Entries[k + 1];
            Dec(rootNode.KeyCount);
          end;

          WriteLeafNode(tree, tree.Header.RootPage, rootNode);
          DeleteValue := True;
          Exit;
        end;
      end;
    end;
  end;
end;

{ Utility Functions }

function StringKey(s: Str255): TKeyValue;
var
  lowerStr: Str255;
  data: array[0..254] of Byte;
  i: Integer;
  crc: Word;
begin
  { Convert to lowercase }
  lowerStr := LowerCase(s);

  { Convert string to byte array }
  for i := 1 to Length(lowerStr) do
    data[i - 1] := Ord(lowerStr[i]);

  { Calculate CRC16 }
  crc := CRC16(data, Length(lowerStr));

  { Convert to LongInt (zero-extend the Word) }
  StringKey := LongInt(crc);
end;

end.
