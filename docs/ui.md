# Text Based User Interface

The `UI` unit provides helper functions for implementing text-based user interfaces.
It uses the `ANSI` unit to support ANSI control codes.

## Core Types

The `TColor` type keeps track of a foreground and background color pair.
| Field | Type | Notes              |
| ----- | -----| -------------------|
| FG    | TInt | Foreground: 0 - 15 |
| BG    | TInt | Background: 0 - 15 |

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
| stUTF8   | Unicode drawing characters    |

**Note: The ASCII and VT100 character sets only provide characters for drawing simple boxes. ANSI and Unicode provide double line boxes and shading.**

The `TBorderType` enum denotes the type of border to draw.
| Value    | Description                            |
| -------- | -------------------------------------- |
| btSingle | Single line border                     |
| btDouble | Double line border (ANSI/UTF8 only)    |

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

| Name                                                                           | Description                                                          |
| ------------------------------------------------------------------------------ | -------------------------------------------------------------------- |
| ClearBox(TScreen, TBox, TColor)                                                | Clear the screen within the given box                                |
| DrawBox(TScreen, TBox, TBorderType, TColor)                                    | Draw a border around the given box                                   |
| WriteText(TScreen, TBox, TColor, TAlignment, OffsetR, OffsetC: TInt, Str255): TInt   | Writes text into a box, returns number of characters displayed       |
| WriteHeader(TScreen, TBox, TColor, TAlignment, OffsetR, OffsetC: TInt, Str255): TInt | Writes text on the box's first row, returns number of characters displayed |
| WriteFooter(TScreen, TBox, TColor, TAlignment, OffsetR, OffsetC: TInt, Str255): TInt | Writes text on the box's last row, returns number of characters displayed |

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

MoveTo(Row, Column);
SetColor(Color);

If (Screen.ScreenType = stVT100) Then
Begin
    SetSecondaryCharacterSet(Output, csDrawing)
    Write(Output, StartDrawing);
End;

Write(Output, TopLeftCornerChar);
For i := 1 to (Width - 2) do
    Write(Output, HorizontalLineChar);
Write(Output, TopRightCorner);

For i : = 1 to (Height - 2) do
Begin
    MoveTo(Row + i, Column);
    Write(Output, VerticalLineChar);
    MoveTo(Row + i, Column + Width);
    Write(Output, VerticalLineChar);
End;

Write(Screen.Output, BottomLeftCornerChar);
For i := 1 to (FinalWidth - 2) do
    Write(Output, HorizontalLineChar);
Write(Output, BottomRightCorner);

If (Screen.ScreenType = stVT100) Then
    Write(Output, StopDrawing);

```

#### Box Drawing Characters

Each of the character sets handles box drawing differently.

**Note: Box drawing doesn't work unless the client supports ANSI escape codes. This is a known limitation that will be addressed later on.**

ASCII:
| Name                  | Char | C |
| --------------------- | ---- | - |
| TopLeftCornerChar     | 0x2B | + |
| TopRightCornerChar    | 0x2B | + |
| HorizontalChar        | 0x2D | - |
| VeticalChar           | 0x7C | \| |
| BottomLeftCornerChar  | 0x2B | + |
| BottomRightCornerChar | 0x2B | + |

ANSI:
| Name                  | Char | C |
| --------------------- | ---- | - |
| TopLeftCornerChar     | 0xDA | ┼ |
| TopRightCornerChar    | 0xBF | ┐ |
| HorizontalChar        | 0xC4 | ─ |
| VeticalChar           | 0xB3 | │ |
| BottomLeftCornerChar  | 0xC0 | └ |
| BottomRightCornerChar | 0xD9 | ┘ |
| SplitRight            | 0xC3 | ├ |
| SplitLeft             | 0xB4 | ┤ |
| SplitDown             | 0xC2 | ┬ |
| SplitUp               | 0xC1 | ┴ |
| SplitAll              | 0xC5 | ┼ |

VT100:
| Name                  | Char | C |
| --------------------- | ---- | - |
| TopLeftCornerChar     | 0x2F | ┼ |
| TopRightCornerChar    | 0x5C | ┐ |
| HorizontalChar        | 0x2D | ─ |
| VeticalChar           | 0x7C | │ |
| BottomLeftCornerChar  | 0x5C | └ |
| BottomRightCornerChar | 0x2F | ┘ |
| SplitRight            | 0xC3 | ├ |
| SplitLeft             | 0xB4 | ┤ |
| SplitDown             | 0xC2 | ┬ |
| SplitUp               | 0xC1 | ┴ |
| SplitAll              | 0xC5 | ┼ |
| StartDrawing          | 0x0E |   |
| StopDrawing           | 0x0F |   |

**NOTE: To use the VT100 drawing characters, you must call SetSecondaryCharacterSet(output, csDrawing) first, then send SI (0x0E) before any drawing characters and SO (0x0F) afterwards.**

UTF8:
| Name                  | Codepoint | Char Sequence  | C |
| --------------------- | --------- | -------------- | - |
| TopLeftCornerChar     | U+250C    | 0xE2 0x94 0x8C | ┼ |
| TopRightCornerChar    | U+2510    | 0xE2 0x94 0x90 | ┐ |
| HorizontalChar        | U+2500    | 0xE2 0x94 0x80 | ─ |
| VeticalChar           | U+2502    | 0xE2 0x94 0x82 | │ |
| BottomLeftCornerChar  | U+2514    | 0xE2 0x94 0x94 | └ |
| BottomRightCornerChar | U+2518    | 0xE2 0x94 0x98 | ┘ |
| SplitRight            | U+251C    | 0xE2 0x94 0x9C | ├ |
| SplitLeft             | U+2524    | 0xE2 0x94 0xA4 | ┤ |
| SplitDown             | U+252C    | 0xE2 0x94 0xAC | ┬ |
| SplitUp               | U+2534    | 0xE2 0x94 0xB4 | ┴ |
| SplitAll              | U+253C    | 0xE2 0x94 0xBC | ┼ |

UTF8 (Rounded):
| Name                  | Codepoint | Char Sequence  | C |
| --------------------- | --------- | -------------- | - |
| TopLeftCornerChar     | U+256D    | 0xE2 0x95 0xAD | ╭ |
| TopRightCornerChar    | U+256E    | 0xE2 0x95 0xAE | ╮ |
| HorizontalChar        | U+2500    | 0xE2 0x94 0x80 | ─ |
| VeticalChar           | U+2502    | 0xE2 0x94 0x82 | │ |
| BottomLeftCornerChar  | U+2570    | 0xE2 0x95 0xB0 | ╰ |
| BottomRightCornerChar | U+256F    | 0xE2 0x95 0xAF | ╯ |
| SplitRight            | U+251C    | 0xE2 0x94 0x9C | ├ |
| SplitLeft             | U+2524    | 0xE2 0x94 0xA4 | ┤ |
| SplitDown             | U+252C    | 0xE2 0x94 0xAC | ┬ |
| SplitUp               | U+2534    | 0xE2 0x94 0xB4 | ┴ |
| SplitAll              | U+253C    | 0xE2 0x94 0xBC | ┼ |

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