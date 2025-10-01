# ANSI Terminal Display Library

The `ANSI` unit provides a display library for outputing text to an ANSI terminal. This includes support for text decoration such as bold, italic, underline, and colors. It also includes support for moving the cursor around the screen and clearing all of or part of the screen as needed.

## Function Reference

### Cursor Movement

| Done | Function                              | Description                           |
|------|---------------------------------------|---------------------------------------|
| [x]  | CursorUp(lines: Integer)              | Move cursor up specified lines        |
| [x]  | CursorDown(lines: Integer)            | Move cursor down specified lines      |
| [x]  | CursorForward(chars: Integer)         | Move cursor forward specified chars   |
| [x]  | CursorBackward(chars: Integer)        | Move cursor backward specified chars  |
| [x]  | CursorPosition(line, column: Integer) | Move cursor to absolute position      |
| [x]  | CursorHome                            | Move cursor to home position (1,1)    |
| [x]  | SaveCursor                            | Save cursor position and attributes   |
| [x]  | RestoreCursor                         | Restore cursor position and attributes|

### Screen Clearing

| Done | Function                   | Description                                |
|------|----------------------------|--------------------------------------------|
| [x]  | ClearScreen                | Clear entire screen                        |
| [x]  | ClearToEndOfScreen         | Clear from cursor to end of screen         |
| [x]  | ClearToEndOfLine           | Clear from cursor to end of line           |
| [x]  | ClearFromBeginningOfLine   | Clear from beginning of line to cursor     |
| [x]  | ClearLine                  | Clear entire line                          |

### Text Attributes

| Done | Function                                                    | Description                        |
|------|-------------------------------------------------------------|------------------------------------|
| [x]  | ResetAttributes                                             | Reset all text attributes          |
| [x]  | SetBold                                                     | Enable bold text                   |
| [x]  | SetUnderscore                                               | Enable underscored text            |
| [x]  | SetBlink                                                    | Enable blinking text               |
| [x]  | SetReverseVideo                                             | Enable reverse video               |
| [x]  | SetAttributes(bold, underscore, blink, reverse: Boolean)    | Set multiple attributes at once    |

### Line Display Modes

| Done | Function              | Description                              |
|------|-----------------------|------------------------------------------|
| [x]  | SetDoubleHeightTop    | Change line to double-height top half    |
| [x]  | SetDoubleHeightBottom | Change line to double-height bottom half |
| [x]  | SetSingleWidthHeight  | Change line to single-width/height       |
| [x]  | SetDoubleWidthHeight  | Change line to double-width/height       |

### Index Operations

| Done | Function                 | Description                  |
|------|--------------------------|------------------------------|
| [x]  | Index                    | Line feed                    |
| [x]  | ReverseIndex             | Reverse line feed            |
| [x]  | CarriageReturnLineFeed   | Carriage return + line feed  |

### Cursor Visibility

| Done | Function       | Description        |
|------|----------------|--------------------|
| [x]  | ShowCursor     | Show cursor        |
| [x]  | HideCursor     | Hide cursor        |

### Edit Mode

| Done | Function              | Description                          |
|------|-----------------------|--------------------------------------|
| [x]  | SetInsertMode         | Set insert mode                      |
| [x]  | SetReplacementMode    | Set replacement mode                 |
| [x]  | SetEnterImmediate     | Immediate operation of ENTER key     |
| [x]  | SetEnterDeferred      | Deferred operation of ENTER key      |
| [x]  | SetEditImmediate      | Edit selection immediate             |
| [x]  | SetEditDeferred       | Edit selection deferred              |

### Edit Operations

| Done | Function                   | Description                          |
|------|----------------------------|--------------------------------------|
| [x]  | DeleteChar                 | Delete character at cursor           |
| [x]  | DeleteChars(count: Integer)| Delete count chars from cursor       |
| [x]  | DeleteLine                 | Delete line at cursor                |
| [x]  | DeleteLines(count: Integer)| Delete count lines from cursor       |
| [x]  | InsertLine                 | Insert line at cursor                |
| [x]  | InsertLines(count: Integer)| Insert count lines at cursor         |

### Colors

| Done | Function                                    | Description                        |
|------|---------------------------------------------|------------------------------------|
| [x]  | SetForegroundColor(color: Integer)          | Set foreground color (0-15)        |
| [x]  | SetBackgroundColor(color: Integer)          | Set background color (0-15)        |
| [x]  | SetColor(foreground, background: Integer)   | Set both foreground and background |

**Standard Colors (0-7):**
- 0: Black
- 1: Red
- 2: Green
- 3: Yellow
- 4: Blue
- 5: Magenta
- 6: Cyan
- 7: White

**Bright Colors (8-15):**
- 8: Bright Black (Gray)
- 9: Bright Red
- 10: Bright Green
- 11: Bright Yellow
- 12: Bright Blue
- 13: Bright Magenta
- 14: Bright Cyan
- 15: Bright White

## Escape Code Reference

### VT52 Compatable Mode

| Done | Escape Sequence | Description                            |
|------|-----------------|----------------------------------------|
| [ ]  | ESC A           | Cursor up                              |
| [ ]  | ESC B           | Cursor down                            |
| [ ]  | ESC C           | Cursor right                           |
| [ ]  | ESC D           | Cursor left                            |
| [ ]  | ESC F           | Special graphics character set         |
| [ ]  | ESC G           | Select ASCII character set             |
| [ ]  | ESC H           | Cursor to home                         |
| [ ]  | ESC I           | Reverse line feed                      |
| [ ]  | ESC J           | Erase to end of screen                 |
| [ ]  | ESC K           | Erase to end of line                   |
| [ ]  | ESC Ylc         | Direct cursor address (See note 1)     |
| [ ]  | ESC Z           | Identify (See note 2)                  |
| [ ]  | ESC =           | Enter alternate keypad mode            |
| [ ]  | ESC >           | Exit alternate keypad mode             |
| [ ]  | ESC 1           | Graphics processor on (See note 3)     |
| [ ]  | ESC 2           | Graphics processor off (See note 3)    |
| [ ]  | ESC <           | Enter ANSI mode                        |

Note 1:  Line and column numbers for direct cursor addresses are single
         character codes whose values are the desired number plus 37 octal.
         Line and column numbers start at 1.

Note 2:  Response to ESC Z is ESC/Z.

Note 3:  Ignored if no graphics processor stored in the VT100

### ANSI Compatable Mode

| Done | Escape Sequence  | Description                                                    |
|------|------------------|----------------------------------------------------------------|
| [x]  | ESC [ Pn A       | Cursor up Pn lines                                             |
| [x]  | ESC [ Pn B       | Cursor down Pn lines                                           |
| [x]  | ESC [ Pn C       | Cursor forward Pn characters (right)                           |
| [x]  | ESC [ Pn D       | Cursor backward Pn characters (left)                           |
| [x]  | ESC [ Pl;PcH     | Direct cursor addressing, where Pl is line#, Pc is column#     |
| [x]  | ESC [ Pl;Pcf     | Same as above                                                  |
| [x]  | ESC D            | Index                                                          |
| [x]  | ESC M            | Reverse index                                                  |
| [x]  | ESC 7            | Save cursor and attributes                                     |
| [x]  | ESC 8            | Restore cursor and attributes                                  |
| [x]  | ESC #3           | Change this line to double-height top half                     |
| [x]  | ESC #4           | Change this line to double-height bottom half                  |
| [x]  | ESC #5           | Change this line to single-width single-height                 |
| [x]  | ESC #6           | Change this line to double-width single-height                 |
| [x]  | ESC [ Ps..Ps m   | Selective parameters (see below)                               |
| [x]  | ESC [ K          | Erase from cursor to end of line                               |
| [x]  | ESC [ 0K         | Same as above                                                  |
| [x]  | ESC [ 1K         | Erase from beginning of line to cursor                         |
| [x]  | ESC [ 2K         | Erase line containing cursor                                   |
| [x]  | ESC [ J          | Erase from cursor to end of screen                             |
| [x]  | ESC [ 0J         | Same as above                                                  |
| [x]  | ESC [ 2J         | Erase entire screen                                            |
| [ ]  | ESC [ Ps..Ps q   | Programmable LEDs (see below)                                  |

**ESC [ Ps..Ps m - Selective Parameters:**
Multiple parameters are separated by semicolon (073 octal), executed in order:
- 0 or none: All attributes off
- 1: Bold on
- 4: Underscore on
- 5: Blink on
- 7: Reverse video on
- Any other parameters are ignored

**ESC [ Ps..Ps q - Programmable LEDs:**
Selective parameters separated by semicolons (073 octal), executed in order:
- 0 or None: All LEDs off
- 1: L1 On
- 2: L2 On
- 3: L3 On
- 4: L4 On
- Any other parameter values are ignored

**Character Set Selection:**

The following select alternative character sets. The G1 set is invoked for use by the control code SO (Shift Out), the G0 set is invoked by the control code SI (Shift In).

| Done | G0 Designator | G1 Designator | Character Set                      |
|------|---------------|---------------|------------------------------------|
| [ ]  | ESC ( A       | ESC ) A       | United Kingdom (UK)                |
| [ ]  | ESC ( B       | ESC ) B       | United States (USASCII)            |
| [ ]  | ESC ( 0       | ESC ) 0       | Special graphics/line drawing set  |
| [ ]  | ESC ( 1       | ESC ) 1       | Alternative character ROM          |
| [ ]  | ESC ( 2       | ESC ) 2       | Alternative graphic ROM            |

**Scrolling and Tabs:**

| Done | Escape Sequence | Description                                                           |
|------|-----------------|-----------------------------------------------------------------------|
| [ ]  | ESC K Pt;Pb r   | Set top scrolling window (Pt) and bottom scrolling window (Pb)        |
| [ ]  | ESC H           | Set tab at current column                                             |
| [ ]  | ESC [ g         | Clear tab at current column                                           |
| [ ]  | ESC [ 0g        | Same as above                                                         |
| [ ]  | ESC [ 3g        | Clear all tabs                                                        |

### Modes

| Done | Mode Name     | Set Mode    | Set Sequence | Reset Mode  | Reset Sequence |
|------|---------------|-------------|--------------|-------------|----------------|
| [ ]  | Line feed/new | New line    | ESC [20h     | Line feed   | ESC [20l       |
| [ ]  | Cursor key    | Application | ESC [?1h     | Cursor      | ESC [?1l       |
| [ ]  | ANSI/VT52     | ANSI        | n/a          | VT52        | ESC [?2l       |
| [ ]  | Column mode   | 132 col     | ESC [?3h     | 80 col      | ESC [?3l       |
| [ ]  | Scrolling     | Smooth      | ESC [?4h     | Jump        | ESC [?4l       |
| [ ]  | Screen mode   | Reverse     | ESC [?5h     | Normal      | ESC [?5l       |
| [ ]  | Origin mode   | Relative    | ESC [?6h     | Absolute    | ESC [?6l       |
| [ ]  | Wraparound    | On          | ESC [?7h     | Off         | ESC [?7l       |
| [ ]  | Autorepeat    | On          | ESC [?8h     | Off         | ESC [?8l       |
| [ ]  | Interface     | On          | ESC [?9h     | Off         | ESC [?9l       |

### Reports

| Done | Escape Sequence | Description                                               |
|------|-----------------|-----------------------------------------------------------|
| [ ]  | ESC [ 6n        | Cursor position report                                    |
| [ ]  | ESC [ Pl;PcR    | Response to cursor position (Pl=line#; Pc=column#)        |
| [ ]  | ESC [ 5n        | Status report                                             |
| [ ]  | ESC [ c         | Response: terminal Ok                                     |
| [ ]  | ESC [ 0c        | Response: terminal not Ok                                 |
| [ ]  | ESC [ c         | What are you?                                             |
| [ ]  | ESC [ 0c        | Same as above                                             |
| [ ]  | ESC [?1;Ps c    | Response with option (see below)                          |
| [ ]  | ESC c           | Causes power-up reset routine to be executed              |
| [ ]  | ESC #8          | Fill screen with "E"                                      |
| [ ]  | ESC [ 2;Ps y    | Invoke Test(s) (see below)                                |

**ESC [?1;Ps c - Option Response Values:**
- 0: Base VT100, no options
- 1: Preprocessor option (STP)
- 2: Advanced video option (AVO)
- 3: AVO and STP
- 4: Graphics processor option (GO)
- 5: GO and STP
- 6: GO and AVO
- 7: GO, STP, and AVO

**ESC [ 2;Ps y - Test Values:**
Ps is a decimal computed by adding the numbers of the desired tests:
- 1: Power up test
- 2: Data loop back
- 4: EIA modem control signal test
- 8: Repeat test(s) indefinitely

### TERMINAL COMMANDS

| Done | Escape Sequence | Description                      |
|------|-----------------|----------------------------------|
| [ ]  | c               | Reset                            |
| [ ]  | [ ! p           | Soft Reset                       |
| [ ]  | # 8             | Fill Screen with E's             |
| [ ]  | } 1 *           | Fill screen with * test          |
| [ ]  | } 2             | Video attribute test display     |
| [ ]  | } 3             | Character sets display test      |

### KEYBOARD COMMANDS

| Done | Escape Sequence | Description                      |
|------|-----------------|----------------------------------|
| [ ]  | [ 2 h           | Keyboard locked                  |
| [ ]  | [ 2 l           | Keyboard unlocked                |
| [ ]  | [ ? 8 h         | Autorepeat ON                    |
| [ ]  | [ ? 8 l         | Autorepeat OFF                   |
| [ ]  | [ 0 q           | Lights all off on keyboard       |
| [ ]  | [ * q           | Light * on                       |

### PROGRAMMABLE KEY COMMANDS

| Done | Escape Sequence | Description                               |
|------|-----------------|-------------------------------------------|
| [ ]  | ! pk            | Program a programmable key (local)        |
| [ ]  | @ pk            | Program a programmable key (on-line)      |
| [ ]  | % pk            | Transmit programmable key contents        |

### SCREEN FORMAT

| Done | Escape Sequence | Description                                    |
|------|-----------------|------------------------------------------------|
| [ ]  | [ ? 3 h         | 132 Characters on                              |
| [ ]  | [ ? 3 l         | 80 Characters on                               |
| [ ]  | [ ? 4 h         | Smooth Scroll on                               |
| [ ]  | [ ? 4 l         | Jump Scroll on                                 |
| [ ]  | [ *t ; *b r     | Scrolling region selected, line *t to *b       |
| [ ]  | [ ? 5 h         | Inverse video on                               |
| [ ]  | [ ? 5 l         | Normal video off                               |
| [ ]  | [ ? 7 h         | Wraparound ON                                  |
| [ ]  | [ ? 7 l         | Wraparound OFF                                 |
| [ ]  | [ ? 75 h        | Screen display ON                              |
| [ ]  | [ ? 75 l        | Screen display OFF                             |

### CHARACTER SETS AND LABELS

| Done | Escape Sequence | Description                      |
|------|-----------------|----------------------------------|
| [ ]  | ( A             | British                          |
| [ ]  | ( B             | North American ASCII set         |
| [ ]  | ( C             | Finnish                          |
| [ ]  | ( E             | Danish or Norwegian              |
| [ ]  | ( H             | Swedish                          |
| [ ]  | ( K             | German                           |
| [ ]  | ( Q             | French Canadian                  |
| [ ]  | ( R             | Flemish or French/Belgian        |
| [ ]  | ( Y             | Italian                          |
| [ ]  | ( Z             | Spanish                          |
| [ ]  | ( 0             | Line Drawing                     |
| [ ]  | ( 1             | Alternative Character            |
| [ ]  | ( 2             | Alternative Line drawing         |
| [ ]  | ( 4             | Dutch                            |
| [ ]  | ( 5             | Finnish                          |
| [ ]  | ( 6             | Danish or Norwegian              |
| [ ]  | ( 7             | Swedish                          |
| [ ]  | ( =             | Swiss (French or German)         |

**Note:** All `(` may be replaced with `)`

### CHARACTER SIZE

| Done | Escape Sequence | Description                                |
|------|-----------------|--------------------------------------------|
| [ ]  | 1               | Double ht, single width top half chars     |
| [ ]  | 2               | Double ht, single width lower half chars   |
| [ ]  | 3               | Double ht, double width top half chars     |
| [ ]  | 4               | Double ht, double width lower half chars   |
| [ ]  | 5               | Single ht, single width chars              |
| [ ]  | 6               | Single ht, double width chars              |

### ATTRIBUTES AND FIELDS

| Done | Escape Sequence | Description                         |
|------|-----------------|-------------------------------------|
| [ ]  | [ 0 m           | Clear all character attributes      |
| [ ]  | [ 1 m           | Alternate Intensity ON              |
| [ ]  | [ 4 m           | Underline ON                        |
| [ ]  | [ 5 m           | Blink ON                            |
| [ ]  | [ 7 m           | Inverse video ON                    |
| [ ]  | [ 22 m          | Alternate Intensity OFF             |
| [ ]  | [ 24 m          | Underline OFF                       |
| [ ]  | [ 25 m          | Blink OFF                           |
| [ ]  | [ 27 m          | Inverse Video OFF                   |
| [ ]  | [ 0 }           | Protected fields OFF                |
| [ ]  | [ 1 }           | Protected = Alternate Intensity     |
| [ ]  | [ 4 }           | Protected = Underline               |
| [ ]  | [ 5 }           | Protected = Blinking                |
| [ ]  | [ 7 }           | Protected = Inverse                 |
| [ ]  | [ 254 }         | Protected = All attributes OFF      |

### CURSOR COMMANDS

| Done | Escape Sequence | Description                                           |
|------|-----------------|-------------------------------------------------------|
| [x]  | [ ? 25 l        | Cursor OFF                                            |
| [x]  | [ ? 25 h        | Cursor ON                                             |
| [ ]  | [ ? 50 l        | Cursor OFF                                            |
| [ ]  | [ ? 50 h        | Cursor ON                                             |
| [x]  | 7               | Save cursor position and character attributes         |
| [x]  | 8               | Restore cursor position and character attributes      |
| [x]  | D               | Line feed                                             |
| [x]  | E               | Carriage return and line feed                         |
| [x]  | M               | Reverse Line feed                                     |
| [x]  | [ A             | Cursor up one line                                    |
| [x]  | [ B             | Cursor down one line                                  |
| [x]  | [ C             | Cursor right one column                               |
| [x]  | [ D             | Cursor left one column                                |
| [x]  | [ * A           | Cursor up * lines                                     |
| [x]  | [ * B           | Cursor down * lines                                   |
| [x]  | [ * C           | Cursor right * columns                                |
| [x]  | [ * D           | Cursor left * columns                                 |
| [x]  | [ H             | Cursor home                                           |
| [x]  | [ *l ; *c H     | Move cursor to line *l, column *c                     |
| [x]  | [ *l ; *c f     | Move cursor to line *l, column *c                     |
| [ ]  | Y nl nc         | Direct cursor addressing (line/column number)         |
| [ ]  | H               | Tab set at present cursor position                    |
| [ ]  | [ 0 g           | Clear tab at present cursor position                  |
| [ ]  | [ 3 g           | Clear all tabs                                        |

### EDIT COMMANDS

| Done | Escape Sequence | Description                                           |
|------|-----------------|-------------------------------------------------------|
| [x]  | [ 4 h           | Insert mode selected                                  |
| [x]  | [ 4 l           | Replacement mode selected                             |
| [x]  | [ ? 14 h        | Immediate operation of ENTER key                      |
| [x]  | [ ? 14 l        | Deferred operation of ENTER key                       |
| [x]  | [ ? 16 h        | Edit selection immediate                              |
| [x]  | [ ? 16 l        | Edit selection deferred                               |
| [x]  | [ P             | Delete character from cursor position                 |
| [x]  | [ * P           | Delete * chars from cursor right                      |
| [x]  | [ M             | Delete 1 char from cursor position                    |
| [x]  | [ * M           | Delete * lines from cursor line down                  |
| [x]  | [ J             | Erase screen from cursor to end                       |
| [x]  | [ 1 J           | Erase beginning of screen to cursor                   |
| [x]  | [ 2 J           | Erase entire screen but do not move cursor            |
| [x]  | [ K             | Erase line from cursor to end                         |
| [x]  | [ 1 K           | Erase from beginning of line to cursor                |
| [x]  | [ 2 K           | Erase entire line but do not move cursor              |
| [x]  | [ L             | Insert 1 line from cursor position                    |
| [x]  | [ * L           | Insert * lines from cursor position                   |

### COLOR COMMANDS

**Foreground Colors (Standard 0-7):**

| Done | Escape Sequence | Description                    |
|------|-----------------|--------------------------------|
| [x]  | [ 30 m          | Set foreground to Black        |
| [x]  | [ 31 m          | Set foreground to Red          |
| [x]  | [ 32 m          | Set foreground to Green        |
| [x]  | [ 33 m          | Set foreground to Yellow       |
| [x]  | [ 34 m          | Set foreground to Blue         |
| [x]  | [ 35 m          | Set foreground to Magenta      |
| [x]  | [ 36 m          | Set foreground to Cyan         |
| [x]  | [ 37 m          | Set foreground to White        |

**Foreground Colors (Bright 8-15):**

| Done | Escape Sequence | Description                         |
|------|-----------------|-------------------------------------|
| [x]  | [ 90 m          | Set foreground to Bright Black      |
| [x]  | [ 91 m          | Set foreground to Bright Red        |
| [x]  | [ 92 m          | Set foreground to Bright Green      |
| [x]  | [ 93 m          | Set foreground to Bright Yellow     |
| [x]  | [ 94 m          | Set foreground to Bright Blue       |
| [x]  | [ 95 m          | Set foreground to Bright Magenta    |
| [x]  | [ 96 m          | Set foreground to Bright Cyan       |
| [x]  | [ 97 m          | Set foreground to Bright White      |

**Background Colors (Standard 0-7):**

| Done | Escape Sequence | Description                    |
|------|-----------------|--------------------------------|
| [x]  | [ 40 m          | Set background to Black        |
| [x]  | [ 41 m          | Set background to Red          |
| [x]  | [ 42 m          | Set background to Green        |
| [x]  | [ 43 m          | Set background to Yellow       |
| [x]  | [ 44 m          | Set background to Blue         |
| [x]  | [ 45 m          | Set background to Magenta      |
| [x]  | [ 46 m          | Set background to Cyan         |
| [x]  | [ 47 m          | Set background to White        |

**Background Colors (Bright 8-15):**

| Done | Escape Sequence | Description                         |
|------|-----------------|-------------------------------------|
| [x]  | [ 100 m         | Set background to Bright Black      |
| [x]  | [ 101 m         | Set background to Bright Red        |
| [x]  | [ 102 m         | Set background to Bright Green      |
| [x]  | [ 103 m         | Set background to Bright Yellow     |
| [x]  | [ 104 m         | Set background to Bright Blue       |
| [x]  | [ 105 m         | Set background to Bright Magenta    |
| [x]  | [ 106 m         | Set background to Bright Cyan       |
| [x]  | [ 107 m         | Set background to Bright White      |
