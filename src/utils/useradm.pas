program UserAdm;

{
  User Administration Utility

  Full-screen text-based user management interface for RetroBBS.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

uses
  BBSTypes, User, Table, UI, ANSI, Colors, Lists, Crt, SysUtils, OSUtils;

const
  { Screen layout constants }
  TABLE_TOP = 1;           { Top row of table }
  TABLE_LEFT = 1;          { Left column of table }
  STATUS_HEIGHT = 3;       { Height of status bar (including borders) }

var
  { Screen and display }
  screen: TScreen;
  userTable: TTable;
  tableBox: TBox;
  statusBox: TBox;

  { State }
  running: Boolean;
  totalUsers: TInt;

{ Helper function to format User ID as 6-digit string }
function FormatUserID(id: TUserID): Str63;
var
  s: String;
begin
  Str(id:6, s);
  while Length(s) < 6 do
    s := '0' + s;
  FormatUserID := s;
end;

{ Fetch user data callback for table }
function FetchUserData(startIndex: TInt; maxRows: TInt; var rows: TArrayList): Boolean;
var
  i, count: TInt;
  user: TUser;
  row: PTableRow;
  cell: PTableCell;
  userID: TUserID;
begin
  { Initialize result list }
  InitArrayList(rows, maxRows);

  { Fetch users starting at startIndex }
  count := 0;
  i := startIndex;

  { Iterate through users }
  while (count < maxRows) and (i < totalUsers) do
  begin
    { Get user by index - User IDs start at 1 }
    userID := i + 1;
    if FindUserByID(userID, user) then
    begin
      { Allocate row }
      New(row);
      row^.RecordID := user.ID;
      InitArrayList(row^.Cells, 5);

      { Add ID cell }
      New(cell);
      cell^ := FormatUserID(user.ID);
      AddArrayListItem(row^.Cells, cell);

      { Add Name cell }
      New(cell);
      cell^ := user.Name;
      AddArrayListItem(row^.Cells, cell);

      { Add Full Name cell }
      New(cell);
      cell^ := user.FullName;
      AddArrayListItem(row^.Cells, cell);

      { Add Email cell }
      New(cell);
      cell^ := user.Email;
      AddArrayListItem(row^.Cells, cell);

      { Add Location cell }
      New(cell);
      cell^ := user.Location;
      AddArrayListItem(row^.Cells, cell);

      { Add row to list }
      AddArrayListItem(rows, row);
      Inc(count);
    end;

    Inc(i);
  end;

  FetchUserData := True;
end;

{ Calculate box positions based on terminal size }
procedure CalculateLayout;
var
  tableHeight: TInt;
begin
  { Calculate table box dimensions }
  tableHeight := screen.Height - STATUS_HEIGHT;

  tableBox.Row := TABLE_TOP;
  tableBox.Column := TABLE_LEFT;
  tableBox.Width := screen.Width;
  tableBox.Height := screen.Height;

  { Calculate status bar box dimensions }
  statusBox.Row := tableHeight + 1;
  statusBox.Column := TABLE_LEFT;
  statusBox.Width := screen.Width;
  statusBox.Height := STATUS_HEIGHT;
end;

{ Callback function for status bar content }
function StatusBarContent(row: TInt; var text: Str255; var alignment: TAlignment): Boolean;
var
  hasUsers: Boolean;
begin
  { Only provide content for row 1 }
  if row = 1 then
  begin
    { Check if there are any users }
    hasUsers := (totalUsers > 0);

    { Build command text based on state }
    if hasUsers then
      text := ' Ins-Add  Del-Delete  Enter-View  '#$18'/K-Prev  '#$19'/J-Next  /-Search  Esc/Q-Quit'
    else
      text := ' Ins-Add  Esc/Q-Quit';

    alignment := aLeft;
    StatusBarContent := True;
  end
  else
    StatusBarContent := False;
end;

{ Draw the status bar }
procedure DrawStatusBar;
var
  statusColor: TColor;
begin
  { Create status bar color (white on black) }
  statusColor.FG := 7;  { White }
  statusColor.BG := 0;  { Black }

  { Draw box with content using callback }
  DrawBox(screen, statusBox, btSingle, statusColor, StatusBarContent, nil, nil);
end;

{ Cleanup and free resources }
procedure Cleanup;
begin
  { Free table resources }
  FreeTable(userTable);

  { Close user database }
  CloseUserDatabase;

  { Clear screen }
  ClearScreen(Output);

  { Reset cursor position }
  CursorPosition(Output, 1, 1);
end;

{ Main program }
begin
  { Initialize }
  running := True;

  { Initialize screen }
  OSUtils.InitializeScreen(screen, Output);

  { Calculate layout }
  CalculateLayout;

  { Initialize user database }
  if not InitUserDatabase then
  begin
    WriteLn('Error: Could not initialize user database');
    Halt(1);
  end;

  { Get total user count }
  totalUsers := GetUserCount;

  { Initialize table }
  InitTable(userTable, screen, tableBox);

  { Configure table appearance }
  userTable.BorderType := btSingle;
  userTable.BorderColor.FG := 7;  { White }
  userTable.BorderColor.BG := 0;  { Black }
  userTable.HeaderColor.FG := 0;  { Black }
  userTable.HeaderColor.BG := 6;  { Cyan }
  userTable.RowColor.FG := 7;     { White }
  userTable.RowColor.BG := 0;     { Black }
  userTable.AltRowColor.FG := 0;  { Disabled }
  userTable.AltRowColor.BG := 0;  { Disabled }
  userTable.SelectedColor.FG := 0;  { Black }
  userTable.SelectedColor.BG := 7;  { White }

  { Define table columns with responsive hiding priorities }
  AddTableColumn(userTable, 'ID', 6, 8, aLeft, 0);           { Always show }
  AddTableColumn(userTable, 'Name', 10, 15, aLeft, 0);       { Always show }
  AddTableColumn(userTable, 'Full Name', 15, 0, aLeft, 2);  { Hide 2nd on narrow }
  AddTableColumn(userTable, 'Email', 15, 0, aLeft, 1);      { Hide 3rd on narrow }
  AddTableColumn(userTable, 'Location', 10, 0, aLeft, 3);   { Hide 1st on narrow }

  { Set data source }
  SetTableDataSource(userTable, FetchUserData, totalUsers);

  { Draw table }
  DrawTable(userTable);

  { Draw status bar }
  DrawStatusBar;

  { Main event loop - minimal for Phase 3 testing }
  { Wait for any key press }
  ReadKey;

  { Cleanup }
  Cleanup;
end.
