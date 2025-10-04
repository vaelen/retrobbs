# Cross-OS Path utilities

The `Path` unit contains helper methods that make it easier to port the program to different operating systems.

## Constants

- PathSeparator - OS specific path separator (/, \, :)

## Methods

- JoinPath(parent: Str255, child: Str255) : Str255
  Returns the parent + PathSeparator + child. If the total length is more than 255, then an empty string is returned instead.
