unit Path;

{
  Cross-OS Path Utilities

  Provides path manipulation utilities that work across different operating
  systems including UNIX, DOS, and Mac OS 7.

  Each OS uses a different path separator:
  - UNIX/Linux/Mac OS X: /
  - DOS/Windows: \
  - Mac OS 7-9: :
}

interface

uses
  BBSTypes;

const
  {$IFDEF UNIX}
    PathSeparator = '/';
  {$ENDIF}
  {$IFDEF MSDOS}
    PathSeparator = '\';
  {$ENDIF}
  {$IFDEF MACOS}
    PathSeparator = ':';
  {$ENDIF}
  {$IF NOT DEFINED(UNIX) AND NOT DEFINED(MSDOS) AND NOT DEFINED(MACOS)}
    PathSeparator = '/';  { Default to UNIX-style }
  {$ENDIF}

{
  JoinPath - Combines a parent path and child path with the appropriate separator

  Parameters:
    parent - The parent directory path
    child - The child path component to append

  Returns:
    The combined path as parent + PathSeparator + child
    Returns empty string if the result would exceed 255 characters

  Examples:
    JoinPath('home', 'user') -> 'home/user' (on UNIX)
    JoinPath('C:', 'DOS') -> 'C:\DOS' (on DOS)
    JoinPath('Volume', 'Folder') -> 'Volume:Folder' (on Mac OS 7)
}
function JoinPath(parent: Str255; child: Str255): Str255;

implementation

function JoinPath(parent: Str255; child: Str255): Str255;
var
  result: Str255;
  totalLen: Integer;
begin
  { Calculate total length: parent + separator + child }
  totalLen := Length(parent) + 1 + Length(child);

  { Check if result would exceed maximum string length }
  if totalLen > 255 then
  begin
    JoinPath := '';
    Exit;
  end;

  { Handle empty parent case }
  if Length(parent) = 0 then
  begin
    JoinPath := child;
    Exit;
  end;

  { Handle empty child case }
  if Length(child) = 0 then
  begin
    JoinPath := parent;
    Exit;
  end;

  { Combine parent + separator + child }
  result := parent + PathSeparator + child;
  JoinPath := result;
end;

end.
