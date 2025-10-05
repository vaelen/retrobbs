program ANSITest;

{
  Test program for ANSI terminal display library

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

begin
  WriteLn('ANSI Terminal Display Library Test');
  WriteLn('===================================');
  WriteLn;

  { Test 1: Clear screen and cursor positioning }
  WriteLn('Test 1: Clear screen and cursor positioning');
  Pause;
  ClearScreen(Output);
  CursorHome(Output);
  WriteLn('Screen cleared, cursor at home');
  WriteLn;

  { Test 2: Text attributes }
  WriteLn('Test 2: Text attributes');
  ResetAttributes(Output);
  Write('Normal text, ');
  SetBold(Output);
  Write('Bold text, ');
  ResetAttributes(Output);
  SetUnderscore(Output);
  Write('Underscored text, ');
  ResetAttributes(Output);
  SetBlink(Output);
  Write('Blinking text, ');
  ResetAttributes(Output);
  SetReverseVideo(Output);
  Write('Reverse video');
  ResetAttributes(Output);
  WriteLn;
  WriteLn;

  { Test 3: Combined attributes }
  WriteLn('Test 3: Combined attributes');
  SetAttributes(Output, True, True, False, False);
  Write('Bold and underscored');
  ResetAttributes(Output);
  WriteLn;
  WriteLn;

  { Test 4: Cursor movement }
  WriteLn('Test 4: Cursor movement');
  WriteLn('Moving cursor...');
  SaveCursor(Output);
  CursorDown(Output, 2);
  Write('[2 lines down]');
  CursorUp(Output, 1);
  CursorForward(Output, 20);
  Write('[1 up, 20 right]');
  RestoreCursor(Output);
  WriteLn;
  WriteLn;
  WriteLn;
  WriteLn;

  { Test 5: Line clearing }
  WriteLn('Test 5: Line clearing');
  Write('This line will be partially cleared...');
  CursorBackward(Output, 15);
  ClearToEndOfLine(Output);
  WriteLn;
  WriteLn;

  { Test 6: Cursor positioning }
  WriteLn('Test 6: Absolute cursor positioning');
  CursorPosition(Output, 20, 40);
  Write('[Line 20, Col 40]');
  CursorPosition(Output, 22, 1);
  WriteLn;

  WriteLn('All tests completed!');
  ResetAttributes(Output);
end.
