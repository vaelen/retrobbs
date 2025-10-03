unit ANSI;

{
  ANSI Terminal Display Library

  Provides functions for outputting ANSI escape codes to control terminal
  display, cursor positioning, text attributes, and screen clearing.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

interface

uses 
  BBSTypes;

const
  ESC = #27;  { ASCII Escape character }

{ Cursor Movement Functions }
procedure CursorUp(lines: TInt);
procedure CursorDown(lines: TInt);
procedure CursorForward(chars: TInt);
procedure CursorBackward(chars: TInt);
procedure CursorPosition(line, column: TInt);
procedure CursorHome;

{ Cursor Save/Restore }
procedure SaveCursor;
procedure RestoreCursor;

{ Screen Clearing Functions }
procedure ClearScreen;
procedure ClearToEndOfScreen;
procedure ClearToEndOfLine;
procedure ClearFromBeginningOfLine;
procedure ClearLine;

{ Text Attribute Functions }
procedure ResetAttributes;
procedure SetBold;
procedure SetUnderscore;
procedure SetBlink;
procedure SetReverseVideo;

{ Combined Attribute Function }
procedure SetAttributes(bold, underscore, blink, reverse: Boolean);

{ Line Display Mode Functions }
procedure SetDoubleHeightTop;
procedure SetDoubleHeightBottom;
procedure SetSingleWidthHeight;
procedure SetDoubleWidthHeight;

{ Index Functions }
procedure Index;
procedure ReverseIndex;

{ Cursor Visibility }
procedure ShowCursor;
procedure HideCursor;

{ Cursor Positioning (Additional) }
procedure CarriageReturnLineFeed;

{ Edit Mode Functions }
procedure SetInsertMode;
procedure SetReplacementMode;
procedure SetEnterImmediate;
procedure SetEnterDeferred;
procedure SetEditImmediate;
procedure SetEditDeferred;

{ Edit Functions }
procedure DeleteChar;
procedure DeleteChars(count: TInt);
procedure DeleteLine;
procedure DeleteLines(count: TInt);
procedure InsertLine;
procedure InsertLines(count: TInt);

{ Color Functions }
procedure SetForegroundColor(color: TInt);
procedure SetBackgroundColor(color: TInt);
procedure SetColor(foreground, background: TInt);

implementation

uses
  SysUtils;

{ Cursor Movement Functions }

procedure CursorUp(lines: TInt);
begin
  if lines > 0 then
    Write(ESC, '[', lines, 'A');
end;

procedure CursorDown(lines: TInt);
begin
  if lines > 0 then
    Write(ESC, '[', lines, 'B');
end;

procedure CursorForward(chars: TInt);
begin
  if chars > 0 then
    Write(ESC, '[', chars, 'C');
end;

procedure CursorBackward(chars: TInt);
begin
  if chars > 0 then
    Write(ESC, '[', chars, 'D');
end;

procedure CursorPosition(line, column: TInt);
begin
  Write(ESC, '[', line, ';', column, 'H');
end;

procedure CursorHome;
begin
  Write(ESC, '[H');
end;

{ Cursor Save/Restore }

procedure SaveCursor;
begin
  Write(ESC, '7');
end;

procedure RestoreCursor;
begin
  Write(ESC, '8');
end;

{ Screen Clearing Functions }

procedure ClearScreen;
begin
  Write(ESC, '[2J');
end;

procedure ClearToEndOfScreen;
begin
  Write(ESC, '[J');
end;

procedure ClearToEndOfLine;
begin
  Write(ESC, '[K');
end;

procedure ClearFromBeginningOfLine;
begin
  Write(ESC, '[1K');
end;

procedure ClearLine;
begin
  Write(ESC, '[2K');
end;

{ Text Attribute Functions }

procedure ResetAttributes;
begin
  Write(ESC, '[0m');
end;

procedure SetBold;
begin
  Write(ESC, '[1m');
end;

procedure SetUnderscore;
begin
  Write(ESC, '[4m');
end;

procedure SetBlink;
begin
  Write(ESC, '[5m');
end;

procedure SetReverseVideo;
begin
  Write(ESC, '[7m');
end;

{ Combined Attribute Function }

procedure SetAttributes(bold, underscore, blink, reverse: Boolean);
var
  codes: string;
  needSeparator: Boolean;
begin
  codes := '';
  needSeparator := False;

  if bold then
  begin
    codes := codes + '1';
    needSeparator := True;
  end;

  if underscore then
  begin
    if needSeparator then
      codes := codes + ';';
    codes := codes + '4';
    needSeparator := True;
  end;

  if blink then
  begin
    if needSeparator then
      codes := codes + ';';
    codes := codes + '5';
    needSeparator := True;
  end;

  if reverse then
  begin
    if needSeparator then
      codes := codes + ';';
    codes := codes + '7';
  end;

  if codes <> '' then
    Write(ESC, '[', codes, 'm')
  else
    ResetAttributes;
end;

{ Line Display Mode Functions }

procedure SetDoubleHeightTop;
begin
  Write(ESC, '#3');
end;

procedure SetDoubleHeightBottom;
begin
  Write(ESC, '#4');
end;

procedure SetSingleWidthHeight;
begin
  Write(ESC, '#5');
end;

procedure SetDoubleWidthHeight;
begin
  Write(ESC, '#6');
end;

{ Index Functions }

procedure Index;
begin
  Write(ESC, 'D');
end;

procedure ReverseIndex;
begin
  Write(ESC, 'M');
end;

{ Cursor Visibility }

procedure ShowCursor;
begin
  Write(ESC, '[?25h');
end;

procedure HideCursor;
begin
  Write(ESC, '[?25l');
end;

{ Cursor Positioning (Additional) }

procedure CarriageReturnLineFeed;
begin
  Write(ESC, 'E');
end;

{ Edit Mode Functions }

procedure SetInsertMode;
begin
  Write(ESC, '[4h');
end;

procedure SetReplacementMode;
begin
  Write(ESC, '[4l');
end;

procedure SetEnterImmediate;
begin
  Write(ESC, '[?14h');
end;

procedure SetEnterDeferred;
begin
  Write(ESC, '[?14l');
end;

procedure SetEditImmediate;
begin
  Write(ESC, '[?16h');
end;

procedure SetEditDeferred;
begin
  Write(ESC, '[?16l');
end;

{ Edit Functions }

procedure DeleteChar;
begin
  Write(ESC, '[P');
end;

procedure DeleteChars(count: TInt);
begin
  if count > 0 then
    Write(ESC, '[', count, 'P');
end;

procedure DeleteLine;
begin
  Write(ESC, '[M');
end;

procedure DeleteLines(count: TInt);
begin
  if count > 0 then
    Write(ESC, '[', count, 'M');
end;

procedure InsertLine;
begin
  Write(ESC, '[L');
end;

procedure InsertLines(count: TInt);
begin
  if count > 0 then
    Write(ESC, '[', count, 'L');
end;

{ Color Functions }

procedure SetForegroundColor(color: TInt);
begin
  if (color >= 0) and (color <= 7) then
    Write(ESC, '[', 30 + color, 'm')
  else if (color >= 8) and (color <= 15) then
    Write(ESC, '[', 90 + (color - 8), 'm');
end;

procedure SetBackgroundColor(color: TInt);
begin
  if (color >= 0) and (color <= 7) then
    Write(ESC, '[', 40 + color, 'm')
  else if (color >= 8) and (color <= 15) then
    Write(ESC, '[', 100 + (color - 8), 'm');
end;

procedure SetColor(foreground, background: TInt);
begin
  SetForegroundColor(foreground);
  SetBackgroundColor(background);
end;

end.
