unit OSUtils;

{
  Operating System Utilities

  Contains utility methods that make it easier to build the rest of the
  system in an OS-agnostic way.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

interface

uses
  BBSTypes, UI;

{ Initialize a TScreen instance in an OS-specific way }
procedure InitializeScreen(var screen: TScreen; var output: Text);

implementation

uses
  SysUtils, Process, ANSI
  {$IFDEF UNIX}
  , BaseUnix
  {$ENDIF}
  ;

{ Query terminal size using ioctl TIOCGWINSZ }
procedure QueryTerminalSize(var output: Text; var width, height: TInt);
{$IFDEF UNIX}
var
  ws: packed record
    ws_row: Word;
    ws_col: Word;
    ws_xpixel: Word;
    ws_ypixel: Word;
  end;
  result: cint;
const
  TIOCGWINSZ = $5413;  { Terminal I/O control get window size }
{$ENDIF}
begin
  { Default values in case detection fails }
  width := 80;
  height := 25;

  {$IFDEF UNIX}
  { Try ioctl TIOCGWINSZ to get terminal size }
  result := FpIOCtl(1, TIOCGWINSZ, @ws);  { File descriptor 1 = stdout }
  if result = 0 then
  begin
    { Success - use the values from the terminal }
    if ws.ws_row > 0 then
      height := ws.ws_row;
    if ws.ws_col > 0 then
      width := ws.ws_col;
  end;
  {$ENDIF}
end;

{ Initialize a TScreen instance in an OS-specific way }
procedure InitializeScreen(var screen: TScreen; var output: Text);
begin
  { Set default values }
  screen.Output := @output;
  screen.Width := 80;
  screen.Height := 25;
  screen.ScreenType := stVT100;
  screen.IsANSI := True;
  screen.IsColor := True;

  { Platform-specific initialization }
  {$IFDEF MSDOS}
  screen.ScreenType := stANSI;
  {$ENDIF}

  QueryTerminalSize(output, screen.Width, screen.Height);

  { Clear screen }
  ClearScreen(output);
end;

end.
