program UITest;

{
  UI Unit Test

  Tests the basic functionality of the UI unit including:
  - ClearBox
  - DrawBox
  - WriteText
  - WriteHeader
  - WriteFooter
  - Text wrapping
  - OffsetR and OffsetC parameters
}

uses
  UI, ANSI, Colors, BBSTypes;

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
  WriteText(screen, box, color, aLeft, 0, 0, 'Left aligned text');

  { Center aligned }
  box.Row := 7;
  color.FG := 10;  { Bright Green }
  WriteText(screen, box, color, aCenter, 0, 0, 'Center aligned text');

  { Right aligned }
  box.Row := 9;
  color.FG := 11;  { Bright Yellow }
  WriteText(screen, box, color, aRight, 0, 0, 'Right aligned text');

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
  WriteText(screen, box, color, aCenter, 0, 0, 'ASCII box characters');

  { Test 4: WriteHeader and WriteFooter }
  WriteLn;
  WriteLn('Test 4: WriteHeader and WriteFooter');
  screen.ScreenType := stANSI;
  box.Row := 3;
  box.Column := 50;
  box.Height := 10;
  box.Width := 28;
  color.FG := 15;  { White }
  color.BG := 2;   { Green }

  ClearBox(screen, box, color);
  DrawBox(screen, box, btSingle, color);

  { Write header }
  color.FG := 14;  { Yellow }
  WriteHeader(screen, box, color, aCenter, 0, 0, ' Test Box ');

  { Write footer }
  color.FG := 11;  { Bright Cyan }
  WriteFooter(screen, box, color, aCenter, 0, 0, ' Footer ');

  { Write some content in the middle }
  box.Row := 7;
  box.Column := 51;
  box.Width := 26;
  color.FG := 10;  { Bright Green }
  WriteText(screen, box, color, aCenter, 0, 0, 'Content text');

  { Test 5: Text wrapping }
  WriteLn;
  WriteLn('Test 5: Text wrapping with long text');
  box.Row := 14;
  box.Column := 50;
  box.Height := 6;
  box.Width := 28;
  color.FG := 15;  { White }
  color.BG := 5;   { Magenta }

  ClearBox(screen, box, color);
  DrawBox(screen, box, btSingle, color);

  { Write header }
  color.FG := 14;  { Yellow }
  WriteHeader(screen, box, color, aCenter, 0, 0, ' Wrapping ');

  { Write long text that will wrap }
  box.Row := 15;
  box.Column := 51;
  box.Height := 4;
  box.Width := 26;
  color.FG := 11;  { Bright Cyan }
  WriteText(screen, box, color, aLeft, 0, 0, 'This is a long text that will wrap across multiple lines in the box!');

  { Test edge case: long word with no spaces }
  box.Row := 16;
  box.Column := 51;
  box.Height := 1;
  box.Width := 26;
  color.FG := 14;  { Yellow }
  WriteText(screen, box, color, aLeft, 0, 0, 'Supercalifragilisticexpialidocious');

  { Clear screen for next tests }
  ClearScreen(Output);
  CursorPosition(Output, 1, 1);

  { Test 6: OffsetR and OffsetC }
  WriteLn('Test 6: Testing OffsetR and OffsetC parameters');
  WriteLn;

  { Draw a box }
  box.Row := 3;
  box.Column := 5;
  box.Height := 15;
  box.Width := 70;
  color.FG := 15;  { White }
  color.BG := 4;   { Blue }

  ClearBox(screen, box, color);
  DrawBox(screen, box, btSingle, color);

  { Write header }
  color.FG := 14;  { Yellow }
  WriteHeader(screen, box, color, aCenter, 0, 0, ' Offset Testing ');

  { Test various offsets - create a grid of text }
  color.FG := 11;  { Bright Cyan }

  { Row 1: OffsetR=1, OffsetC variations }
  WriteText(screen, box, color, aLeft, 1, 1, 'OffsetR=1, OffsetC=1');
  WriteText(screen, box, color, aLeft, 1, 25, 'OffsetC=25');
  WriteText(screen, box, color, aLeft, 1, 40, 'OffsetC=40');

  { Row 3: OffsetR=3 }
  color.FG := 10;  { Bright Green }
  WriteText(screen, box, color, aLeft, 3, 1, 'OffsetR=3, OffsetC=1');

  { Row 5: OffsetR=5 with center alignment }
  color.FG := 13;  { Bright Magenta }
  WriteText(screen, box, color, aCenter, 5, 0, 'OffsetR=5, Centered, OffsetC=0');
  WriteText(screen, box, color, aCenter, 5, 10, 'Same row, OffsetC=10');

  { Row 7: OffsetR=7 with right alignment }
  color.FG := 12;  { Bright Red }
  WriteText(screen, box, color, aRight, 7, 0, 'Right aligned, OffsetC=0');
  WriteText(screen, box, color, aRight, 7, -10, 'Same row, OffsetC=-10');

  { Row 9: Multiple lines showing offset doesn't affect wrapping }
  color.FG := 14;  { Yellow }
  box.Row := 3;
  box.Column := 5;
  box.Height := 15;
  box.Width := 68;
  WriteText(screen, box, color, aLeft, 9, 1, 'This text starts with OffsetR=9 and OffsetC=1 and will wrap to the next line.');

  { Position cursor below box }
  CursorPosition(Output, 19, 1);
  ResetAttributes(Output);

  WriteLn;
  WriteLn('Test complete! Press Enter to continue...');
  ReadLn;

  { Clear screen for final test }
  ClearScreen(Output);
  CursorPosition(Output, 1, 1);

  { Test 7: Return values }
  WriteLn('Test 7: Testing return values (characters displayed)');
  WriteLn;

  box.Row := 3;
  box.Column := 5;
  box.Height := 10;
  box.Width := 50;
  color.FG := 15;
  color.BG := 4;

  ClearBox(screen, box, color);
  DrawBox(screen, box, btSingle, color);

  color.FG := 14;
  WriteLn('Header returned: ', WriteHeader(screen, box, color, aCenter, 0, 0, ' Return Value Test '));

  color.FG := 11;
  box.Row := 4;
  box.Column := 6;
  box.Width := 48;
  box.Height := 6;
  WriteLn('WriteText returned: ', WriteText(screen, box, color, aLeft, 0, 0, 'This text will wrap and we will see how many characters were displayed.'));

  box.Row := 3;
  color.FG := 13;
  WriteLn('Footer returned: ', WriteFooter(screen, box, color, aCenter, 0, 0, ' End '));

  { Test trailing space counting }
  WriteLn;
  WriteLn('Testing trailing space in word wrapping:');
  box.Row := 10;
  box.Column := 6;
  box.Width := 15;
  box.Height := 3;
  color.FG := 10;
  WriteLn('Text: "This is a test word"');
  WriteLn('Text length: ', Length('This is a test word'));
  WriteLn('Box width: 15');
  WriteLn('Should wrap after "a " on line 1 (position 10)');
  WriteLn('Returned: ', WriteText(screen, box, color, aLeft, 0, 0, 'This is a test word'));
  WriteLn('Expected: 19 (all chars including space after "a")');

  CursorPosition(Output, 20, 1);
  ResetAttributes(Output);

  WriteLn;
  WriteLn('All tests complete! Press Enter to exit...');
  ReadLn;

  { Clear screen and reset }
  ClearScreen(Output);
  CursorHome(Output);
end.
