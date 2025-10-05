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
procedure CursorUp(var output: Text; lines: TInt);
procedure CursorDown(var output: Text; lines: TInt);
procedure CursorForward(var output: Text; chars: TInt);
procedure CursorBackward(var output: Text; chars: TInt);
procedure CursorPosition(var output: Text; line, column: TInt);
procedure CursorHome(var output: Text);

{ Cursor Save/Restore }
procedure SaveCursor(var output: Text);
procedure RestoreCursor(var output: Text);

{ Screen Clearing Functions }
procedure ClearScreen(var output: Text);
procedure ClearToEndOfScreen(var output: Text);
procedure ClearToEndOfLine(var output: Text);
procedure ClearFromBeginningOfLine(var output: Text);
procedure ClearLine(var output: Text);

{ Text Attribute Functions }
procedure ResetAttributes(var output: Text);
procedure SetBold(var output: Text);
procedure SetUnderscore(var output: Text);
procedure SetBlink(var output: Text);
procedure SetReverseVideo(var output: Text);

{ Combined Attribute Function }
procedure SetAttributes(var output: Text; bold, underscore, blink, reverse: Boolean);

{ Line Display Mode Functions }
procedure SetDoubleHeightTop(var output: Text);
procedure SetDoubleHeightBottom(var output: Text);
procedure SetSingleWidthHeight(var output: Text);
procedure SetDoubleWidthHeight(var output: Text);

{ Index Functions }
procedure Index(var output: Text);
procedure ReverseIndex(var output: Text);

{ Cursor Visibility }
procedure ShowCursor(var output: Text);
procedure HideCursor(var output: Text);

{ Cursor Positioning (Additional) }
procedure CarriageReturnLineFeed(var output: Text);

{ Edit Mode Functions }
procedure SetInsertMode(var output: Text);
procedure SetReplacementMode(var output: Text);
procedure SetEnterImmediate(var output: Text);
procedure SetEnterDeferred(var output: Text);
procedure SetEditImmediate(var output: Text);
procedure SetEditDeferred(var output: Text);

{ Edit Functions }
procedure DeleteChar(var output: Text);
procedure DeleteChars(var output: Text; count: TInt);
procedure DeleteLine(var output: Text);
procedure DeleteLines(var output: Text; count: TInt);
procedure InsertLine(var output: Text);
procedure InsertLines(var output: Text; count: TInt);

{ Color Functions }
procedure SetForegroundColor(var output: Text; color: TInt);
procedure SetBackgroundColor(var output: Text; color: TInt);
procedure SetColor(var output: Text; foreground, background: TInt);

implementation

uses
  SysUtils;

{ Cursor Movement Functions }

procedure CursorUp(var output: Text; lines: TInt);
begin
  if lines > 0 then
    Write(output, ESC, '[', lines, 'A');
end;

procedure CursorDown(var output: Text; lines: TInt);
begin
  if lines > 0 then
    Write(output, ESC, '[', lines, 'B');
end;

procedure CursorForward(var output: Text; chars: TInt);
begin
  if chars > 0 then
    Write(output, ESC, '[', chars, 'C');
end;

procedure CursorBackward(var output: Text; chars: TInt);
begin
  if chars > 0 then
    Write(output, ESC, '[', chars, 'D');
end;

procedure CursorPosition(var output: Text; line, column: TInt);
begin
  Write(output, ESC, '[', line, ';', column, 'H');
end;

procedure CursorHome(var output: Text);
begin
  Write(output, ESC, '[H');
end;

{ Cursor Save/Restore }

procedure SaveCursor(var output: Text);
begin
  Write(output, ESC, '7');
end;

procedure RestoreCursor(var output: Text);
begin
  Write(output, ESC, '8');
end;

{ Screen Clearing Functions }

procedure ClearScreen(var output: Text);
begin
  Write(output, ESC, '[2J');
end;

procedure ClearToEndOfScreen(var output: Text);
begin
  Write(output, ESC, '[J');
end;

procedure ClearToEndOfLine(var output: Text);
begin
  Write(output, ESC, '[K');
end;

procedure ClearFromBeginningOfLine(var output: Text);
begin
  Write(output, ESC, '[1K');
end;

procedure ClearLine(var output: Text);
begin
  Write(output, ESC, '[2K');
end;

{ Text Attribute Functions }

procedure ResetAttributes(var output: Text);
begin
  Write(output, ESC, '[0m');
end;

procedure SetBold(var output: Text);
begin
  Write(output, ESC, '[1m');
end;

procedure SetUnderscore(var output: Text);
begin
  Write(output, ESC, '[4m');
end;

procedure SetBlink(var output: Text);
begin
  Write(output, ESC, '[5m');
end;

procedure SetReverseVideo(var output: Text);
begin
  Write(output, ESC, '[7m');
end;

{ Combined Attribute Function }

procedure SetAttributes(var output: Text; bold, underscore, blink, reverse: Boolean);
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
    Write(output, ESC, '[', codes, 'm')
  else
    ResetAttributes(output);
end;

{ Line Display Mode Functions }

procedure SetDoubleHeightTop(var output: Text);
begin
  Write(output, ESC, '#3');
end;

procedure SetDoubleHeightBottom(var output: Text);
begin
  Write(output, ESC, '#4');
end;

procedure SetSingleWidthHeight(var output: Text);
begin
  Write(output, ESC, '#5');
end;

procedure SetDoubleWidthHeight(var output: Text);
begin
  Write(output, ESC, '#6');
end;

{ Index Functions }

procedure Index(var output: Text);
begin
  Write(output, ESC, 'D');
end;

procedure ReverseIndex(var output: Text);
begin
  Write(output, ESC, 'M');
end;

{ Cursor Visibility }

procedure ShowCursor(var output: Text);
begin
  Write(output, ESC, '[?25h');
end;

procedure HideCursor(var output: Text);
begin
  Write(output, ESC, '[?25l');
end;

{ Cursor Positioning (Additional) }

procedure CarriageReturnLineFeed(var output: Text);
begin
  Write(output, ESC, 'E');
end;

{ Edit Mode Functions }

procedure SetInsertMode(var output: Text);
begin
  Write(output, ESC, '[4h');
end;

procedure SetReplacementMode(var output: Text);
begin
  Write(output, ESC, '[4l');
end;

procedure SetEnterImmediate(var output: Text);
begin
  Write(output, ESC, '[?14h');
end;

procedure SetEnterDeferred(var output: Text);
begin
  Write(output, ESC, '[?14l');
end;

procedure SetEditImmediate(var output: Text);
begin
  Write(output, ESC, '[?16h');
end;

procedure SetEditDeferred(var output: Text);
begin
  Write(output, ESC, '[?16l');
end;

{ Edit Functions }

procedure DeleteChar(var output: Text);
begin
  Write(output, ESC, '[P');
end;

procedure DeleteChars(var output: Text; count: TInt);
begin
  if count > 0 then
    Write(output, ESC, '[', count, 'P');
end;

procedure DeleteLine(var output: Text);
begin
  Write(output, ESC, '[M');
end;

procedure DeleteLines(var output: Text; count: TInt);
begin
  if count > 0 then
    Write(output, ESC, '[', count, 'M');
end;

procedure InsertLine(var output: Text);
begin
  Write(output, ESC, '[L');
end;

procedure InsertLines(var output: Text; count: TInt);
begin
  if count > 0 then
    Write(output, ESC, '[', count, 'L');
end;

{ Color Functions }

procedure SetForegroundColor(var output: Text; color: TInt);
begin
  if (color >= 0) and (color <= 7) then
    Write(output, ESC, '[', 30 + color, 'm')
  else if (color >= 8) and (color <= 15) then
    Write(output, ESC, '[', 90 + (color - 8), 'm');
end;

procedure SetBackgroundColor(var output: Text; color: TInt);
begin
  if (color >= 0) and (color <= 7) then
    Write(output, ESC, '[', 40 + color, 'm')
  else if (color >= 8) and (color <= 15) then
    Write(output, ESC, '[', 100 + (color - 8), 'm');
end;

procedure SetColor(var output: Text; foreground, background: TInt);
begin
  SetForegroundColor(output, foreground);
  SetBackgroundColor(output, background);
end;

end.
