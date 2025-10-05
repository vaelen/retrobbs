# UI Demo

The program called `uidemo` demonstrates the current state of the UI framework. The demo program source code is locaed at `src/demos/uidemo.pas` and the binary is located at `bin/demos/uidemo`. 

The demo does the following:
1. Prompts the user for screen rows, columns, and type.
2. Sets the color palette to bright white on blue
3. Clears the screen
4. Loads the file `docs/lorem.txt`, placing the first 255 characters of each line into an array for later use.
5. Creates several randomly placed windows using the box drawing APIs.
   Each of those windows has:
   1. A randomly chosen foreground and background color from the `ColorPalettes` list that does not have a blue background.
   2. An opaque background, covering any windows below it.
   3. A border surrounding it.
   4. Text contents chosen randomly from the array of lines that were read in earlier. The text should have a random alignment and must not overwrite the border. (This is achived by creating a temporary "text box" that starts 1 row below and 1 column to the right of the real box and has a height and width that are 2 less than the real box.)
   5. A centered title on the border that is composed of the first 2 words of the chosen text.
   6. A label on the footer that says "X of Y" where X is the number of bytes shown and Y is the total number of bytes in the line that was chosen. The right edge of this label is always 2 characters from the right edge of the box. This is accomplished by creating a temporary box with a width of the string + 2 and a column value of the parent box's column + width - text length - 4.