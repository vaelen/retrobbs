unit UI;

{
  Text Based User Interface

  The UI unit provides helper functions for implementing text-based user
  interfaces. It uses the ANSI unit to support ANSI control codes.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

interface

uses
  ANSI, BBSTypes, Colors;

const
  SI = #$0E;
  SO = #$0F;

type
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
    stVT100   { VT100 Alternate Character Set }
  );

  { TBorderType denotes the type of border to draw }
  TBorderType = (
    btSingle,   { Single line border }
    btDouble    { Double line border (ANSI only) }
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

  { TBoxChar is a box drawing character }
  TBoxChar = char;

  { TBoxChars contains all box drawing characters for a character set }
  TBoxChars = record
    TopLeft: TBoxChar;
    TopCenter: TBoxChar;
    TopRight: TBoxChar;
    CenterLeft: TBoxChar;
    Center: TBoxChar;
    CenterRight: TBoxChar;
    BottomLeft: TBoxChar;
    BottomCenter: TBoxChar;
    BottomRight: TBoxChar;
    Horizontal: TBoxChar;
    Vertical: TBoxChar;
  end;

  { TBoxContentCallback - Callback function for providing box content }
  { Parameters: row (1-based, relative to box interior), var text, var alignment }
  { Returns: True if content provided, False if row should be empty }
  TBoxContentCallback = function(row: TInt; var text: Str255; var alignment: TAlignment): Boolean;

  { TBoxBorderCallback - Callback function for header/footer on borders }
  { Parameters: var text, var color, var alignment, var offset }
  { offset is from left edge if left-aligned, right edge if right-aligned, ignored if centered }
  { Returns: True if text should be displayed, False otherwise }
  TBoxBorderCallback = function(var text: Str255; var color: TColor; var alignment: TAlignment; var offset: TInt): Boolean;

{ Core Drawing Procedures }

{ ClearBox clears the screen within the given box }
procedure ClearBox(var screen: TScreen; box: TBox; color: TColor);

{ DrawBox draws a border around the given box with optional content }
{ contentCallback can be nil for empty box, or provide content for each row }
{ headerCallback can be nil, or provide text to overlay on top border }
{ footerCallback can be nil, or provide text to overlay on bottom border }
procedure DrawBox(var screen: TScreen; box: TBox; borderType: TBorderType; color: TColor; contentCallback: TBoxContentCallback; headerCallback: TBoxBorderCallback; footerCallback: TBoxBorderCallback);

{ WriteText writes text into a box and returns the number of characters displayed }
function WriteText(var screen: TScreen; box: TBox; color: TColor; alignment: TAlignment; offsetR, offsetC: TInt; text: Str255): TInt;

{ Box Drawing Helper Functions }

{ Get appropriate box characters for screen type and border type }
function GetBoxChars(screenType: TScreenType; borderType: TBorderType): TBoxChars;

{ Write a single box drawing character }
procedure WriteBoxChar(var screen: TScreen; ch: TBoxChar);

{ Enable box drawing character set (VT100 shift-in, etc) }
procedure EnableBoxDrawing(var screen: TScreen);

{ Start drawing box characters in VT100 }
procedure StartBoxDrawing(var screen: TScreen);

{ Stop drawing box characters in VT100 }
procedure StopBoxDrawing(var screen: TScreen);

implementation

const
  { ASCII box drawing characters }
  ASCIIBoxChars: TBoxChars = (
    TopLeft: '+';
    TopCenter: '+';
    TopRight: '+';
    CenterLeft: '+';
    Center: '+';
    CenterRight: '+';
    BottomLeft: '+';
    BottomCenter: '+';
    BottomRight: '+';
    Horizontal: '-';
    Vertical: '|'
  );

  { ANSI (CP437) box drawing characters }
  ANSIBoxChars: TBoxChars = (
    TopLeft: #$DA;
    TopCenter: #$C2;
    TopRight: #$BF;
    CenterLeft: #$C3;
    Center: #$C5;
    CenterRight: #$B4;
    BottomLeft: #$C0;
    BottomCenter: #$C1;
    BottomRight: #$D9;
    Horizontal: #$C4;
    Vertical: #$B3
  );

  { VT100 box drawing characters (used with alternate character set) }
  VT100BoxChars: TBoxChars = (
    TopLeft: 'l';
    TopCenter: 'w';
    TopRight: 'k';
    CenterLeft: 't';
    Center: 'n';
    CenterRight: 'u';
    BottomLeft: 'm';
    BottomCenter: 'v';
    BottomRight: 'j';
    Horizontal: 'q';
    Vertical: 'x'
  );

{ Helper function to get minimum of two integers }
function Min(a, b: TInt): TInt;
begin
  if a < b then
    Min := a
  else
    Min := b;
end;

{ Box Drawing Helper Functions }

function GetBoxChars(screenType: TScreenType; borderType: TBorderType): TBoxChars;
begin
  { Select character set based on screen type }
  { borderType currently only affects ANSI (future: double-line support) }
  case screenType of
    stASCII: GetBoxChars := ASCIIBoxChars;
    stANSI: GetBoxChars := ANSIBoxChars;
    stVT100: GetBoxChars := VT100BoxChars;
  else
    GetBoxChars := ASCIIBoxChars;  { Fallback }
  end;
end;

procedure WriteBoxChar(var screen: TScreen; ch: TBoxChar);
begin
  Write(screen.Output^, ch);
end;

procedure EnableBoxDrawing(var screen: TScreen);
begin
  if screen.ScreenType = stVT100 then
  begin
    SetSecondaryCharacterSet(screen.Output^, csDrawing);
  end;
end;

procedure StartBoxDrawing(var screen: TScreen);
begin
  if screen.ScreenType = stVT100 then
    Write(screen.Output^, SI);  { SI - Shift In to G1 alternate character set }
end;

procedure StopBoxDrawing(var screen: TScreen);
begin
  if screen.ScreenType = stVT100 then
    Write(screen.Output^, SO);  { SO - Shift Out to G0 normal character set }
end;

{ ClearBox implementation }
procedure ClearBox(var screen: TScreen; box: TBox; color: TColor);
var
  row, column, height, width: TInt;
  output: PText;
  i, j: TInt;
begin
  { This procedure only makes sense if we support ANSI escape codes }
  if not screen.isANSI then Exit;
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
procedure DrawBox(var screen: TScreen; box: TBox; borderType: TBorderType; color: TColor; contentCallback: TBoxContentCallback; headerCallback: TBoxBorderCallback; footerCallback: TBoxBorderCallback);
var
  row, column, height, width, contentWidth: TInt;
  output: PText;
  i, j, textLen, padLeft, padRight: TInt;
  boxChars: TBoxChars;
  text: Str255;
  alignment: TAlignment;
  hasContent: Boolean;
  borderText: Str255;
  borderColor: TColor;
  borderAlignment: TAlignment;
  borderOffset: TInt;
  borderColumn: TInt;
begin
  row := box.Row;
  column := box.Column;
  height := Min(box.Height, screen.Height - row + 1);
  width := Min(box.Width, screen.Width - column + 1);
  contentWidth := width - 2;  { Width available for content (excluding borders) }
  output := screen.Output;

  { Select appropriate box drawing character set }
  case screen.ScreenType of
    stASCII: boxChars := ASCIIBoxChars;
    stANSI: boxChars := ANSIBoxChars;
    stVT100: boxChars := VT100BoxChars;
  end;

  { Set color }
  if screen.IsColor then
    SetColor(output^, color.FG, color.BG);

  { Move to start position (only if ANSI is supported) }
  if screen.IsANSI then
    CursorPosition(output^, row, column);

  { Enable VT100 alternate character set if needed }
  EnableBoxDrawing(screen);

  { Draw top line with optional header text }
  StartBoxDrawing(screen);
  Write(output^, boxChars.TopLeft);

  { Check if we have header text to render }
  hasContent := False;
  if Assigned(headerCallback) then
    hasContent := headerCallback(borderText, borderColor, borderAlignment, borderOffset);

  if hasContent then
  begin
    { Trim text to fit within border (including spaces) }
    textLen := Length(borderText);
    if textLen > width - 4 then  { -4 for corners and spaces }
    begin
      borderText := Copy(borderText, 1, width - 4);
      textLen := width - 4;
    end;

    { Calculate starting position for text based on alignment }
    case borderAlignment of
      aLeft:
        borderColumn := 1 + borderOffset;
      aRight:
        borderColumn := (width - 2) - textLen - 2 - borderOffset;  { -2 for spaces around text }
      aCenter:
        borderColumn := ((width - 2 - textLen - 2) div 2) + 1;  { -2 for spaces }
    end;

    { Draw horizontal line before text }
    for i := 1 to borderColumn - 1 do
      Write(output^, boxChars.Horizontal);

    { Switch to normal text for header }
    StopBoxDrawing(screen);
    if screen.IsColor then
      SetColor(output^, borderColor.FG, borderColor.BG);
    Write(output^, ' ', borderText, ' ');
    if screen.IsColor then
      SetColor(output^, color.FG, color.BG);

    { Switch back to box drawing and fill rest of line }
    StartBoxDrawing(screen);
    for i := borderColumn + textLen + 2 to width - 2 do
      Write(output^, boxChars.Horizontal);
  end
  else
  begin
    { No header text, just draw horizontal line }
    for i := 1 to width - 2 do
      Write(output^, boxChars.Horizontal);
  end;

  Write(output^, boxChars.TopRight);
  if not screen.IsANSI then
    WriteLn(output^);

  { Disable box drawing for content }
  StopBoxDrawing(screen);

  { Draw content lines }
  for i := 1 to height - 2 do
  begin
    { Position cursor at start of line if ANSI supported }
    if screen.IsANSI then
      CursorPosition(output^, row + i, column);

    { Enable box drawing for left border }
    StartBoxDrawing(screen);
    Write(output^, boxChars.Vertical);
    StopBoxDrawing(screen);

    { Get content for this row if callback provided }
    hasContent := False;
    if Assigned(contentCallback) then
      hasContent := contentCallback(i, text, alignment);

    if hasContent then
    begin
      { Trim text to fit within content width }
      textLen := Length(text);
      if textLen > contentWidth then
      begin
        text := Copy(text, 1, contentWidth);
        textLen := contentWidth;
      end;

      { Calculate padding based on alignment }
      case alignment of
        aLeft:
          begin
            padLeft := 0;
            padRight := contentWidth - textLen;
          end;
        aRight:
          begin
            padLeft := contentWidth - textLen;
            padRight := 0;
          end;
        aCenter:
          begin
            padLeft := (contentWidth - textLen) div 2;
            padRight := contentWidth - textLen - padLeft;
          end;
      else
        begin
          padLeft := 0;
          padRight := contentWidth - textLen;
        end;
      end;

      { Write left padding }
      for j := 1 to padLeft do
        Write(output^, ' ');

      { Write content text }
      Write(output^, text);

      { Write right padding }
      for j := 1 to padRight do
        Write(output^, ' ');
    end
    else
    begin
      { No content - fill with spaces }
      for j := 1 to contentWidth do
        Write(output^, ' ');
    end;

    { Enable box drawing for right border }
    StartBoxDrawing(screen);
    Write(output^, boxChars.Vertical);
    StopBoxDrawing(screen);
    if not screen.IsANSI then
      WriteLn(output^);
  end;

  { Position cursor for bottom line if ANSI supported }
  if screen.IsANSI then
    CursorPosition(output^, row + height - 1, column);

  { Draw bottom line with optional footer text }
  StartBoxDrawing(screen);
  Write(output^, boxChars.BottomLeft);

  { Check if we have footer text to render }
  hasContent := False;
  if Assigned(footerCallback) then
    hasContent := footerCallback(borderText, borderColor, borderAlignment, borderOffset);

  if hasContent then
  begin
    { Trim text to fit within border (including spaces) }
    textLen := Length(borderText);
    if textLen > width - 4 then  { -4 for corners and spaces }
    begin
      borderText := Copy(borderText, 1, width - 4);
      textLen := width - 4;
    end;

    { Calculate starting position for text based on alignment }
    case borderAlignment of
      aLeft:
        borderColumn := 1 + borderOffset;
      aRight:
        borderColumn := (width - 2) - textLen - 2 - borderOffset;  { -2 for spaces around text }
      aCenter:
        borderColumn := ((width - 2 - textLen - 2) div 2) + 1;  { -2 for spaces }
    end;

    { Draw horizontal line before text }
    for i := 1 to borderColumn - 1 do
      Write(output^, boxChars.Horizontal);

    { Switch to normal text for footer }
    StopBoxDrawing(screen);
    if screen.IsColor then
      SetColor(output^, borderColor.FG, borderColor.BG);
    Write(output^, ' ', borderText, ' ');
    if screen.IsColor then
      SetColor(output^, color.FG, color.BG);

    { Switch back to box drawing and fill rest of line }
    StartBoxDrawing(screen);
    for i := borderColumn + textLen + 2 to width - 2 do
      Write(output^, boxChars.Horizontal);
  end
  else
  begin
    { No footer text, just draw horizontal line }
    for i := 1 to width - 2 do
      Write(output^, boxChars.Horizontal);
  end;

  Write(output^, boxChars.BottomRight);
  if not screen.IsANSI then
    WriteLn(output^);

  { Disable VT100 alternate character set if needed }
  StopBoxDrawing(screen);
end;

{ WriteText implementation }
function WriteText(var screen: TScreen; box: TBox; color: TColor; alignment: TAlignment; offsetR, offsetC: TInt; text: Str255): TInt;
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
  charsDisplayed: TInt;
begin
  row := box.Row;
  column := box.Column;
  height := Min(box.Height, screen.Height - row + 1);
  width := Min(box.Width, screen.Width - column + 1);
  output := screen.Output;
  textLength := Length(text);
  charsDisplayed := 0;

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
    if screen.isANSI then
      CursorPosition(output^, currentRow, startColumn);

    { Write this line of text }
    Write(output^, lineText);
    charsDisplayed := charsDisplayed + lineLength;

    { Move to next line }
    textPos := textPos + lineLength;
    remaining := remaining - lineLength;
    currentRow := currentRow + 1;
  end;

  WriteText := charsDisplayed;
end;

end.
