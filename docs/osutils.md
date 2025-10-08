# Operating System Utilities

The `OSUtils` unit contains utility methods that make it easier to build the rest of the system in an OS-agnostic way.

## Screen Initialization

The `InitializeScreen(var Screen, var Output)` procedure initializes a `TScreen` instance in an OS-specific way.

| OS    | Locale | ScreenType | Width x Height    |
| ----- | ------ | ---------- | ----------------- |
| DOS   |        | stANSI     | 80x25             |
| UNIX  | UTF-8  | stUTF8     | ioctl (80x25)     |
| UNIX  | Other  | stVT100    | ioctl (80x25)     |
| Other |        | stVT100    | 80x25             |

**Terminal Size Detection:**

- On UNIX systems, uses `ioctl` with `TIOCGWINSZ` to query terminal dimensions directly
- This is the same method used by `stty size` but more efficient (no external process)
- Falls back to 80x25 if `ioctl` fails or stdout is not connected to a terminal
- Works in real interactive terminals and detects window resize events
