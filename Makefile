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
ANSI_TEST_SRC = $(TEST_DIR)/ansitest.pas
HASH_TEST_SRC = $(TEST_DIR)/hashtest.pas
TYPE_TEST_SRC = $(TEST_DIR)/typetest.pas
USER_TEST_SRC = $(TEST_DIR)/usertest.pas
BTREE_TEST_SRC = $(TEST_DIR)/btreetest.pas
DEMO_SRC = $(DEMO_DIR)/ansidemo.pas
ANSI_UNIT = $(SRC_DIR)/ansi.pas
HASH_UNIT = $(SRC_DIR)/hash.pas
BBSTYPES_UNIT = $(SRC_DIR)/bbstypes.pas
USER_UNIT = $(SRC_DIR)/user.pas
BTREE_UNIT = $(SRC_DIR)/btree.pas

# Utility source files
CRC16_SRC = $(UTIL_DIR)/crc16.pas
CRC16X_SRC = $(UTIL_DIR)/crc16x.pas
CRC32_SRC = $(UTIL_DIR)/crc32.pas
SHA1_SRC = $(UTIL_DIR)/sha1.pas

# Output binaries
OUTPUT = $(BIN_DIR)/retrobbs
ANSI_TEST_OUTPUT = $(TEST_BIN_DIR)/ansitest
HASH_TEST_OUTPUT = $(TEST_BIN_DIR)/hashtest
TYPE_TEST_OUTPUT = $(TEST_BIN_DIR)/typetest
USER_TEST_OUTPUT = $(TEST_BIN_DIR)/usertest
BTREE_TEST_OUTPUT = $(TEST_BIN_DIR)/btreetest
DEMO_OUTPUT = $(DEMO_BIN_DIR)/ansidemo

# Utility binaries
CRC16_OUTPUT = $(UTIL_BIN_DIR)/crc16
CRC16X_OUTPUT = $(UTIL_BIN_DIR)/crc16x
CRC32_OUTPUT = $(UTIL_BIN_DIR)/crc32
SHA1_OUTPUT = $(UTIL_BIN_DIR)/sha1

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
$(ANSI_TEST_OUTPUT): $(ANSI_TEST_SRC) $(ANSI_UNIT) | $(TEST_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(ANSI_TEST_OUTPUT) $(ANSI_TEST_SRC)

# Build the Hash test program
$(HASH_TEST_OUTPUT): $(HASH_TEST_SRC) $(HASH_UNIT) | $(TEST_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(HASH_TEST_OUTPUT) $(HASH_TEST_SRC)

# Build the BBSTypes test program
$(TYPE_TEST_OUTPUT): $(TYPE_TEST_SRC) $(BBSTYPES_UNIT) | $(TEST_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(TYPE_TEST_OUTPUT) $(TYPE_TEST_SRC)

# Build the User test program
$(USER_TEST_OUTPUT): $(USER_TEST_SRC) $(USER_UNIT) $(BBSTYPES_UNIT) $(HASH_UNIT) | $(TEST_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(USER_TEST_OUTPUT) $(USER_TEST_SRC)

# Build the BTree test program
$(BTREE_TEST_OUTPUT): $(BTREE_TEST_SRC) $(BTREE_UNIT) $(BBSTYPES_UNIT) $(HASH_UNIT) | $(TEST_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(BTREE_TEST_OUTPUT) $(BTREE_TEST_SRC)

# Build the ANSI demo program
$(DEMO_OUTPUT): $(DEMO_SRC) $(ANSI_UNIT) | $(DEMO_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(DEMO_OUTPUT) $(DEMO_SRC)

# Build CRC16 utility
$(CRC16_OUTPUT): $(CRC16_SRC) $(HASH_UNIT) | $(UTIL_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(CRC16_OUTPUT) $(CRC16_SRC)

# Build CRC16X utility
$(CRC16X_OUTPUT): $(CRC16X_SRC) $(HASH_UNIT) | $(UTIL_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(CRC16X_OUTPUT) $(CRC16X_SRC)

# Build CRC32 utility
$(CRC32_OUTPUT): $(CRC32_SRC) $(HASH_UNIT) | $(UTIL_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(CRC32_OUTPUT) $(CRC32_SRC)

# Build SHA1 utility
$(SHA1_OUTPUT): $(SHA1_SRC) $(HASH_UNIT) | $(UTIL_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(SHA1_OUTPUT) $(SHA1_SRC)

# Build test programs
test: $(ANSI_TEST_OUTPUT) $(HASH_TEST_OUTPUT) $(TYPE_TEST_OUTPUT) $(USER_TEST_OUTPUT) $(BTREE_TEST_OUTPUT)

# Build demo programs
demo: $(DEMO_OUTPUT)

# Build utility programs
utils: $(CRC16_OUTPUT) $(CRC16X_OUTPUT) $(CRC32_OUTPUT) $(SHA1_OUTPUT)

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
