unit Colors;

{
  Color Palette Library

  Defines color palettes for use with ANSI terminal output.

  Copyright 2025, Andrew C. Young <andrew@vaelen.org>
  MIT License
}

interface

uses BBSTypes;

type
  TColor = record
    FG: TInt;  { Foreground: 0 - 15 }
    BG: TInt;  { Background: 0 - 15 }
  end;

const
  { Dark Backgrounds }
  pWhiteOnBlack: TColor = (FG: 7; BG: 0);
  pGreenOnBlack: TColor = (FG: 10; BG: 0);
  pCyanOnBlack: TColor = (FG: 14; BG: 0);
  pYellowOnBlack: TColor = (FG: 11; BG: 0);
  pWhiteOnBlue: TColor = (FG: 7; BG: 4);
  pBWhiteOnBlue: TColor = (FG: 15; BG: 4);
  pYellowOnBlue: TColor = (FG: 11; BG: 4);
  pWhiteOnGreen: TColor = (FG: 7; BG: 2);
  pBWhiteOnGreen: TColor = (FG: 15; BG: 2);
  pWhiteOnCyan: TColor = (FG: 7; BG: 6);
  pBWhiteOnCyan: TColor = (FG: 15; BG: 6);
  pYellowOnRed: TColor = (FG: 11; BG: 1);
  pCyanOnMagenta: TColor = (FG: 14; BG: 5);
  pBWhiteOnGray: TColor = (FG: 15; BG: 8);
  pGreenOnGray: TColor = (FG: 10; BG: 8);

  DarkBackgrounds: array[0..14] of TColor = (
    (FG: 7; BG: 0),   { pWhiteOnBlack }
    (FG: 10; BG: 0),  { pGreenOnBlack }
    (FG: 14; BG: 0),  { pCyanOnBlack }
    (FG: 11; BG: 0),  { pYellowOnBlack }
    (FG: 7; BG: 4),   { pWhiteOnBlue }
    (FG: 15; BG: 4),  { pBWhiteOnBlue }
    (FG: 11; BG: 4),  { pYellowOnBlue }
    (FG: 7; BG: 2),   { pWhiteOnGreen }
    (FG: 15; BG: 2),  { pBWhiteOnGreen }
    (FG: 7; BG: 6),   { pWhiteOnCyan }
    (FG: 15; BG: 6),  { pBWhiteOnCyan }
    (FG: 11; BG: 1),  { pYellowOnRed }
    (FG: 14; BG: 5),  { pCyanOnMagenta }
    (FG: 15; BG: 8),  { pBWhiteOnGray }
    (FG: 10; BG: 8)   { pGreenOnGray }
  );

  { Light Backgrounds }
  pBlueOnWhite: TColor = (FG: 4; BG: 7);
  pGreenOnWhite: TColor = (FG: 2; BG: 7);
  pRedOnWhite: TColor = (FG: 1; BG: 7);
  pMagentaOnWhite: TColor = (FG: 5; BG: 7);
  pCyanOnWhite: TColor = (FG: 6; BG: 7);
  pBlackOnBWhite: TColor = (FG: 0; BG: 15);
  pBlueOnBWhite: TColor = (FG: 4; BG: 15);
  pRedOnBWhite: TColor = (FG: 1; BG: 15);
  pBlackOnYellow: TColor = (FG: 0; BG: 3);
  pBlueOnYellow: TColor = (FG: 4; BG: 3);
  pBlackOnCyan: TColor = (FG: 0; BG: 6);

  LightBackgrounds: array[0..10] of TColor = (
    (FG: 4; BG: 7),   { pBlueOnWhite }
    (FG: 2; BG: 7),   { pGreenOnWhite }
    (FG: 1; BG: 7),   { pRedOnWhite }
    (FG: 5; BG: 7),   { pMagentaOnWhite }
    (FG: 6; BG: 7),   { pCyanOnWhite }
    (FG: 0; BG: 15),  { pBlackOnBWhite }
    (FG: 4; BG: 15),  { pBlueOnBWhite }
    (FG: 1; BG: 15),  { pRedOnBWhite }
    (FG: 0; BG: 3),   { pBlackOnYellow }
    (FG: 4; BG: 3),   { pBlueOnYellow }
    (FG: 0; BG: 6)    { pBlackOnCyan }
  );

  { Accent Colors }
  pRedOnBlack: TColor = (FG: 9; BG: 0);
  pBlueOnBlack: TColor = (FG: 12; BG: 0);
  pMagentaOnBlack: TColor = (FG: 13; BG: 0);
  pYellowOnCyan: TColor = (FG: 11; BG: 6);
  pCyanOnBlue: TColor = (FG: 14; BG: 4);
  pCyanOnRed: TColor = (FG: 14; BG: 1);

  AccentColors: array[0..5] of TColor = (
    (FG: 9; BG: 0),   { pRedOnBlack }
    (FG: 12; BG: 0),  { pBlueOnBlack }
    (FG: 13; BG: 0),  { pMagentaOnBlack }
    (FG: 11; BG: 6),  { pYellowOnCyan }
    (FG: 14; BG: 4),  { pCyanOnBlue }
    (FG: 14; BG: 1)   { pCyanOnRed }
  );

  { All Color Palettes Combined }
  ColorPalettes: array[0..31] of TColor = (
    { Dark Backgrounds }
    (FG: 7; BG: 0),   { pWhiteOnBlack }
    (FG: 10; BG: 0),  { pGreenOnBlack }
    (FG: 14; BG: 0),  { pCyanOnBlack }
    (FG: 11; BG: 0),  { pYellowOnBlack }
    (FG: 7; BG: 4),   { pWhiteOnBlue }
    (FG: 15; BG: 4),  { pBWhiteOnBlue }
    (FG: 11; BG: 4),  { pYellowOnBlue }
    (FG: 7; BG: 2),   { pWhiteOnGreen }
    (FG: 15; BG: 2),  { pBWhiteOnGreen }
    (FG: 7; BG: 6),   { pWhiteOnCyan }
    (FG: 15; BG: 6),  { pBWhiteOnCyan }
    (FG: 11; BG: 1),  { pYellowOnRed }
    (FG: 14; BG: 5),  { pCyanOnMagenta }
    (FG: 15; BG: 8),  { pBWhiteOnGray }
    (FG: 10; BG: 8),  { pGreenOnGray }
    { Light Backgrounds }
    (FG: 4; BG: 7),   { pBlueOnWhite }
    (FG: 2; BG: 7),   { pGreenOnWhite }
    (FG: 1; BG: 7),   { pRedOnWhite }
    (FG: 5; BG: 7),   { pMagentaOnWhite }
    (FG: 6; BG: 7),   { pCyanOnWhite }
    (FG: 0; BG: 15),  { pBlackOnBWhite }
    (FG: 4; BG: 15),  { pBlueOnBWhite }
    (FG: 1; BG: 15),  { pRedOnBWhite }
    (FG: 0; BG: 3),   { pBlackOnYellow }
    (FG: 4; BG: 3),   { pBlueOnYellow }
    (FG: 0; BG: 6),   { pBlackOnCyan }
    { Accent Colors }
    (FG: 9; BG: 0),   { pRedOnBlack }
    (FG: 12; BG: 0),  { pBlueOnBlack }
    (FG: 13; BG: 0),  { pMagentaOnBlack }
    (FG: 11; BG: 6),  { pYellowOnCyan }
    (FG: 14; BG: 4),  { pCyanOnBlue }
    (FG: 14; BG: 1)   { pCyanOnRed }
  );

implementation

end.
