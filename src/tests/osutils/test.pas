program OSUtilsTest;

{
  OSUtils Unit Test

  Tests the OSUtils unit functionality including screen initialization
  and terminal size detection.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  BBSTypes, UI, OSUtils, ANSI;

var
  screen: TScreen;

begin
  WriteLn('OSUtils Unit Test');
  WriteLn('=================');
  WriteLn;

  { Initialize screen using OSUtils }
  InitializeScreen(screen, Output);

  WriteLn('Screen initialized successfully!');
  WriteLn;
  WriteLn('Screen properties:');
  WriteLn('  Width: ', screen.Width);
  WriteLn('  Height: ', screen.Height);
  Write('  ScreenType: ');
  case screen.ScreenType of
    stASCII: WriteLn('ASCII');
    stANSI:  WriteLn('ANSI (CP437)');
    stVT100: WriteLn('VT100');
    stUTF8:  WriteLn('UTF-8');
  end;
  WriteLn('  IsANSI: ', screen.IsANSI);
  WriteLn('  IsColor: ', screen.IsColor);
  WriteLn;

  { Test ANSI output if supported }
  if screen.IsANSI then
  begin
    WriteLn('Testing ANSI color output:');
    SetColor(Output, 10, 0);  { Bright green on black }
    Write('  This text should be green');
    ResetAttributes(Output);
    WriteLn;
  end;

  WriteLn;
  WriteLn('Test completed successfully!');
end.
