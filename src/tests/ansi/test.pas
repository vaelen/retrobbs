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
  ClearScreen;
  CursorHome;
  WriteLn('Screen cleared, cursor at home');
  WriteLn;

  { Test 2: Text attributes }
  WriteLn('Test 2: Text attributes');
  ResetAttributes;
  Write('Normal text, ');
  SetBold;
  Write('Bold text, ');
  ResetAttributes;
  SetUnderscore;
  Write('Underscored text, ');
  ResetAttributes;
  SetBlink;
  Write('Blinking text, ');
  ResetAttributes;
  SetReverseVideo;
  Write('Reverse video');
  ResetAttributes;
  WriteLn;
  WriteLn;

  { Test 3: Combined attributes }
  WriteLn('Test 3: Combined attributes');
  SetAttributes(True, True, False, False);
  Write('Bold and underscored');
  ResetAttributes;
  WriteLn;
  WriteLn;

  { Test 4: Cursor movement }
  WriteLn('Test 4: Cursor movement');
  WriteLn('Moving cursor...');
  SaveCursor;
  CursorDown(2);
  Write('[2 lines down]');
  CursorUp(1);
  CursorForward(20);
  Write('[1 up, 20 right]');
  RestoreCursor;
  WriteLn;
  WriteLn;
  WriteLn;
  WriteLn;

  { Test 5: Line clearing }
  WriteLn('Test 5: Line clearing');
  Write('This line will be partially cleared...');
  CursorBackward(15);
  ClearToEndOfLine;
  WriteLn;
  WriteLn;

  { Test 6: Cursor positioning }
  WriteLn('Test 6: Absolute cursor positioning');
  CursorPosition(20, 40);
  Write('[Line 20, Col 40]');
  CursorPosition(22, 1);
  WriteLn;

  WriteLn('All tests completed!');
  ResetAttributes;
end.
