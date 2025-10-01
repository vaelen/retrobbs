program ANSIDemo;

{
  Comprehensive demonstration of ANSI terminal features

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  ANSI, SysUtils;

procedure Pause;
begin
  WriteLn;
  Write('Press ENTER to continue...');
  ReadLn;
end;

procedure DemoColors;
var
  i: Integer;
begin
  WriteLn('=== Color Demo ===');
  WriteLn;

  WriteLn('Standard Colors (0-7):');
  for i := 0 to 7 do
  begin
    SetForegroundColor(i);
    Write('Color ', i, ' ');
  end;
  ResetAttributes;
  WriteLn;
  WriteLn;

  WriteLn('Bright Colors (8-15):');
  for i := 8 to 15 do
  begin
    SetForegroundColor(i);
    Write('Color ', i, ' ');
  end;
  ResetAttributes;
  WriteLn;
  WriteLn;

  WriteLn('Background Colors:');
  for i := 0 to 7 do
  begin
    SetColor(7, i);
    Write(' BG ', i, ' ');
    ResetAttributes;
    Write(' ');
  end;
  WriteLn;
  WriteLn;

  WriteLn('Combined Colors:');
  SetColor(1, 7);  { Red on White }
  Write(' Red on White ');
  ResetAttributes;
  Write(' ');
  SetColor(4, 3);  { Blue on Yellow }
  Write(' Blue on Yellow ');
  ResetAttributes;
  Write(' ');
  SetColor(2, 0);  { Green on Black }
  Write(' Green on Black ');
  ResetAttributes;
  WriteLn;
  WriteLn;
end;

procedure DemoCursor;
begin
  WriteLn('=== Cursor Control Demo ===');
  WriteLn;

  WriteLn('Hiding cursor for 2 seconds...');
  HideCursor;
  Sleep(2000);
  ShowCursor;
  WriteLn('Cursor restored!');
  WriteLn;

  WriteLn('Cursor movement demo:');
  Write('Start position');
  SaveCursor;
  CursorDown(2);
  Write('[2 down]');
  CursorUp(1);
  CursorForward(15);
  Write('[1 up, 15 right]');
  RestoreCursor;
  CursorForward(20);
  Write('[Back to start, 20 right]');
  WriteLn;
  WriteLn;
  WriteLn;
end;

procedure DemoEdit;
begin
  WriteLn('=== Edit Operations Demo ===');
  WriteLn;

  WriteLn('This is a test line with extra text that will be deleted.');
  CursorUp(1);
  CursorForward(25);
  DeleteChars(10);
  CursorDown(1);
  WriteLn;

  WriteLn('Line 1');
  WriteLn('Line 2');
  WriteLn('Line 3 (will be deleted)');
  WriteLn('Line 4');
  CursorUp(2);
  DeleteLine;
  CursorDown(2);
  WriteLn;

  WriteLn('Before insert');
  WriteLn('After insert');
  CursorUp(1);
  InsertLine;
  Write('[Inserted line]');
  CursorDown(2);
  WriteLn;
end;

procedure DemoAttributes;
begin
  WriteLn('=== Text Attributes Demo ===');
  WriteLn;

  Write('Normal, ');
  SetBold;
  Write('Bold, ');
  ResetAttributes;
  SetUnderscore;
  Write('Underline, ');
  ResetAttributes;
  SetBlink;
  Write('Blink, ');
  ResetAttributes;
  SetReverseVideo;
  Write('Reverse');
  ResetAttributes;
  WriteLn;
  WriteLn;

  SetAttributes(True, True, False, False);
  Write('Bold + Underline');
  ResetAttributes;
  WriteLn;
  WriteLn;
end;

begin
  ClearScreen;
  CursorHome;

  WriteLn('RetroBBS ANSI Terminal Library - Comprehensive Demo');
  WriteLn('====================================================');
  WriteLn;

  DemoColors;
  Pause;

  ClearScreen;
  CursorHome;
  DemoCursor;
  Pause;

  ClearScreen;
  CursorHome;
  DemoEdit;
  Pause;

  ClearScreen;
  CursorHome;
  DemoAttributes;
  Pause;

  ClearScreen;
  CursorHome;
  WriteLn('Demo complete!');
  ResetAttributes;
end.
