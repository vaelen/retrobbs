# RetroBBS

RetroBBS is a BBS software package targeted at retro computing systems from the 1990s.

## Product Features

- [ ] ANSI terminal support
- [ ] Adaptive menu system (ANSI vs ASCII, 40 vs 80 column)
- [ ] Support for multiple connection types
  - [ ] Serial
  - [ ] Modem
  - [ ] TCP/IP
  - [ ] Local (console)
- [ ] User database / login with access controls
- [ ] Personal mail between users
- [ ] Shared threaded discussion groups
- [ ] Full screen text editor for mail and discussion groups
- [ ] File areas
  - [ ] XModem support
  - [ ] ZModem support
  - [ ] Kermit support
- [ ] FidoNet integration
  - [ ] Netmail (email)
  - [ ] Echomail (discussion groups)
  - [ ] Binkp client (TCP/IP based transfer)
- [ ] Message of the Day
- [ ] One-liners (leave messages for all other users to see)
- [ ] Multi-user chat
- [ ] System Operator (Sysop) menu (when logged in)
- [ ] Support for games / doors
- [ ] System Opeartor (Sysop) console interface showing:
  - [ ] Logged-in users and current activity
  - [ ] Recent users
  - [ ] FidoNet activity
  - [ ] Local Login

## Build Targets

- [x] Linux / UNIX / MacOS 10 - Using the Free Pascal compiler
- [ ] Mac OS 7+ - Using MacPascal
- [ ] DOS 3.0+ - Using TurboPascal
- [ ] Windows 3.1 - Using TurboPascal

To build on Linux, run `make`.

## Design Features

- [x] Written in Pascal for portibility.
- [ ] Written as a series of self-contained and testable modules
- [ ] Standalone tools for maintaining data files
- [ ] Uses text files for data storage
- [ ] Does not depend on external modules
- [ ] Files use 8.3 filenames for DOS support
- [ ] Single-threaded application
- [ ] Avoids Object Pascal syntax for maximum portability

## Project Layout

- docs/    - Documentation
- src/     - Source code
- tests/   - Source code and supporting files for unit tests
- bin/     - Binaries
- plan/    - Planning documents
- tasks/   - Task definition documents
- Makefile - For building on Linux, UNIX, etc.

## Additional Documentation

More detailed documentation can be found in the [docs](docs/index.md) folder.

## License

MIT License

Copyright 2025, Andrew C. Young <andrew@vaelen.org>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.