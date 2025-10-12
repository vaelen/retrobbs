program UIDemo;

{
  UI Framework Demo

  Demonstrates the UI framework by creating randomly placed windows
  with text content loaded from docs/lorem.txt.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  ANSI, BBSTypes, Colors, UI, Lists, OSUtils, SysUtils;

function Min(a, b: TInt): TInt;
begin
  if a < b then
    Min := a
  else
    Min := b;
end;

const
  MaxWindows = 10;

type
  { TParagraph stores a dynamically allocated text paragraph }
  PParagraph = ^TParagraph;
  TParagraph = record
    Text: PChar;      { Null-terminated string }
    Length: TInt;     { Length of text }
  end;

  { TBoxContext stores context needed by the callback function }
  PBoxContext = ^TBoxContext;
  TBoxContext = record
    Screen: TScreen;
    Box: TBox;
    Paragraph: PParagraph;
    Alignment: TAlignment;
    CurrentRow: TInt;      { Current row being rendered }
    TextPos: TInt;         { Current position in paragraph text }
    CharsDisplayed: TInt;  { Total characters displayed }
  end;

var
  screen: TScreen;
  paragraphs: TArrayList;
  i, j: TInt;
  f: Text;
  tempLine: String;
  windowCount: TInt;
  box: TBox;
  colorIdx: TInt;
  color: TColor;
  paraIdx: TInt;
  para: PParagraph;
  title: Str255;
  alignmentNum: TInt;
  boxContext: TBoxContext;

{ Helper function to allocate and store a paragraph }
function CreateParagraph(const text: String): PParagraph;
var
  para: PParagraph;
  len: TInt;
begin
  New(para);
  len := Length(text);
  para^.Length := len;

  { Allocate memory for text plus null terminator }
  GetMem(para^.Text, len + 1);

  { Copy string to PChar }
  if len > 0 then
    Move(text[1], para^.Text^, len);
  para^.Text[len] := #0;  { Null terminator }

  CreateParagraph := para;
end;

{ Helper function to free a paragraph }
procedure FreeParagraph(para: PParagraph);
begin
  if para <> nil then
  begin
    if para^.Text <> nil then
      FreeMem(para^.Text);
    Dispose(para);
  end;
end;

{ Helper function to get a word from PChar string }
function GetWord(text: PChar; startPos: TInt; var wordEnd: TInt): String;
var
  len, i: TInt;
  result: String;
begin
  result := '';
  len := StrLen(text);

  { Skip leading spaces }
  while (startPos < len) and (text[startPos] = ' ') do
    Inc(startPos);

  { Get word }
  i := startPos;
  while (i < len) and (text[i] <> ' ') do
  begin
    result := result + text[i];
    Inc(i);
  end;

  wordEnd := i;
  GetWord := result;
end;

{ Callback function for DrawBox header }
function RenderHeader(var text: Str255; var headerColor: TColor; var alignment: TAlignment; var offset: TInt): Boolean;
begin
  if Length(title) > 0 then
  begin
    text := title;
    headerColor := color;
    alignment := aCenter;
    offset := 0;
    RenderHeader := True;
  end
  else
    RenderHeader := False;
end;

{ Callback function for DrawBox footer }
function RenderFooter(var text: Str255; var footerColor: TColor; var alignment: TAlignment; var offset: TInt): Boolean;
begin
  if boxContext.CharsDisplayed > 0 then
  begin
    text := IntToStr(boxContext.CharsDisplayed) + ' of ' + IntToStr(boxContext.Paragraph^.Length);
    footerColor := color;
    alignment := aRight;
    offset := 2;
    RenderFooter := True;
  end
  else
    RenderFooter := False;
end;

{ Callback function for DrawBox to render word-wrapped paragraph text }
function RenderParagraphLine(row: TInt; var text: Str255; var alignment: TAlignment): Boolean;
var
  ctx: PBoxContext;
  lineWidth, wordLen, lineLen: TInt;
  word: String;
  wordEnd: TInt;
  line: Str255;
begin
  { Get context from global variable (passed via pointer) }
  ctx := @boxContext;

  { Set alignment }
  alignment := ctx^.Alignment;

  { Calculate available width (box width - 2 for borders) }
  lineWidth := ctx^.Box.Width - 2;

  { Check if we've finished all text }
  if ctx^.TextPos >= ctx^.Paragraph^.Length then
  begin
    text := '';
    RenderParagraphLine := False;
    Exit;
  end;

  { Build line with word wrapping }
  line := '';
  lineLen := 0;

  while ctx^.TextPos < ctx^.Paragraph^.Length do
  begin
    { Get next word }
    word := GetWord(ctx^.Paragraph^.Text, ctx^.TextPos, wordEnd);
    wordLen := Length(word);

    { If this is the first word or it fits on current line }
    if (lineLen = 0) or (lineLen + 1 + wordLen <= lineWidth) then
    begin
      { Add word to line }
      if lineLen > 0 then
      begin
        line := line + ' ';
        Inc(lineLen);
        Inc(ctx^.CharsDisplayed);
      end;
      line := line + word;
      lineLen := lineLen + wordLen;
      ctx^.CharsDisplayed := ctx^.CharsDisplayed + wordLen;
      ctx^.TextPos := wordEnd;

      { Skip trailing spaces }
      while (ctx^.TextPos < ctx^.Paragraph^.Length) and
            (ctx^.Paragraph^.Text[ctx^.TextPos] = ' ') do
      begin
        Inc(ctx^.TextPos);
        Inc(ctx^.CharsDisplayed);
      end;
    end
    else
    begin
      { Word doesn't fit, break line here }
      break;
    end;
  end;

  text := line;
  RenderParagraphLine := True;
end;

begin
  { Initialize paragraphs list }
  InitArrayList(paragraphs, 0);

  { Initialize screen using OS-specific detection }
  InitializeScreen(screen, Output);

  { Set color palette to bright white on blue }
  if screen.IsColor then
    SetColor(Output, 15, 4);

  { Load docs/lorem.txt - each line becomes a paragraph }
  Assign(f, 'docs/lorem.txt');
  {$I-}
  Reset(f);
  {$I+}
  if IOResult = 0 then
  begin
    while not EOF(f) do
    begin
      ReadLn(f, tempLine);
      { Skip empty lines }
      if Length(tempLine) > 0 then
      begin
        para := CreateParagraph(tempLine);
        AddArrayListItem(paragraphs, para);
      end;
    end;
    Close(f);
  end
  else
  begin
    WriteLn('Error: Could not open docs/lorem.txt');
    Halt(1);
  end;

  if paragraphs.Count = 0 then
  begin
    WriteLn('Error: No paragraphs read from docs/lorem.txt');
    Halt(1);
  end;

  { Initialize random number generator }
  Randomize;

  { Create randomly placed windows }
  windowCount := Random(MaxWindows - 5) + 5;  { 5 to 10 windows }

  for i := 1 to windowCount do
  begin
    { Create random box dimensions and position }
    box.Height := Random(screen.Height div 3) + 5;  { At least 5 rows }
    box.Width := Random(screen.Width div 2) + 20;   { At least 20 cols }

    { Make sure box fits on screen }
    if box.Height > screen.Height then
      box.Height := screen.Height;
    if box.Width > screen.Width then
      box.Width := screen.Width;

    box.Row := Random(screen.Height - box.Height) + 1;
    box.Column := Random(screen.Width - box.Width) + 1;

    { Choose random color from ColorPalettes, excluding blue backgrounds }
    repeat
      colorIdx := Random(32);
      color := ColorPalettes[colorIdx];
    until color.BG <> 4;  { Skip colors with blue background }

    { Choose random paragraph }
    paraIdx := Random(paragraphs.Count);
    para := PParagraph(GetArrayListItem(paragraphs, paraIdx));

    { Choose random alignment }
    alignmentNum := Random(3);
    case alignmentNum of
      0: boxContext.Alignment := aLeft;
      1: boxContext.Alignment := aCenter;
      2: boxContext.Alignment := aRight;
    else
      boxContext.Alignment := aLeft;
    end;

    { Initialize box context for callback }
    boxContext.Screen := screen;
    boxContext.Box := box;
    boxContext.Paragraph := para;
    boxContext.CurrentRow := 1;
    boxContext.TextPos := 0;
    boxContext.CharsDisplayed := 0;

    { Extract first 2 words for title }
    title := '';
    if para^.Length > 0 then
    begin
      title := GetWord(para^.Text, 0, j);
      if j < para^.Length then
        title := title + ' ' + GetWord(para^.Text, j, j);
    end;

    { Clear box with opaque background }
    ClearBox(screen, box, color);

    { Draw box with content, header, and footer using callbacks }
    DrawBox(screen, box, btSingle, color, RenderParagraphLine, RenderHeader, RenderFooter);
  end;

  { Cleanup: Free all paragraphs }
  for i := 0 to paragraphs.Count - 1 do
  begin
    para := PParagraph(GetArrayListItem(paragraphs, i));
    FreeParagraph(para);
  end;
  FreeArrayList(paragraphs);

  { Position cursor at bottom }
  if screen.isANSI then
    CursorPosition(Output, screen.Height, 1);
  WriteLn;
end.