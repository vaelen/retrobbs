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
    SetForegroundColor(Output, i);
    Write('Color ', i, ' ');
  end;
  ResetAttributes(Output);
  WriteLn;
  WriteLn;

  WriteLn('Bright Colors (8-15):');
  for i := 8 to 15 do
  begin
    SetForegroundColor(Output, i);
    Write('Color ', i, ' ');
  end;
  ResetAttributes(Output);
  WriteLn;
  WriteLn;

  WriteLn('Background Colors:');
  for i := 0 to 7 do
  begin
    SetColor(Output, 7, i);
    Write(' BG ', i, ' ');
    ResetAttributes(Output);
    Write(' ');
  end;
  WriteLn;
  WriteLn;

  WriteLn('Combined Colors:');
  SetColor(Output, 1, 7);  { Red on White }
  Write(' Red on White ');
  ResetAttributes(Output);
  Write(' ');
  SetColor(Output, 4, 3);  { Blue on Yellow }
  Write(' Blue on Yellow ');
  ResetAttributes(Output);
  Write(' ');
  SetColor(Output, 2, 0);  { Green on Black }
  Write(' Green on Black ');
  ResetAttributes(Output);
  WriteLn;
  WriteLn;
end;

procedure DemoCursor;
begin
  WriteLn('=== Cursor Control Demo ===');
  WriteLn;

  WriteLn('Hiding cursor for 2 seconds...');
  HideCursor(Output);
  Sleep(2000);
  ShowCursor(Output);
  WriteLn('Cursor restored!');
  WriteLn;

  WriteLn('Cursor movement demo:');
  Write('Start position');
  SaveCursor(Output);
  CursorDown(Output, 2);
  Write('[2 down]');
  CursorUp(Output, 1);
  CursorForward(Output, 15);
  Write('[1 up, 15 right]');
  RestoreCursor(Output);
  CursorForward(Output, 20);
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
  CursorUp(Output, 1);
  CursorForward(Output, 25);
  DeleteChars(Output, 10);
  CursorDown(Output, 1);
  WriteLn;

  WriteLn('Line 1');
  WriteLn('Line 2');
  WriteLn('Line 3 (will be deleted)');
  WriteLn('Line 4');
  CursorUp(Output, 2);
  DeleteLine(Output);
  CursorDown(Output, 2);
  WriteLn;

  WriteLn('Before insert');
  WriteLn('After insert');
  CursorUp(Output, 1);
  InsertLine(Output);
  Write('[Inserted line]');
  CursorDown(Output, 2);
  WriteLn;
end;

procedure DemoAttributes;
begin
  WriteLn('=== Text Attributes Demo ===');
  WriteLn;

  Write('Normal, ');
  SetBold(Output);
  Write('Bold, ');
  ResetAttributes(Output);
  SetUnderscore(Output);
  Write('Underline, ');
  ResetAttributes(Output);
  SetBlink(Output);
  Write('Blink, ');
  ResetAttributes(Output);
  SetReverseVideo(Output);
  Write('Reverse');
  ResetAttributes(Output);
  WriteLn;
  WriteLn;

  SetAttributes(Output, True, True, False, False);
  Write('Bold + Underline');
  ResetAttributes(Output);
  WriteLn;
  WriteLn;
end;

begin
  ClearScreen(Output);
  CursorHome(Output);

  WriteLn('RetroBBS ANSI Terminal Library - Comprehensive Demo');
  WriteLn('====================================================');
  WriteLn;

  DemoColors;
  Pause;

  ClearScreen(Output);
  CursorHome(Output);
  DemoCursor;
  Pause;

  ClearScreen(Output);
  CursorHome(Output);
  DemoEdit;
  Pause;

  ClearScreen(Output);
  CursorHome(Output);
  DemoAttributes;
  Pause;

  ClearScreen(Output);
  CursorHome(Output);
  WriteLn('Demo complete!');
  ResetAttributes(Output);
end.
