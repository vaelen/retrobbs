# RetroBBS Makefile
# For Linux/UNIX/MacOS using Free Pascal Compiler

# Compiler
FPC = fpc

# Compiler flags
FPCFLAGS = -MTP -O2 -Xs -XX -CX -Fu$(SRC_DIR)

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
ANSI_TEST_SRC = $(TEST_DIR)/ansi/test.pas
HASH_TEST_SRC = $(TEST_DIR)/hash/test.pas
TYPE_TEST_SRC = $(TEST_DIR)/bbstypes/test.pas
USER_TEST_SRC = $(TEST_DIR)/user/test.pas
BTREE_TEST_SRC = $(TEST_DIR)/btree/test.pas
PATH_TEST_SRC = $(TEST_DIR)/path/test.pas
DB_TEST_SRC = $(TEST_DIR)/db/test.pas
DB_SIMPLE_SRC = $(TEST_DIR)/db/simple.pas
DB_SIZE_SRC = $(TEST_DIR)/db/size.pas
DB_MINIMAL_SRC = $(TEST_DIR)/db/minimal.pas
DB_ALL_SRC = $(TEST_DIR)/db/all.pas
ALL_TESTS_SRC = $(TEST_DIR)/all.pas
DEMO_SRC = $(DEMO_DIR)/ansidemo.pas
ANSI_UNIT = $(SRC_DIR)/ansi.pas
HASH_UNIT = $(SRC_DIR)/hash.pas
BBSTYPES_UNIT = $(SRC_DIR)/bbstypes.pas
USER_UNIT = $(SRC_DIR)/user.pas
BTREE_UNIT = $(SRC_DIR)/btree.pas
PATH_UNIT = $(SRC_DIR)/path.pas
DB_UNIT = $(SRC_DIR)/db.pas

# Utility source files
CRC16_SRC = $(UTIL_DIR)/crc16.pas
CRC16X_SRC = $(UTIL_DIR)/crc16x.pas
CRC32_SRC = $(UTIL_DIR)/crc32.pas
SHA1_SRC = $(UTIL_DIR)/sha1.pas

# Output binaries
OUTPUT = $(BIN_DIR)/retrobbs
ANSI_TEST_BIN_DIR = $(TEST_BIN_DIR)/ansi
HASH_TEST_BIN_DIR = $(TEST_BIN_DIR)/hash
TYPE_TEST_BIN_DIR = $(TEST_BIN_DIR)/bbstypes
USER_TEST_BIN_DIR = $(TEST_BIN_DIR)/user
BTREE_TEST_BIN_DIR = $(TEST_BIN_DIR)/btree
PATH_TEST_BIN_DIR = $(TEST_BIN_DIR)/path
ANSI_TEST_OUTPUT = $(ANSI_TEST_BIN_DIR)/test
HASH_TEST_OUTPUT = $(HASH_TEST_BIN_DIR)/test
TYPE_TEST_OUTPUT = $(TYPE_TEST_BIN_DIR)/test
USER_TEST_OUTPUT = $(USER_TEST_BIN_DIR)/test
BTREE_TEST_OUTPUT = $(BTREE_TEST_BIN_DIR)/test
PATH_TEST_OUTPUT = $(PATH_TEST_BIN_DIR)/test
DB_TEST_BIN_DIR = $(TEST_BIN_DIR)/db
DB_TEST_OUTPUT = $(DB_TEST_BIN_DIR)/test
DB_SIMPLE_OUTPUT = $(DB_TEST_BIN_DIR)/simple
DB_SIZE_OUTPUT = $(DB_TEST_BIN_DIR)/size
DB_MINIMAL_OUTPUT = $(DB_TEST_BIN_DIR)/minimal
DB_ALL_OUTPUT = $(DB_TEST_BIN_DIR)/all
ALL_TESTS_OUTPUT = $(TEST_BIN_DIR)/all
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

# Create test binary directories
$(ANSI_TEST_BIN_DIR):
	mkdir -p $(ANSI_TEST_BIN_DIR)

$(HASH_TEST_BIN_DIR):
	mkdir -p $(HASH_TEST_BIN_DIR)

$(TYPE_TEST_BIN_DIR):
	mkdir -p $(TYPE_TEST_BIN_DIR)

$(USER_TEST_BIN_DIR):
	mkdir -p $(USER_TEST_BIN_DIR)

$(BTREE_TEST_BIN_DIR):
	mkdir -p $(BTREE_TEST_BIN_DIR)

$(PATH_TEST_BIN_DIR):
	mkdir -p $(PATH_TEST_BIN_DIR)

# Build the ANSI test program
$(ANSI_TEST_OUTPUT): $(ANSI_TEST_SRC) $(ANSI_UNIT) | $(ANSI_TEST_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(ANSI_TEST_OUTPUT) $(ANSI_TEST_SRC)

# Build the Hash test program
$(HASH_TEST_OUTPUT): $(HASH_TEST_SRC) $(HASH_UNIT) | $(HASH_TEST_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(HASH_TEST_OUTPUT) $(HASH_TEST_SRC)

# Build the BBSTypes test program
$(TYPE_TEST_OUTPUT): $(TYPE_TEST_SRC) $(BBSTYPES_UNIT) | $(TYPE_TEST_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(TYPE_TEST_OUTPUT) $(TYPE_TEST_SRC)

# Build the User test program
$(USER_TEST_OUTPUT): $(USER_TEST_SRC) $(USER_UNIT) $(BBSTYPES_UNIT) $(HASH_UNIT) | $(USER_TEST_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(USER_TEST_OUTPUT) $(USER_TEST_SRC)

# Build the BTree test program
$(BTREE_TEST_OUTPUT): $(BTREE_TEST_SRC) $(BTREE_UNIT) $(BBSTYPES_UNIT) $(HASH_UNIT) | $(BTREE_TEST_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(BTREE_TEST_OUTPUT) $(BTREE_TEST_SRC)

# Build the Path test program
$(PATH_TEST_OUTPUT): $(PATH_TEST_SRC) $(PATH_UNIT) $(BBSTYPES_UNIT) | $(PATH_TEST_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(PATH_TEST_OUTPUT) $(PATH_TEST_SRC)

# Create DB test binary directory
$(DB_TEST_BIN_DIR):
	mkdir -p $(DB_TEST_BIN_DIR)

# Build the DB test programs
$(DB_TEST_OUTPUT): $(DB_TEST_SRC) $(DB_UNIT) $(BTREE_UNIT) $(BBSTYPES_UNIT) $(HASH_UNIT) | $(DB_TEST_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(DB_TEST_OUTPUT) $(DB_TEST_SRC)

$(DB_SIMPLE_OUTPUT): $(DB_SIMPLE_SRC) $(DB_UNIT) $(BTREE_UNIT) $(BBSTYPES_UNIT) $(HASH_UNIT) | $(DB_TEST_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(DB_SIMPLE_OUTPUT) $(DB_SIMPLE_SRC)

$(DB_SIZE_OUTPUT): $(DB_SIZE_SRC) $(DB_UNIT) $(BTREE_UNIT) $(BBSTYPES_UNIT) | $(DB_TEST_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(DB_SIZE_OUTPUT) $(DB_SIZE_SRC)

$(DB_MINIMAL_OUTPUT): $(DB_MINIMAL_SRC) $(DB_UNIT) $(BTREE_UNIT) $(BBSTYPES_UNIT) $(HASH_UNIT) | $(DB_TEST_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(DB_MINIMAL_OUTPUT) $(DB_MINIMAL_SRC)

$(DB_ALL_OUTPUT): $(DB_ALL_SRC) | $(DB_TEST_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(DB_ALL_OUTPUT) $(DB_ALL_SRC)

# Build the master test suite
$(ALL_TESTS_OUTPUT): $(ALL_TESTS_SRC) | $(TEST_BIN_DIR)
	$(FPC) $(FPCFLAGS) -o$(ALL_TESTS_OUTPUT) $(ALL_TESTS_SRC)

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
test: $(ANSI_TEST_OUTPUT) $(HASH_TEST_OUTPUT) $(TYPE_TEST_OUTPUT) $(USER_TEST_OUTPUT) $(BTREE_TEST_OUTPUT) $(PATH_TEST_OUTPUT) $(DB_TEST_OUTPUT) $(ALL_TESTS_OUTPUT)

# Build all Path test programs
test-path: $(PATH_TEST_OUTPUT)

# Build all DB test programs
test-db: $(DB_TEST_OUTPUT) $(DB_SIMPLE_OUTPUT) $(DB_SIZE_OUTPUT) $(DB_MINIMAL_OUTPUT) $(DB_ALL_OUTPUT)

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

.PHONY: all test test-path test-db demo utils clean distclean run run-test run-demo
