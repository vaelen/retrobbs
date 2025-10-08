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
{ Execute locale command and check for UTF-8 }
function DetectUTF8: Boolean;
var
  localeOutput: AnsiString;
  lcVar: String;
begin
  DetectUTF8 := False;
  Exit;

  { Try to execute 'locale' command }
  localeOutput := '';

  { Use RunCommand to execute locale }
  if RunCommand('locale', [], localeOutput) then
  begin
    { Check if LC_CTYPE contains UTF-8 }
    if (Pos('LC_CTYPE', localeOutput) > 0) and (Pos('UTF-8', localeOutput) > 0) then
    begin
      DetectUTF8 := True;
      Exit;
    end;
  end;

  { Fallback: Check environment variables for LC_* containing UTF-8 }
  lcVar := GetEnvironmentVariable('LC_CTYPE');
  if (lcVar <> '') and (Pos('UTF-8', UpperCase(lcVar)) > 0) then
  begin
    DetectUTF8 := True;
    Exit;
  end;

  lcVar := GetEnvironmentVariable('LC_ALL');
  if (lcVar <> '') and (Pos('UTF-8', UpperCase(lcVar)) > 0) then
  begin
    DetectUTF8 := True;
    Exit;
  end;

  lcVar := GetEnvironmentVariable('LANG');
  if (lcVar <> '') and (Pos('UTF-8', UpperCase(lcVar)) > 0) then
  begin
    DetectUTF8 := True;
    Exit;
  end;
end;
{$ELSE}
function DetectUTF8: Boolean;
begin
  DetectUTF8 := False;
end;
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

  {$IFDEF UNIX}
  { Detect UTF-8 support }
  if DetectUTF8 then
    screen.ScreenType := stUTF8
  else
    screen.ScreenType := stVT100;

  { Query terminal size on UNIX systems }
  QueryTerminalSize(output, screen.Width, screen.Height);
  {$ENDIF}

  { Clear screen }
  ClearScreen(output);
end;

end.
