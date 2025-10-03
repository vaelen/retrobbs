# Database (DB) Library Tests

This directory contains test programs for the DB library unit.

## Test Programs

### dbtest.pas
Comprehensive test suite for the DB library. Tests all major functionality:
- Database creation and opening
- Adding, finding, updating, and deleting records
- Multi-page record support
- Persistence (close and reopen)
- Free space reclamation
- Database validation

**Run with:** `make test-db` or `bin/tests/dbtest`

### dbsizetest.pas
Analyzes and displays the size of TDatabase structure and all its components. Useful for understanding memory usage.

**Run with:** `bin/tests/dbsizetest`

**Output:**
- TDatabase total size: **3,256 bytes**
- Breakdown of all component sizes
- Memory usage recommendations

### dbsimple.pas
Simplified test program for basic DB operations. Good for debugging and learning the API.

**Run with:** `bin/tests/dbsimple`

### minimal.pas
Minimal test program to isolate specific functionality. Used during development to debug issues.

**Note:** This test demonstrates the global variable issue - it will crash because it declares TDatabase as a global variable.

## Building Tests

```bash
# Build all DB tests
make test-db

# Build individual tests
make bin/tests/dbtest
make bin/tests/dbsizetest
make bin/tests/dbsimple
make bin/tests/dbminimal

# Clean and rebuild
make clean && make test-db
```

## Important Notes

### TDatabase Variable Declaration

**Always declare TDatabase variables locally in procedures, never globally.**

```pascal
// CORRECT ✓
procedure MyProcedure;
var
  db: TDatabase;
begin
  OpenDatabase('mydb', db);
  // ... use db ...
  CloseDatabase(db);
end;

// INCORRECT ✗ - Will cause crashes!
var
  db: TDatabase;  // Global variable

begin
  OpenDatabase('mydb', db);  // CRASH!
end;
```

### Why Global Variables Crash

The TDatabase structure contains embedded File types (624 bytes each) that have complex initialization requirements. File types should not be embedded in records that get initialized globally. The file handles contain internal state that gets corrupted during global initialization, causing segmentation faults.

### Structure Sizes

- **TDatabase**: 3,256 bytes (3.2 KB)
  - File handles: 624 bytes × 2 = 1,248 bytes
  - TBTree (with embedded File): 904 bytes
  - Headers and metadata: ~1,100 bytes

## Test Data Files

Tests create temporary database files in the current directory:
- `*.dat` - Data files (database pages)
- `*.idx` - Primary index files
- `*.i00` through `*.i14` - Secondary index files (when used)
- `*.jnl` - Journal files (for transactions)

These files are automatically cleaned up at the start of each test run.

## Known Limitations

- Secondary indexes are only partially implemented (placeholder)
- Some optimizations deferred for future work
- Global TDatabase variables are not supported (by design)

## See Also

- [src/db.pas](../../db.pas) - DB library implementation
- [docs/db.md](../../../docs/db.md) - DB design documentation
- [db-tasks.md](../../../db-tasks.md) - Implementation task list
