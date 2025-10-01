# RetroBBS Makefile
# For Linux/UNIX/MacOS using Free Pascal Compiler

# Compiler
FPC = fpc

# Compiler flags
FPCFLAGS = -O2 -Xs -XX -CX

# Directories
SRC_DIR = src
BIN_DIR = bin

# Source file
MAIN_SRC = $(SRC_DIR)/retrobbs.pas

# Output binary
OUTPUT = $(BIN_DIR)/retrobbs

# Default target
all: $(OUTPUT)

# Create bin directory if it doesn't exist
$(BIN_DIR):
	mkdir -p $(BIN_DIR)

# Build the main program
$(OUTPUT): $(MAIN_SRC) | $(BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(OUTPUT) $(MAIN_SRC)

# Clean build artifacts
clean:
	rm -f $(BIN_DIR)/*
	rm -f $(SRC_DIR)/*.o
	rm -f $(SRC_DIR)/*.ppu

# Clean everything including binary
distclean: clean
	rm -rf $(BIN_DIR)

# Run the program
run: $(OUTPUT)
	$(OUTPUT)

.PHONY: all clean distclean run
