program UIDemo;

{
  UI Framework Demo

  Demonstrates the UI framework by creating randomly placed windows
  with text content loaded from docs/lorem.txt.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  ANSI, BBSTypes, Colors, UI, SysUtils;

function Min(a, b: TInt): TInt;
begin
  if a < b then
    Min := a
  else
    Min := b;
end;

const
  MaxLines = 100;
  MaxWindows = 10;

type
  TLineArray = array[0..MaxLines-1] of Str255;

var
  screen: TScreen;
  lines: TLineArray;
  lineCount: TInt;
  i, j: TInt;
  rows, cols: TInt;
  screenTypeNum: TInt;
  f: Text;
  line: Str255;
  windowCount: TInt;
  box, textBox, footerBox: TBox;
  colorIdx: TInt;
  color: TColor;
  lineIdx: TInt;
  title: Str255;
  footer: Str255;
  spacePos: TInt;
  textLen: TInt;
  charsDisplayed: TInt;
  alignment: TAlignment;
  alignmentNum: TInt;

begin
  { Step 1: Prompt user for screen settings }
  Write('Enter screen rows: ');
  ReadLn(rows);
  Write('Enter screen columns: ');
  ReadLn(cols);
  WriteLn('Screen types:');
  WriteLn('  0 = ASCII');
  WriteLn('  1 = ANSI (CP437)');
  WriteLn('  2 = VT100');
  Write('Enter screen type: ');
  ReadLn(screenTypeNum);

  { Initialize screen }
  screen.Output := @Output;
  screen.Height := rows;
  screen.Width := cols;
  screen.IsANSI := (screenTypeNum > 0);
  screen.IsColor := (screenTypeNum > 0);

  case screenTypeNum of
    0: screen.ScreenType := stASCII;
    1: screen.ScreenType := stANSI;
    2: screen.ScreenType := stVT100;
  else
    screen.ScreenType := stASCII;
  end;

  { Step 2: Set color palette to bright white on blue }
  if screen.IsColor then
    SetColor(Output, 15, 4);

  { Step 3: Clear the screen }
  ClearScreen(Output);
  CursorHome(Output);

  { Step 4: Load docs/lorem.txt }
  lineCount := 0;
  Assign(f, 'docs/lorem.txt');
  {$I-}
  Reset(f);
  {$I+}
  if IOResult = 0 then
  begin
    while (not EOF(f)) and (lineCount < MaxLines) do
    begin
      ReadLn(f, line);
      if Length(line) > 255 then
        SetLength(line, 255);
      lines[lineCount] := line;
      Inc(lineCount);
    end;
    Close(f);
  end
  else
  begin
    WriteLn('Error: Could not open docs/lorem.txt');
    Halt(1);
  end;

  if lineCount = 0 then
  begin
    WriteLn('Error: No lines read from docs/lorem.txt');
    Halt(1);
  end;

  { Initialize random number generator }
  Randomize;

  { Step 5: Create randomly placed windows }
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
    { Blue background colors are at indices: 4, 5, 6, 30 }
    repeat
      colorIdx := Random(32);
      color := ColorPalettes[colorIdx];
    until color.BG <> 4;  { Skip colors with blue background }

    { Choose random line of text }
    lineIdx := Random(lineCount);
    line := lines[lineIdx];
    textLen := Length(line);

    { Clear box with opaque background }
    ClearBox(screen, box, color);

    { Draw border }
    DrawBox(screen, box, btSingle, color);

    { Extract first 2 words for title }
    title := '';
    spacePos := Pos(' ', line);
    if spacePos > 0 then
    begin
      title := Copy(line, 1, spacePos - 1);
      { Find second word }
      j := spacePos + 1;
      while (j <= Length(line)) and (line[j] = ' ') do
        Inc(j);
      spacePos := j;
      while (spacePos <= Length(line)) and (line[spacePos] <> ' ') do
        Inc(spacePos);
      if spacePos <= Length(line) then
        title := title + ' ' + Copy(line, j, spacePos - j)
      else if j <= Length(line) then
        title := title + ' ' + Copy(line, j, Length(line) - j + 1);
    end
    else
      title := Copy(line, 1, Min(10, Length(line)));

    { Write centered title on border }
    if Length(title) > 0 then
      WriteHeader(screen, box, color, aCenter, 0, 0, title);

    { Create text box inside border (1 row down, 1 col right, 2 less height/width) }
    textBox.Row := box.Row + 1;
    textBox.Column := box.Column + 1;
    textBox.Height := box.Height - 2;
    textBox.Width := box.Width - 2;

    { Choose random alignment }
    alignmentNum := Random(3);
    case alignmentNum of
      0: alignment := aLeft;
      1: alignment := aCenter;
      2: alignment := aRight;
    else
      alignment := aLeft;
    end;

    { Write text content }
    if textBox.Height > 0 then
      charsDisplayed := WriteText(screen, textBox, color, alignment, 0, 0, line)
    else
      charsDisplayed := 0;

    { Create footer label "X of Y" }
    footer := IntToStr(charsDisplayed) + ' of ' + IntToStr(textLen);

    { Create temporary box for footer aligned to right edge }
    { Right edge at column + width - Length(footer) - 4 }
    footerBox.Row := box.Row + box.Height - 1;
    footerBox.Column := box.Column + box.Width - Length(footer) - 4;
    footerBox.Height := 1;
    footerBox.Width := Length(footer) + 2;

    { Write footer }
    WriteFooter(screen, box, color, aRight, 0, -2, footer);
  end;

  { Position cursor at bottom }
  CursorPosition(Output, screen.Height, 1);
  WriteLn;
end.
