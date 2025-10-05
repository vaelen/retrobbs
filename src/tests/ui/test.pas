program UITest;

{
  UI Unit Test

  Tests the basic functionality of the UI unit including:
  - ClearBox
  - DrawBox
  - WriteText
}

uses
  UI, ANSI, BBSTypes;

var
  screen: TScreen;
  box: TBox;
  color: TColor;

begin
  WriteLn('UI Unit Test');
  WriteLn('============');
  WriteLn;

  { Initialize screen }
  screen.Output := @Output;
  screen.Height := 24;
  screen.Width := 80;
  screen.IsANSI := True;
  screen.IsColor := True;
  screen.ScreenType := stANSI;

  { Clear the screen }
  ClearScreen(Output);

  { Test 1: Draw a box with ANSI characters }
  WriteLn('Test 1: Drawing box with ANSI characters');
  box.Row := 3;
  box.Column := 5;
  box.Height := 10;
  box.Width := 40;
  color.FG := 15;  { White }
  color.BG := 4;   { Blue }

  ClearBox(screen, box, color);
  DrawBox(screen, box, btSingle, color);

  { Test 2: Write text with different alignments }
  WriteLn;
  WriteLn('Test 2: Writing text with different alignments');

  { Left aligned }
  box.Row := 5;
  box.Column := 6;
  box.Width := 38;
  box.Height := 1;
  color.FG := 14;  { Yellow }
  color.BG := 4;   { Blue }
  WriteText(screen, box, color, aLeft, 'Left aligned text');

  { Center aligned }
  box.Row := 7;
  color.FG := 10;  { Bright Green }
  WriteText(screen, box, color, aCenter, 'Center aligned text');

  { Right aligned }
  box.Row := 9;
  color.FG := 11;  { Bright Yellow }
  WriteText(screen, box, color, aRight, 'Right aligned text');

  { Test 3: Draw a box with ASCII characters }
  WriteLn;
  WriteLn('Test 3: Drawing box with ASCII characters');
  screen.ScreenType := stASCII;
  box.Row := 15;
  box.Column := 5;
  box.Height := 5;
  box.Width := 40;
  color.FG := 15;  { White }
  color.BG := 1;   { Red }

  ClearBox(screen, box, color);
  DrawBox(screen, box, btSingle, color);

  box.Row := 17;
  box.Column := 6;
  box.Width := 38;
  color.FG := 14;  { Yellow }
  WriteText(screen, box, color, aCenter, 'ASCII box characters');

  { Position cursor below boxes }
  CursorPosition(Output, 21, 1);
  ResetAttributes(Output);

  WriteLn;
  WriteLn('Test complete! Press Enter to continue...');
  ReadLn;

  { Clear screen and reset }
  ClearScreen(Output);
  CursorHome(Output);
end.
