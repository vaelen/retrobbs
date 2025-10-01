# Documentation

RetroBBS is built as a set of modular units. Those units are documented in this directory. In addition, RetroBBS makes use of technologies defined by various committes and organizations (such as FidoNet). The documentation for these technologies can also be found in this directory.

## Unit Documentation

Units:
  - [ANSI](ansi.md) - Handles ANSI escape sequences
  - [Hash](hash.md) - CRC and Hashing algorithms
  - Users - Code for managing users and handling login
  - Mail - Handles local mail
  - Boards - Handles local message boards
  - Editor - A full screen text editor
  - FileAreas - Handles file areas
  - XModem - an implementation of the XModem file transfer protocol
  - ZModem - an implementation of the ZModem file transfer protocol
  - Kermit - an implementation of the Kermit file transfer protocol
  - FidoNet - Handles the FidoNet mail system
  - Binkp - Handles the Binkp transport system for FidoNet
  - Serial - Handles serial ports and modems
  - Net - Handles TCP/IP connections
  - OS - Operating System specific functions

## RFCs

  - [RFC-822](rfc/rfc822.txt)     ARPA Internet Text Messages
  - [RFC-1036](rfc/rfc1036.txt)   Standard for Interchange of USENET Messages

## Fidonet Technical Standards

FidoNet is a system for delivering personal mail (Netmail) and discussion groups (Echomail) between BBS systems. It was originally designed to transfer packets between systems over a dialup link, but now the TCP/IP based binkp protocol is used instead.

### Core Technologies

  - [FTS-0001](ftn/fts-0001.txt)  Basic Fidonet Technical Standard
  - [FTS-0004](ftn/fts-0004.txt)  Echomail specification
  - [FTS-0009](ftn/fts-0009.txt)  Message identification and reply linkage

### Control Paragraphs

  - [FTS-4000](ftn/fts-4000.txt)  Control paragraphs
  - [FTS-4001](ftn/fts-4001.txt)  Addressing control paragraphs
  - [FTS-4008](ftn/fts-4008.txt)  Time zone information (TZUTC)
  - [FTS-4009](ftn/fts-4009.txt)  Netmail tracking (Via)
  - [FTS-5003](ftn/fts-5003.txt)  Character set definition in Fidonet messages

### Nodelist Definition

  - [FTS-5000](ftn/fts-5000.txt)  The Distribution Nodelist
  - [FTS-5001](ftn/fts-5001.txt)  Nodelist Flags and Userflags
  - [FTS-5002](ftn/fts-5002.txt)  Pointlist formats
  - [FTS-5004](ftn/fts-5004.txt)  DSN Distributed Nodelist
  - [FTS-5006](ftn/fts-5006.txt)  Tick file format

### Binkp Transfer Protocol

  - [FTS-1026](ftn/fts-1026.txt)  Binkp/1.0 Protocol specification
  - [FTS-1027](ftn/fts-1027.txt)  Binkp/1.0 optional protocol extension CRAM
  - [FTS-1028](ftn/fts-1028.txt)  Binkp protocol extension Non-reliable Mode
  - [FTS-1029](ftn/fts-1029.txt)  Binkp optional protocol extension Dataframe Compression
  - [FTS-1030](ftn/fts-1030.txt)  Binkp optional protocol extension CRC Checksum
  - [FTS-5005](ftn/fts-5005.txt)  Advanced Binkleyterm Style Outbound flow and control

### Binkp Extensions (Not Officially Adopted)

  - [FSP-1024](ftn/fsp-1024.txt)  Binkp/1.1 Protocol specification
  - [FSP-1027](ftn/fsp-1027.txt)  Binkp extensions: No Dupes mode and No Dupes

