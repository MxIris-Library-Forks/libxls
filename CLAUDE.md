# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

libxls is a C library for reading Excel binary OLE format (.xls) files (BIFF8, Excel 97-2003). It also provides `xls2csv`, a CLI tool for converting XLS to CSV. Licensed under BSD 2-clause.

## Build Commands

### Autotools (primary build system)

```bash
# First-time setup from git (generates configure script)
./autogen.sh

# Standard build
./configure && make

# Run tests
make check

# Install
make install
```

Build artifacts: `libxlsreader.la` (shared library), `xls2csv` (CLI binary), `test_libxls` / `test2_libxls` (test programs).

### Swift Package Manager

The SPM target compiles the C sources directly (no copying — uses symlinks). See `Sources/libxls/` for layout.

```bash
swift build
swift test
```

### Fuzz testing (requires Clang 6+ with libFuzzer)

```bash
./configure --enable-fuzz-testing
make fuzz_xls
```

## Architecture

The library has a layered architecture for parsing XLS files:

1. **OLE layer** (`src/ole.c`) — Parses the OLE 2.0 compound document container format (sectors, FAT, directory entries)
2. **BIFF parser** (`src/xls.c`) — Core engine that reads BIFF8 records (BOF, SST, FORMAT, XF, ROW, CELL types, FORMULA, etc.) and builds workbook/worksheet structures
3. **Utilities** (`src/xlstool.c`) — String transcoding via iconv, display helpers, color handling
4. **Endian support** (`src/endian.c`) — Byte-order conversion for cross-platform compatibility (big-endian/little-endian)
5. **Locale** (`src/locale.c`) — Locale management for character conversion

### Public API

The main public header is `include/xls.h`. Key functions:
- `xls_open_file()` / `xls_open_buffer()` — Open from file path or memory buffer
- `xls_parseWorkBook()` / `xls_parseWorkSheet()` — Parse structures
- `xls_close_WB()` / `xls_close_WS()` — Cleanup

All functions return `xls_error_t` for error handling (never calls `exit()`).

### Data structures

Defined in `include/libxls/xlsstruct.h` — BIFF record structs (546 lines). Key types: `xlsWorkBook`, `xlsWorkSheet`, `xlsRow`, `xlsCell`. Cell types include BLANK, NUMBER, LABEL, FORMULA, BOOLERR, RK, MULRK, MULBLANK.

### C++ bindings

`cplusplus/XlsReader.h` and `cplusplus/XlsReader.cpp` provide an OOP wrapper. Built only when C++11 is available (`test_cpp` target).

### Internal data structure

`include/libxls/brdb.c.h` is a BIFF record database — an array of opcode-to-name mappings used for debug printing. `brdb.h` wraps it as a static array initializer (included via `#include` inside `brdb[]` definition). Both files are excluded from the Swift module via `module.modulemap` because `brdb.c.h` contains code fragments that break clang's `-fmodules` processing.

## Key Files

| File | Purpose |
|------|---------|
| `src/xls.c` | Core BIFF record parser (~1800 lines) |
| `src/ole.c` | OLE 2.0 container parser |
| `src/xlstool.c` | String encoding, display utilities |
| `src/xls2csv.c` | CLI tool implementation |
| `include/xls.h` | Public API header |
| `include/libxls/xlsstruct.h` | All BIFF struct definitions |
| `Package.swift` | SPM package manifest (C target) |
| `Sources/libxls/include/module.modulemap` | Custom modulemap — exposes only `xls.h`, excludes internal `brdb.*` headers |
| `Sources/libxls/src/config.h` | Empty stub — all config macros are defined in `Package.swift` cSettings |

## SPM Integration Layout

```
Sources/libxls/
  include/                          (publicHeadersPath)
    module.modulemap                (custom — umbrella header "xls.h", excludes brdb.*)
    xls.h             → ../../include/xls.h              (symlink)
    libxls/
      xlstypes.h      → ../../../include/libxls/...      (symlinks)
      xlsstruct.h
      xlstool.h
      ole.h, endian.h, locale.h
      brdb.h, brdb.c.h             (symlinks — available to C compiler, excluded from module)
  src/
    xls.c             → ../../src/xls.c                  (symlinks)
    ole.c, xlstool.c, endian.c, locale.c
    config.h                        (empty stub file)
```

The `src/` subdirectory is required so that `#include "../include/xls.h"` relative paths in the C sources resolve correctly.

## Testing

- `test/test.c` → `test_libxls` — Primary test (registered in `TESTS`, runs via `make check`)
- `test/test2.c` → `test2_libxls` — Quick demo/test
- Test data: `test/files/test2.xls`
- Fuzz corpus: `fuzz/corpus/` (34 files, integrated with Google OSS-Fuzz)
- Swift tests: `Tests/libxlsTests/libxlsTests.swift`

## Dependencies

- **Required**: libiconv (character set conversion)
- **Build tools**: autoconf, automake, libtool, autoconf-archive
- **Optional**: C++11 compiler (for C++ bindings/tests), Clang 6+ with libFuzzer (for fuzz testing)

## Compiler Flags

The library is built with strict warnings: `-Wall -Wextra -Wstrict-prototypes -Wno-unused-parameter -pedantic-errors`

## Notes

- The `--program-prefix` configure option can rename `xls2csv` to avoid conflicts with catdoc's `xls2csv`
- The library supports both file and buffer-based input for use in environments without filesystem access
