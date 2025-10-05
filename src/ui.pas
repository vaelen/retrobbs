unit UI;

{
  Text Based User Interface

  The UI unit provides helper functions for implementing text-based user
  interfaces. It uses the ANSI unit to support ANSI control codes.
}

interface

uses
  ANSI, BBSTypes;

type
  { TColor keeps track of a foreground and background color pair }
  TColor = record
    FG: TInt;  { Foreground: 0 - 15 }
    BG: TInt;  { Background: 0 - 15 }
  end;

  { TAlignment lists possible text alignments }
  TAlignment = (
    aLeft,    { Left Aligned }
    aCenter,  { Centered }
    aRight    { Right Aligned }
  );

  { TScreenType denotes the character set used for drawing characters }
  TScreenType = (
    stASCII,  { Only use 7bit ASCII }
    stANSI,   { CP437 - IBM PC }
    stVT100,  { VT100 Alternate Character Set }
    stUTF8    { Unicode drawing characters }
  );

  { TBorderType denotes the type of border to draw }
  TBorderType = (
    btSingle,   { Single line border }
    btDouble    { Double line border (ANSI/UTF8 only) }
  );

  { PText is a pointer to a Text file }
  PText = ^Text;

  { TScreen keeps track of information related to the screen }
  TScreen = record
    Output: PText;         { The output stream }
    Height: TInt;          { Height in Characters }
    Width: TInt;           { Width in Characters }
    IsANSI: Boolean;       { Supports ANSI Control Characters }
    IsColor: Boolean;      { Supports color }
    ScreenType: TScreenType;  { Screen Type (for drawing boxes) }
  end;

  { TBox keeps track of the size and location of a square box }
  TBox = record
    Row: TInt;     { Row position (1-based) }
    Column: TInt;  { Column position (1-based) }
    Height: TInt;  { Height in characters }
    Width: TInt;   { Width in characters }
  end;

{ Core Drawing Procedures }

{ ClearBox clears the screen within the given box }
procedure ClearBox(var screen: TScreen; box: TBox; color: TColor);

{ DrawBox draws a border around the given box }
procedure DrawBox(var screen: TScreen; box: TBox; borderType: TBorderType; color: TColor);

{ WriteText writes text into a box }
procedure WriteText(var screen: TScreen; box: TBox; color: TColor; alignment: TAlignment; offsetR, offsetC: TInt; text: Str255);

{ WriteHeader writes text on the box's first row }
procedure WriteHeader(var screen: TScreen; box: TBox; color: TColor; alignment: TAlignment; offsetR, offsetC: TInt; text: Str255);

{ WriteFooter writes text on the box's last row }
procedure WriteFooter(var screen: TScreen; box: TBox; color: TColor; alignment: TAlignment; offsetR, offsetC: TInt; text: Str255);

implementation

{ Box drawing character tables }
type
  TBoxChars = record
    TopLeft: Char;
    TopRight: Char;
    Horizontal: Char;
    Vertical: Char;
    BottomLeft: Char;
    BottomRight: Char;
  end;

const
  { ASCII box drawing characters }
  ASCIIBoxChars: TBoxChars = (
    TopLeft: '+';
    TopRight: '+';
    Horizontal: '-';
    Vertical: '|';
    BottomLeft: '+';
    BottomRight: '+'
  );

  { ANSI (CP437) box drawing characters }
  ANSIBoxChars: TBoxChars = (
    TopLeft: #$DA;
    TopRight: #$BF;
    Horizontal: #$C4;
    Vertical: #$B3;
    BottomLeft: #$C0;
    BottomRight: #$D9
  );

  { VT100 box drawing characters (used with alternate character set) }
  VT100BoxChars: TBoxChars = (
    TopLeft: '/';
    TopRight: '\';
    Horizontal: '-';
    Vertical: '|';
    BottomLeft: '\';
    BottomRight: '/'
  );

{ Helper function to get minimum of two integers }
function Min(a, b: TInt): TInt;
begin
  if a < b then
    Min := a
  else
    Min := b;
end;

{ ClearBox implementation }
procedure ClearBox(var screen: TScreen; box: TBox; color: TColor);
var
  row, column, height, width: TInt;
  output: PText;
  i, j: TInt;
begin
  row := box.Row;
  column := box.Column;
  height := Min(box.Height, screen.Height - row + 1);
  width := Min(box.Width, screen.Width - column + 1);
  output := screen.Output;

  { Set color }
  if screen.IsColor then
    SetColor(output^, color.FG, color.BG);

  { Clear each line }
  for i := 0 to height - 1 do
  begin
    CursorPosition(output^, row + i, column);
    for j := 1 to width do
      Write(output^, ' ');
  end;
end;

{ DrawBox implementation }
procedure DrawBox(var screen: TScreen; box: TBox; borderType: TBorderType; color: TColor);
var
  row, column, height, width: TInt;
  output: PText;
  i: TInt;
  boxChars: TBoxChars;
begin
  row := box.Row;
  column := box.Column;
  height := Min(box.Height, screen.Height - row + 1);
  width := Min(box.Width, screen.Width - column + 1);
  output := screen.Output;

  { Select appropriate box drawing character set }
  case screen.ScreenType of
    stASCII: boxChars := ASCIIBoxChars;
    stANSI: boxChars := ANSIBoxChars;
    stVT100: boxChars := VT100BoxChars;
    stUTF8: boxChars := ASCIIBoxChars;  { UTF8 will be implemented later }
  end;

  { Set color }
  if screen.IsColor then
    SetColor(output^, color.FG, color.BG);

  { Move to start position }
  CursorPosition(output^, row, column);

  { Enable VT100 alternate character set if needed }
  if screen.ScreenType = stVT100 then
  begin
    SetSecondaryCharacterSet(output^, csDrawing);
    Write(output^, #$0E);  { SI - Shift In to G1 alternate character set }
  end;

  { Draw top line }
  Write(output^, boxChars.TopLeft);
  for i := 1 to width - 2 do
    Write(output^, boxChars.Horizontal);
  Write(output^, boxChars.TopRight);

  { Draw side lines }
  for i := 1 to height - 2 do
  begin
    CursorPosition(output^, row + i, column);
    Write(output^, boxChars.Vertical);
    CursorPosition(output^, row + i, column + width - 1);
    Write(output^, boxChars.Vertical);
  end;

  { Draw bottom line }
  CursorPosition(output^, row + height - 1, column);
  Write(output^, boxChars.BottomLeft);
  for i := 1 to width - 2 do
    Write(output^, boxChars.Horizontal);
  Write(output^, boxChars.BottomRight);

  { Disable VT100 alternate character set if needed }
  if screen.ScreenType = stVT100 then
    Write(output^, #$0F);  { SO - Shift Out to G0 normal character set }
end;

{ WriteText implementation }
procedure WriteText(var screen: TScreen; box: TBox; color: TColor; alignment: TAlignment; offsetR, offsetC: TInt; text: Str255);
var
  row, column, height, width: TInt;
  output: PText;
  textLength: TInt;
  startColumn: TInt;
  currentRow: TInt;
  textPos: TInt;
  lineLength: TInt;
  remaining: TInt;
  lineText: Str255;
  i: TInt;
  lastSpace: TInt;
begin
  row := box.Row;
  column := box.Column;
  height := Min(box.Height, screen.Height - row + 1);
  width := Min(box.Width, screen.Width - column + 1);
  output := screen.Output;
  textLength := Length(text);

  { Set color }
  if screen.IsColor then
    SetColor(output^, color.FG, color.BG);

  { Initialize for wrapping }
  currentRow := row + offsetR;
  textPos := 1;
  remaining := textLength;

  { Write text with wrapping }
  while (remaining > 0) and (currentRow < row + height) do
  begin
    { Calculate how much text fits on this line }
    lineLength := Min(remaining, width);

    { Try to break at whitespace if not the last line }
    if (lineLength < remaining) and (lineLength > 0) then
    begin
      { Look for the last space in this segment }
      lastSpace := 0;
      for i := lineLength downto 1 do
      begin
        if text[textPos + i - 1] = ' ' then
        begin
          lastSpace := i;
          break;
        end;
      end;

      { If we found a space, break there }
      if lastSpace > 0 then
        lineLength := lastSpace;
    end;

    lineText := Copy(text, textPos, lineLength);

    { Calculate starting column based on alignment }
    case alignment of
      aLeft: startColumn := column + offsetC;
      aCenter: startColumn := column + ((width - lineLength) div 2) + offsetC;
      aRight: startColumn := column + (width - lineLength) + offsetC;
    end;

    { Move cursor to position }
    CursorPosition(output^, currentRow, startColumn);

    { Write this line of text }
    Write(output^, lineText);

    { Move to next line }
    textPos := textPos + lineLength;
    remaining := remaining - lineLength;
    currentRow := currentRow + 1;
  end;
end;

{ WriteHeader implementation }
procedure WriteHeader(var screen: TScreen; box: TBox; color: TColor; alignment: TAlignment; offsetR, offsetC: TInt; text: Str255);
var
  headerBox: TBox;
begin
  headerBox.Row := box.Row;
  headerBox.Column := box.Column;
  headerBox.Height := 1;
  headerBox.Width := box.Width;
  WriteText(screen, headerBox, color, alignment, offsetR, offsetC, text);
end;

{ WriteFooter implementation }
procedure WriteFooter(var screen: TScreen; box: TBox; color: TColor; alignment: TAlignment; offsetR, offsetC: TInt; text: Str255);
var
  footerBox: TBox;
begin
  footerBox.Row := box.Row + box.Height - 1;
  footerBox.Column := box.Column;
  footerBox.Height := 1;
  footerBox.Width := box.Width;
  WriteText(screen, footerBox, color, alignment, offsetR, offsetC, text);
end;

end.
