# RetroBBS Makefile
# For Linux/UNIX/MacOS using Free Pascal Compiler

# Compiler
FPC = fpc

# Compiler flags
FPCFLAGS = -O2 -Xs -XX -CX -Fu$(SRC_DIR)

# Directories
SRC_DIR = src
BIN_DIR = bin
TEST_DIR = $(SRC_DIR)/tests
TEST_BIN_DIR = $(BIN_DIR)/tests
DEMO_DIR = $(SRC_DIR)/demos
DEMO_BIN_DIR = $(BIN_DIR)/demos
UTIL_DIR = $(SRC_DIR)/utils
UTIL_BIN_DIR = $(BIN_DIR)/utils

# Source files
MAIN_SRC = $(SRC_DIR)/retrobbs.pas
TEST_SRC = $(TEST_DIR)/ansitest.pas
DEMO_SRC = $(DEMO_DIR)/ansidemo.pas
ANSI_UNIT = $(SRC_DIR)/ansi.pas

# Output binaries
OUTPUT = $(BIN_DIR)/retrobbs
TEST_OUTPUT = $(TEST_BIN_DIR)/ansitest
DEMO_OUTPUT = $(DEMO_BIN_DIR)/ansidemo

# Default target
all: $(OUTPUT)

# Create bin directory if it doesn't exist
$(BIN_DIR):
	mkdir -p $(BIN_DIR)

# Create bin/tests directory if it doesn't exist
$(TEST_BIN_DIR):
	mkdir -p $(TEST_BIN_DIR)

# Create bin/demos directory if it doesn't exist
$(DEMO_BIN_DIR):
	mkdir -p $(DEMO_BIN_DIR)

# Create bin/utils directory if it doesn't exist
$(UTIL_BIN_DIR):
	mkdir -p $(UTIL_BIN_DIR)

# Build the main program
$(OUTPUT): $(MAIN_SRC) $(ANSI_UNIT) | $(BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(OUTPUT) $(MAIN_SRC)

# Build the ANSI test program
$(TEST_OUTPUT): $(TEST_SRC) $(ANSI_UNIT) | $(TEST_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(TEST_OUTPUT) $(TEST_SRC)

# Build the ANSI demo program
$(DEMO_OUTPUT): $(DEMO_SRC) $(ANSI_UNIT) | $(DEMO_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(DEMO_OUTPUT) $(DEMO_SRC)

# Build test programs
test: $(TEST_OUTPUT)

# Build demo programs
demo: $(DEMO_OUTPUT)

# Build utility programs (empty for now, add targets as utils are created)
utils:
	@echo "No utility programs defined yet"

# Clean build artifacts
clean:
	rm -rf $(TEST_BIN_DIR)
	rm -rf $(DEMO_BIN_DIR)
	rm -rf $(UTIL_BIN_DIR)
	rm -f $(BIN_DIR)/*.o
	rm -f $(BIN_DIR)/*.ppu
	rm -f $(BIN_DIR)/retrobbs
	rm -f $(SRC_DIR)/*.o
	rm -f $(SRC_DIR)/*.ppu
	rm -f $(TEST_DIR)/*.o
	rm -f $(TEST_DIR)/*.ppu
	rm -f $(DEMO_DIR)/*.o
	rm -f $(DEMO_DIR)/*.ppu
	rm -f $(UTIL_DIR)/*.o
	rm -f $(UTIL_DIR)/*.ppu

# Clean everything including binary
distclean: clean
	rm -rf $(BIN_DIR)

# Run the main program
run: $(OUTPUT)
	$(OUTPUT)

# Run the ANSI test program
run-test: $(TEST_OUTPUT)
	$(TEST_OUTPUT)

# Run the ANSI demo program
run-demo: $(DEMO_OUTPUT)
	$(DEMO_OUTPUT)

.PHONY: all test demo utils clean distclean run run-test run-demo
