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

{$IFDEF UNIX}
{ External C function for TTY detection }
function isatty(fd: cint): cint; cdecl; external 'c' name 'isatty';
{$ENDIF}

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
{$IFDEF UNIX}
var
  isTTY: Boolean;
{$ENDIF}
begin
  { Set default values }
  screen.Output := @output;
  screen.Width := 80;
  screen.Height := 25;
  screen.ScreenType := stASCII;
  screen.IsANSI := False;
  screen.IsColor := False;

  { Platform-specific initialization }
  {$IFDEF MSDOS}
  screen.ScreenType := stANSI;
  screen.IsANSI := True;
  screen.IsColor := True;
  {$ENDIF}

  {$IFDEF UNIX}
  { Check if output is connected to a TTY }
  isTTY := (isatty(1) <> 0);  { File descriptor 1 = stdout }

  if isTTY then
  begin
    { Connected to a terminal - use VT100 }
    screen.ScreenType := stVT100;
    screen.IsANSI := True;
    screen.IsColor := True;
  end
  else
  begin
    { Piped output - use ASCII only }
    screen.ScreenType := stASCII;
    screen.IsANSI := False;
    screen.IsColor := False;
  end;
  {$ENDIF}

  QueryTerminalSize(output, screen.Width, screen.Height);

  { Clear screen only if connected to terminal }
  if screen.IsANSI then
    ClearScreen(output);
end;

end.
