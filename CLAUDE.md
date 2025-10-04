# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RetroBBS is a BBS (Bulletin Board System) software package targeted at retro computing systems from the 1990s. The project is in early development stage with no source code yet - only documentation and technical standards.

## Core Design Principles

**Critical constraints that must be followed:**

1. **Language**: Written in Pascal for maximum portability across retro platforms
2. **Syntax restrictions**: Use standard Pascal syntax only - **NO Object Pascal syntax** (no classes, no object-oriented features)
3. **Filename convention**: Use 8.3 filename format for DOS compatibility
4. **Data storage**: Text-based data storage formats only (no binary databases)
5. **Architecture**: Single-threaded design (no multi-threading)
6. **Modularity**: Strictly modular design with separate units for each functional area

## Build Targets

- **Primary target**: Linux / UNIX / MacOS 10 - Using the Free Pascal compiler (marked as completed in README)
- **Planned targets**:
  - Mac OS 7+ - Using MacPascal
  - DOS 3.0+ - Using TurboPascal
  - Windows 3.1 - Using TurboPascal

To build on Linux, run `make`.

The code must compile and run on all these platforms, which is why the design constraints above are critical.

## Planned Architecture

The system will be organized into these units/modules:

**Core System Units:**
- ANSI - Terminal handling and ANSI graphics
- OS - Operating system abstraction layer
- Serial - Serial port/modem communication
- Net - TCP/IP networking

**User & Communication:**
- Users - User database management
- Mail - Email/netmail system
- Boards - Discussion boards/forums
- Editor - Message editor

**File Transfer:**
- FileAreas - File area management
- XModem - XModem protocol
- ZModem - ZModem protocol
- Kermit - Kermit protocol

**FidoNet Integration:**
- FidoNet - FidoNet core functionality
- Binkp - Binkp transfer protocol

## Technical Standards Reference

The [docs/](docs/) directory contains critical technical standards that define protocol implementations:

- **FidoNet Technical Standards (FTS)**: Core FidoNet protocols in [docs/ftn/](docs/ftn/)
  - Message formats, packet structures, nodelist specifications
  - Binkp protocol specifications (FTS-1026 through FTS-1030)
  - Control paragraphs, addressing, character sets

- **RFC Standards**: Email/message format specs in [docs/rfc/](docs/rfc/)
  - RFC 822: Email message format
  - RFC 1036: Usenet message format

When implementing FidoNet or messaging features, consult the relevant FTS/FSC/FRL documents in [docs/ftn/index.md](docs/ftn/index.md).

## Project Layout

```
retrobbs/
├── src/              - Source code
│   ├── ansi.pas      - ANSI terminal library unit
│   ├── retrobbs.pas  - Main program
│   ├── demos/        - Demo programs
│   ├── tests/        - Test programs (organized by unit)
│   │   ├── all.pas   - Master test suite (runs all unit tests)
│   │   ├── db/       - DB unit tests
│   │   │   ├── all.pas    - DB test suite
│   │   │   ├── test.pas   - Main DB tests
│   │   │   └── ...        - Other DB tests
│   │   └── ...       - Other unit test directories
│   └── utils/        - Utility programs
├── bin/              - Compiled binaries
│   ├── retrobbs      - Main program binary
│   ├── demos/        - Compiled demo programs
│   ├── tests/        - Compiled test programs (organized by unit)
│   │   ├── all       - Master test suite binary
│   │   ├── db/       - DB unit test binaries
│   │   │   ├── all   - DB test suite binary
│   │   │   └── ...   - Other DB test binaries
│   │   └── ...       - Other unit test binaries
│   └── utils/        - Compiled utility programs
├── tests/            - Test artifacts and data files (organized by unit)
│   ├── db/           - DB test data files
│   └── ...           - Other unit test data
├── docs/             - Documentation
│   ├── ansi.md       - ANSI library documentation
│   ├── ftn/          - FidoNet technical standards
│   └── rfc/          - RFC specifications
├── Makefile          - Build system
├── CLAUDE.md         - Claude Code guidance
└── README.md         - Project overview
```

### Build Commands

- `make` - Build main program → `bin/retrobbs`
- `make demo` - Build demo programs → `bin/demos/*`
- `make test` - Build test programs → `bin/tests/*`
- `make utils` - Build utility programs → `bin/utils/*`
- `make run` - Run main program
- `make run-demo` - Run demo program
- `make run-test` - Run test program
- `make clean` - Remove build artifacts
- `make distclean` - Remove all binaries

## Testing

**Testing is critical to ensure code quality and cross-platform compatibility.**

### Test Organization

- **Unit test sources**: Stored in `src/tests/`, organized by unit
- **Compiled test binaries**: Stored in `bin/tests/`, organized by unit
- **Test artifacts/data files**: Created in `tests/`, organized by unit

### Test Structure

Each unit should have its own test directory structure:

```
src/tests/<unit>/          # Test source files for <unit>
├── all.pas                # Unit test suite (runs all tests for this unit)
├── test.pas               # Main test program
├── <feature>.pas          # Feature-specific tests
└── README.md              # Test documentation

bin/tests/<unit>/          # Compiled test binaries
├── all                    # Unit test suite binary
├── test                   # Main test binary
└── <feature>              # Feature-specific test binaries

tests/<unit>/              # Test data files and artifacts
├── test.dat               # Example data file
└── ...                    # Other test artifacts
```

### Master Test Suite

- **`src/tests/all.pas`**: Master test suite that runs all unit test suites
- **`bin/tests/all`**: Compiled master test suite
- The master suite calls each unit's `all` binary to execute all tests for that unit
- This hierarchical approach keeps test organization manageable
- **Note**: A unit doesn't need an `all.pas` test file if there is only a single test file in the unit

### Naming Conventions

**IMPORTANT**: Test files should NOT include the unit name in their filename since they are already organized in unit-specific directories.

**Correct**:
- `src/tests/db/test.pas` - Main DB tests
- `src/tests/db/size.pas` - DB size analysis test
- `src/tests/db/all.pas` - DB test suite

**Incorrect**:
- `src/tests/db/dbtest.pas` - Redundant "db" prefix
- `src/tests/db/dbsize.pas` - Redundant "db" prefix

### Test Data Files

All test data files and artifacts should be created in `tests/<unit>/`:

**Example**: DB unit test creating a database file
```pascal
// CORRECT - Create in tests/db/
if not CreateDatabase('tests/db/test', 128) then
  WriteLn('Failed to create database');

// INCORRECT - Don't create in current directory
if not CreateDatabase('test', 128) then
  WriteLn('Failed to create database');
```

### Test Suite Pattern

Each unit's `all.pas` should follow this pattern:

```pascal
program AllTests;

{
  <Unit> Test Suite

  Runs all test programs for the <unit> unit.
}

uses
  SysUtils, Process;

function RunTest(testName: String): Boolean;
var
  exitCode: Integer;
begin
  WriteLn('Running ', testName, '...');
  exitCode := ExecuteProcess('bin/tests/<unit>/' + testName, []);
  RunTest := (exitCode = 0);
  if exitCode = 0 then
    WriteLn('  PASSED')
  else
    WriteLn('  FAILED (exit code: ', exitCode, ')');
end;

begin
  WriteLn('===========================================');
  WriteLn('<Unit> Test Suite');
  WriteLn('===========================================');
  WriteLn;

  RunTest('test');
  RunTest('feature1');
  RunTest('feature2');

  WriteLn;
  WriteLn('===========================================');
end.
```

### Running Tests

```bash
# Run all tests (master suite)
make test && bin/tests/all

# Run tests for a specific unit
bin/tests/<unit>/all

# Run individual test
bin/tests/<unit>/test
```

## Development Status

All planned features are currently marked as unchecked/in progress in the README:
- ANSI terminal support with adaptive menu system (ANSI vs ASCII, 40 vs 80 column)
- Multiple connection types (serial/modem/TCP/IP/local console)
- User database with login and access controls
- Personal mail between users
- Shared threaded discussion groups
- Full screen text editor for mail and discussion groups
- File areas with XModem, ZModem, and Kermit support
- FidoNet integration (Netmail, Echomail, Binkp client)
- Message of the Day
- One-liners (leave messages for all other users to see)
- Multi-user chat
- System Operator (Sysop) menu when logged in
- Support for games/doors
- System Operator (Sysop) console interface showing logged-in users, recent users, FidoNet activity, and local login

## Design Features Status

- [x] Written in Pascal for portability
- [ ] Written as a series of self-contained and testable modules
- [ ] Standalone tools for maintaining data files
- [ ] Uses text files for data storage
- [ ] Does not depend on external modules
- [ ] Files use 8.3 filenames for DOS support
- [ ] Single-threaded application
- [ ] Avoids Object Pascal syntax for maximum portability

## License

MIT License - Copyright 2025, Andrew C. Young <andrew@vaelen.org>
