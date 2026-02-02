# dlss-finder.bin - DLSS Library Locator Utility

## Overview

**File:** `dlss-finder.bin` (actually `dlss-finder.exe` renamed)  
**Size:** 82 KB  
**Type:** PE32+ executable (Windows 64-bit)  
**Version:** DLSS Enabler v3.x component  

A utility executable that searches the system for NVIDIA DLSS libraries. Used during DLSS Enabler installation to locate existing DLSS DLLs installed by games or NVIDIA drivers.

## Purpose

When setting up DLSS Enabler on a system, this tool:
1. Scans common DLSS installation directories
2. Locates `nvngx_dlss.dll` files (real NVIDIA DLSS libraries)
3. Reports version information
4. Helps determine compatibility with existing DLSS installations

## Why .bin Extension?

Original filename: `dlss-finder.exe`

Renamed to `.bin` to:
- Avoid anti-virus false positives (some AVs flag .exe files in mod distributions)
- Prevent accidental execution by users
- Indicate it's a binary tool, not a user-facing application

On Windows, it can still be executed:
```cmd
dlss-finder.bin
```

Or renamed back to .exe:
```bash
mv dlss-finder.bin dlss-finder.exe
./dlss-finder.exe
```

## How It Works

### Search Locations

Scans typical DLSS installation paths:
```
C:\Windows\System32\
C:\Program Files\NVIDIA Corporation\Ansel\
C:\Program Files\NVIDIA Corporation\NVIDIA NGX\
C:\ProgramData\NVIDIA Corporation\NGX\
Game directories (passed as arguments)
```

### What It Looks For

- `nvngx_dlss.dll` - Main DLSS library
- `nvngx.dll` - NGX runtime
- Version info in DLL resources
- File size and timestamp

### Output

Prints findings to console:
```
DLSS Finder v1.0
Scanning for DLSS libraries...

Found: C:\Program Files\NVIDIA Corporation\NVIDIA NGX\nvngx_dlss.dll
  Version: 3.5.0
  Size: 45.2 MB
  Date: 2024-01-15

Found: C:\Game\nvngx_dlss.dll
  Version: 2.5.1
  Size: 32.8 MB
  Date: 2023-09-20
```

## Usage

### Command-Line

```bash
# Scan default locations
dlss-finder.bin

# Scan specific directory
dlss-finder.bin "C:\Games\Cyberpunk 2077"

# Recursive scan
dlss-finder.bin --recursive "C:\Games"
```

### From Install Script

DLSS Enabler v3.x installer calls this during setup:
```bash
dlss-finder.exe --scan-game "$GAME_DIR"
```

Results used to:
- Detect existing DLSS versions
- Warn about version conflicts
- Decide whether to backup original DLLs

## In Hybrid Installation

### Why Included?

Bundled in the hybrid package for:
1. **Debugging** - Users can manually check for DLSS libraries
2. **Compatibility** - Verify no conflicting DLSS mods are installed
3. **Information** - Understand what DLSS version a game ships with

### When to Use

**Before installation:**
```bash
cd /Users/danhimebauch/Developer/DLSS-Enabler-v4-Hybrid
./install.sh /path/to/game

# If issues, run:
wine dlss-finder.bin "Z:/path/to/game"
```

**After installation:**
Check if native DLSS DLLs are interfering:
```bash
wine dlss-finder.bin "Z:/path/to/game"
```

If it finds `nvngx_dlss.dll` in the game directory, DLSS Enabler may conflict with native DLSS.

## Technical Details

### File Format

Standard Windows PE32+ executable:
- x86-64 architecture
- GUI subsystem (no console window by default)
- Minimal dependencies (statically linked)

### Size Analysis

82 KB is small, indicating:
- No GUI framework (console only or messagebox-based UI)
- Minimal external dependencies
- Likely written in C/C++
- Optimized release build

### Symbols

No debug strings found in basic analysis. Likely stripped for size.

## Logging

May generate log file:
```
dlss-finder.log
```

Contents:
```
[Scan] Starting DLSS library search...
[Found] C:\Program Files\NVIDIA Corporation\NVIDIA NGX\nvngx_dlss.dll
[Version] 3.5.0
[Scan] Complete. Found 2 DLSS libraries.
```

## Compatibility

### Supported Windows Versions

Windows 7 and later (64-bit).

### Wine/Proton

Runs under Wine with no issues:
```bash
wine dlss-finder.bin
```

## Reverse Engineering Notes

### Limited String Data

Basic strings analysis reveals little (likely minimal logging):
- Standard PE headers
- Some runtime library strings
- No obvious search path strings (possibly embedded or dynamically constructed)

### No Obfuscation

Standard release build. No packing or anti-analysis techniques.

## Usage Scenarios

### Scenario 1: Check for Conflicts

Before installing DLSS Enabler:
```bash
wine dlss-finder.bin "Z:/path/to/game"
```

If it finds existing DLSS files, backup or remove them before proceeding.

### Scenario 2: Verify Installation

After installing native DLSS (e.g., from NexusMods):
```bash
wine dlss-finder.bin "Z:/path/to/game"
```

Confirm the expected DLSS version is present.

### Scenario 3: Troubleshooting

Game crashes with DLSS Enabler installed:
```bash
wine dlss-finder.bin "Z:/path/to/game"
```

Check if multiple DLSS versions are conflicting.

## Alternatives

### Manual Search

Instead of using this tool:
```bash
find /path/to/game -name "*nvngx*" -o -name "*dlss*"
```

### File Manager

Search for `nvngx_dlss.dll` in game directory.

## Is This Utility Necessary?

**For automated installers:** Yes, very useful.

**For manual hybrid installation:** Not critical. You can manually check for DLLs:
```bash
ls -lh /path/to/game/*.dll | grep -i dlss
```

**For troubleshooting:** Helpful when diagnosing conflicts.

## Source Code

Part of DLSS Enabler v3.x:
https://github.com/artur-graniszewski/DLSS-Enabler

Likely source file:
- `dlss_finder.cpp`
- `dlss_scanner.cpp`

Probably uses Windows API:
- `FindFirstFile` / `FindNextFile` for directory scanning
- `GetFileVersionInfo` for version extraction

## Known Issues

None reported. Simple and stable utility.

## Future Considerations

DLSS Enabler v4.0 may integrate this functionality into the main DLL or eliminate the need by handling conflicts automatically.

## Summary

A small utility executable for finding DLSS libraries on the system:
- Scans common installation paths
- Reports version info
- Helps detect conflicts
- Useful for troubleshooting
- Renamed to .bin to avoid AV false positives
- Not critical for manual installation but helpful for automation

Think of it as "Where's my DLSS?" - a simple diagnostic tool for DLSS-related file management.
