# Text Based User Interface

The `UI` unit provides helper functions for implementing text-based user interfaces.
It uses the `ANSI` unit to support ANSI control codes and the `Color` unit to support colors.

## Core Types

The `TAlignment` enum lists possible text alignments.

| Value   | Description   |
| ------- | ------------- |
| aLeft   | Left Aligned  |
| aCenter | Centered      |
| aRight  | Right Aligned |

The `TScreenType` enum denotes the character set used for drawing characters.

| Value    | Description                   |
| -------- | ----------------------------- |
| stASCII  | Only use 7bit ASCII           |
| stANSI   | CP437 - IBM PC                |
| stVT100  | VT100 Alternate Character Set |

**Note: The ASCII and VT100 character sets only provide characters for drawing simple boxes. ANSI and Unicode provide double line boxes and shading.**

The `TBorderType` enum denotes the type of border to draw.

| Value    | Description                            |
| -------- | -------------------------------------- |
| btSingle | Single line border                     |
| btDouble | Double line border (ANSI only)    |

The `TScreen` type keeps track of information related to the screen.

| Field      | Type        | Notes                             |
| ---------- | ----------- | --------------------------------- |
| Output     | PText       | The output stream                 |
| Height     | TInt        | Height in Characters              |
| Width      | TInt        | Width in Characters               |
| IsANSI     | Boolean     | Supports ANSI Control Characters  |
| IsColor    | Boolean     | Supports color                    |
| ScreenType | TScreenType | Screen Type (for drawing boxes)   |

The `TBox` type keeps track of the size and location of a square box.

| Field  | Type |
| ------ | -----|
| Row    | TInt |
| Column | TInt |
| Height | TInt |
| Width  | TInt |

## Core Drawing Procedures

- ClearBox(TScreen, TBox, TColor)
  - Clear the screen within the given box
- DrawBox(TScreen, TBox, TBorderType, TColor, TBoxContentCallback)
  - Draw a border around the given box with optional content via callback
  - Pass `nil` for the callback parameter to draw an empty box
- WriteText(TScreen, TBox, TColor, TAlignment, OffsetR, OffsetC: TInt, Str255): TInt
  - Writes text into a box, returns number of characters displayed
- WriteHeader(TScreen, TBox, TColor, TAlignment, OffsetR, OffsetC: TInt, Str255): TInt
  - Writes text on the box's first row, returns number of characters displayed
- WriteFooter(TScreen, TBox, TColor, TAlignment, OffsetR, OffsetC: TInt, Str255): TInt
  - Writes text on the box's last row, returns number of characters displayed

### TBoxContentCallback

The `TBoxContentCallback` is a function type used by `DrawBox` to provide content for each line inside the box.

**Type Definition:**

```pascal
TBoxContentCallback = function(row: TInt; var text: Str255; var alignment: TAlignment): Boolean;
```

**Parameters:**

- `row`: The row number (1-based) relative to the box interior (row 1 is the first line after the top border)
- `text`: Output parameter - the text to display on this row
- `alignment`: Output parameter - the alignment for this row (aLeft, aCenter, or aRight)

**Return Value:**

- `True` if content is provided for this row
- `False` if the row should be empty (filled with spaces)

**Notes:**

- The callback is called once for each content row in the box
- Text longer than the available width (box width - 2) will be truncated
- The callback can maintain state in a global or external variable to track position across multiple rows

**Example Usage:**

```pascal
{ Callback function to display line numbers }
function ShowLineNumber(row: TInt; var text: Str255; var alignment: TAlignment): Boolean;
begin
  text := 'Line ' + IntToStr(row);
  alignment := aCenter;
  ShowLineNumber := True;
end;

{ Draw a box with line numbers }
DrawBox(screen, myBox, btSingle, myColor, ShowLineNumber);
```

### ClearBox

Algorithm:

```pascal
Row := Box.Row;
Column := Box.Column;
Height := Min(Box.Height, Screen.Height - Row);
Width := Min(Box.Width, Screen.Width - Column);
Output := Screen.Output;

MoveTo(Row, Column);
SetColor(Color);

For i := 1 to Height do
    For j := 1 to Width
        Write(Output, ' ')
```

### DrawBox

Algorithm:

```pascal
Row := Box.Row;
Column := Box.Column;
Height := Min(Box.Height, Screen.Height - Row);
Width := Min(Box.Width, Screen.Width - Column);
Output := Screen.Output;

{ Position cursor if ANSI supported }
If Screen.IsANSI Then
    CursorPosition(Output, Row, Column);

SetColor(Color);

{ Enable VT100 character set if needed }
If (Screen.ScreenType = stVT100) Then
    SetSecondaryCharacterSet(Output, csDrawing);

{ Draw top border sequentially }
Write(Output, TopLeft);
For i := 1 to (Width - 2) do
    Write(Output, HorizontalLineChar);
Write(Output, TopRightCorner);
If Not Screen.IsANSI Then WriteLn(Output);

{ Draw content lines with callback }
For i := 1 to (Height - 2) do
Begin
    If Screen.IsANSI Then
        CursorPosition(Output, Row + i, Column);

    Write(Output, VerticalLineChar);

    { Get content from callback if provided }
    If Assigned(ContentCallback) Then
        HasContent := ContentCallback(i, Text, Alignment)
    Else
        HasContent := False;

    { Render content according to alignment or fill with spaces }
    If HasContent Then
        RenderAlignedText(Text, Alignment, Width - 2)
    Else
        WriteSpaces(Width - 2);

    Write(Output, VerticalLineChar);
    If Not Screen.IsANSI Then WriteLn(Output);
End;

{ Draw bottom border }
If Screen.IsANSI Then
    CursorPosition(Output, Row + Height - 1, Column);

Write(Output, BottomLeft);
For i := 1 to (Width - 2) do
    Write(Output, HorizontalLineChar);
Write(Output, BottomRightCorner);
If Not Screen.IsANSI Then WriteLn(Output);
```

#### Box Drawing Characters

Each of the character sets handles box drawing differently.

**Note: Box drawing doesn't work unless the client supports ANSI escape codes. This is a known limitation that will be addressed later on.**

ASCII:

| Name         | Char | C |
| ------------ | ---- | - |
| TopLeft      | 0x2B | + |
| TopCenter    | 0x2B | + |
| TopRight     | 0x2B | + |
| CenterLeft   | 0x2B | + |
| Center       | 0x2B | + |
| CenterRight  | 0x2B | + |
| BottomLeft   | 0x2B | + |
| BottomCenter | 0x2B | + |
| BottomRight  | 0x2B | + |
| Horizontal   | 0x2D | - |
| Vertical     | 0x7C | \| |

ANSI:

| Name         | Char | C |
| ------------ | ---- | - |
| TopLeft      | 0xDA | ┌ |
| TopCenter    | 0xC2 | ┬ |
| TopRight     | 0xBF | ┐ |
| CenterLeft   | 0xC3 | ├ |
| Center       | 0xC5 | ┼ |
| CenterRight  | 0xB4 | ┤ |
| BottomLeft   | 0xC0 | └ |
| BottomCenter | 0xC1 | ┴ |
| BottomRight  | 0xD9 | ┘ |
| Horizontal   | 0xC4 | ─ |
| Vertical     | 0xB3 | │ |

VT100:

| Name         | Char | C |
| ------------ | ---- | - |
| TopLeft      | 0x2F | ┌ |
| TopCenter    | 0xC2 | ┬ |
| TopRight     | 0x5C | ┐ |
| CenterLeft   | 0xC3 | ├ |
| Center       | 0xC5 | ┼ |
| CenterRight  | 0xB4 | ┤ |
| BottomLeft   | 0x5C | └ |
| BottomCenter | 0xC1 | ┴ |
| BottomRight  | 0x2F | ┘ |
| Horizontal   | 0x2D | ─ |
| Vertical     | 0x7C | │ |
| StartDrawing | 0x0E |   |
| StopDrawing  | 0x0F |   |

**NOTE: To use the VT100 drawing characters, you must call SetSecondaryCharacterSet(output, csDrawing) first, then send SI (0x0E) before any drawing characters and SO (0x0F) afterwards.**

**NOTE: UTF-8 characters are listed here, but they are not used in the code at this time.**

UTF-8:

| Name         | Codepoint | Char Sequence  | C |
| ------------ | --------- | -------------- | - |
| TopLeft      | U+250C    | 0xE2 0x94 0x8C | ┌ |
| TopCenter    | U+252C    | 0xE2 0x94 0xAC | ┬ |
| TopRight     | U+2510    | 0xE2 0x94 0x90 | ┐ |
| CenterLeft   | U+251C    | 0xE2 0x94 0x9C | ├ |
| Center       | U+253C    | 0xE2 0x94 0xBC | ┼ |
| CenterRight  | U+2524    | 0xE2 0x94 0xA4 | ┤ |
| BottomLeft   | U+2514    | 0xE2 0x94 0x94 | └ |
| BottomCenter | U+2534    | 0xE2 0x94 0xB4 | ┴ |
| BottomRight  | U+2518    | 0xE2 0x94 0x98 | ┘ |
| Horizontal   | U+2500    | 0xE2 0x94 0x80 | ─ |
| Vertical     | U+2502    | 0xE2 0x94 0x82 | │ |

### WriteText

Algorithm:

```pascal
Row := Box.Row;
Column := Box.Column;
Height := Min(Box.Height, Screen.Height - Row + 1);
Width := Min(Box.Width, Screen.Width - Column + 1);
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            Output := Screen.Output;
TextLength := Length(Text);

{ Set color }
SetColor(Output, Color.FG, Color.BG);

{ Initialize for wrapping }
CurrentRow := Row + OffsetR;
TextPos := 1;
Remaining := TextLength;

{ Write text with wrapping }
While (Remaining > 0) And (CurrentRow < Row + Height) Do
Begin
    { Calculate how much text fits on this line }
    LineLength := Min(Remaining, Width);

    { Try to break at whitespace if not the last line }
    If (LineLength < Remaining) And (LineLength > 0) Then
    Begin
        { Look for the last space in this segment }
        LastSpace := 0;
        For i := LineLength DownTo 1 Do
        Begin
            If Text[TextPos + i - 1] = ' ' Then
            Begin
                LastSpace := i;
                Break;
            End;
        End;

        { If we found a space, break there }
        If LastSpace > 0 Then
            LineLength := LastSpace;
    End;

    LineText := Copy(Text, TextPos, LineLength);

    { Calculate starting column based on alignment }
    Case Alignment of
        aLeft: StartColumn := Column + OffsetC;
        aCenter: StartColumn := Column + ((Width - LineLength) div 2) + OffsetC;
        aRight: StartColumn := Column + (Width - LineLength) + OffsetC;
    End;

    { Move cursor and write this line of text }
    CursorPosition(Output, CurrentRow, StartColumn);
    Write(Output, LineText);

    { Move to next line }
    TextPos := TextPos + LineLength;
    Remaining := Remaining - LineLength;
    CurrentRow := CurrentRow + 1;
End;
```

## WriteHeader

Algorithm:

```pascal
var HeaderBox: Box;
HeaderBox.Row := Box.Row;
HeaderBox.Column := Box.Column;
HeaderBox.Height := 1;
Headerbox.Width := Box.Width;
WriteText(Screen, HeaderBox, Color, Alignment, OffsetR, OffsetC, Text)
```

## WriteFooter

Algorithm:

```pascal
var FooterBox: Box;
FooterBox.Row := Box.Row + Box.Height - 1;
FooterBox.Column := Box.Column;
FooterBox.Height := 1;
FooterBox.Width := Box.Width;
WriteText(Screen, FooterBox, Color, Alignment, OffsetR, OffsetC, Text)
```
