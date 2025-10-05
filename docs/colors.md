# Color Palette Library

The `Colors` unit defines several useful color palettes.

## Types

The `TColor` type keeps track of a foreground and background color pair.
| Field | Type | Notes              |
| ----- | -----| -------------------|
| FG    | TInt | Foreground: 0 - 15 |
| BG    | TInt | Background: 0 - 15 |

## Constants

The following tables show color palettes that have been defined as constants for easy use.

In addition, the constant `ColorPalettes` is an array of all the colors listed here.

### Dark Backgrounds

The constant array `DarkBackgrounds` contains the following colors:

| Name            | FG | BG | Description                |
| --------------- | -- | -- | -------------------------- |
| pWhiteOnBlack   | 7  | 0  | White on Black             |
| pGreenOnBlack   | 10 | 0  | Bright Green on Black      |
| pCyanOnBlack    | 14 | 0  | Bright Cyan on Black       |
| pYellowOnBlack  | 11 | 0  | Bright Yellow on Black     |
| pWhiteOnBlue    | 7  | 4  | White on Blue              |
| pBWhiteOnBlue   | 15 | 4  | Bright White on Blue       |
| pYellowOnBlue   | 11 | 4  | Bright Yellow on Blue      |
| pWhiteOnGreen   | 7  | 2  | White on Green             |
| pBWhiteOnGreen  | 15 | 2  | Bright White on Green      |
| pWhiteOnCyan    | 7  | 6  | White on Cyan              |
| pBWhiteOnCyan   | 15 | 6  | Bright White on Cyan       |
| pYellowOnRed    | 11 | 1  | Bright Yellow on Red       |
| pCyanOnMagenta  | 14 | 5  | Bright Cyan on Magenta     |
| pBWhiteOnGray   | 15 | 8  | Bright White on Gray       |
| pGreenOnGray    | 10 | 8  | Bright Green on Gray       |

### Light Backgrounds

The constant array `LightBackgrounds` contains the following colors:

| Name            | FG | BG | Description                |
| --------------- | -- | -- | -------------------------- |
| pBlueOnWhite    | 4  | 7  | Blue on White (lt gray)    |
| pGreenOnWhite   | 2  | 7  | Green on White (lt gray)   |
| pRedOnWhite     | 1  | 7  | Red on White (lt gray)     |
| pMagentaOnWhite | 5  | 7  | Magenta on White (lt gray) |
| pCyanOnWhite    | 6  | 7  | Cyan on White              |
| pBlackOnBWhite  | 0  | 15 | Black on Bright White      |
| pBlueOnBWhite   | 4  | 15 | Blue on Bright White       |
| pRedOnBWhite    | 1  | 15 | Red on Bright White        |
| pBlackOnYellow  | 0  | 3  | Black on Yellow            |
| pBlueOnYellow   | 4  | 3  | Blue on Yellow             |
| pBlackOnCyan    | 0  | 6  | Black on Cyan              |
| pBlackOnYellow  | 0  | 3  | Black on Yellow            |
| pBlackOnYellow  | 0  | 3  | Black on Yellow            |

### Accent Colors

The constant array `AccentColors` contains the following colors:

| Name            | FG | BG | Description                |
| --------------- | -- | -- | -------------------------- |
| pRedOnBlack     | 9  | 0  | Bright Red on Black        |
| pBlueOnBlack    | 12 | 0  | Bright Blue on Black       |
| pMagentaOnBlack | 13 | 0  | Bright Magenta on Black    |
| pYellowOnCyan   | 11 | 6  | Bright Yellow on Cyan      |
| pCyanOnBlue     | 14 | 4  | Bright Cyan on Blue        |
| pCyanOnRed      | 14 | 1  | Bright Cyan on Red         |

