# DLSS Enabler v4.0 Hybrid for Linux + AMD

Hybrid installation package combining DLSS Enabler v4.0 with v3.x base runtime files for AMD/Intel GPU support on Linux via Wine/Proton.

## Features

- DLSS Enabler v4.0 experimental tech preview
- Multi-frame generation (3x, 4x modes)
- FSR 3.1 frame generation backend
- Full AMD/Intel GPU support
- Multiple DLL injection methods
- Wine/Proton optimized
- Automatic game detection (Unreal Engine + 11 hardcoded games)
- Steam wrapper mode for one-click installation

## Installation Methods

### Method 1: One-Liner Setup (Recommended for Steam)

Install to `~/dlss/` for Steam wrapper usage:

```bash
curl -fsSL https://raw.githubusercontent.com/xXJSONDeruloXx/dlss-enabler-v4-hybrid/main/setup.sh | bash
```

Then add to Steam launch options:

```bash
# Default (version.dll)
~/dlss/install %command%

# Specific injection method
~/dlss/install --method=winmm %command%
~/dlss/install --method=dxgi %command%

# Per-method wrappers (alternative)
~/dlss/install-winmm %command%
~/dlss/install-dxgi %command%

# Uninstall
~/dlss/uninstall %command%
```

**Features:**
- Automatic game directory detection
- Supports Unreal Engine games
- Hardcoded fixes for 11 common games (Cyberpunk, Witcher, etc.)
- Backups original files automatically
- One-line uninstall with backup restore

### Method 2: Manual Installation (Traditional)

For manual control or non-Steam launchers:

```bash
git clone https://github.com/xXJSONDeruloXx/dlss-enabler-v4-hybrid.git
cd dlss-enabler-v4-hybrid
./install.sh /path/to/game [injection_method]
```

Then add to Steam/Heroic/Lutris launch options:

```bash
WINEDLLOVERRIDES="version=n,b;nvapi64=n,b" %COMMAND%
```

## Injection Methods

| Method | Use Case |
|--------|----------|
| `version` | Most games (default) |
| `winmm` | Cyberpunk 2077, games with existing version.dll |
| `d3d11` | DirectX 11 games |
| `d3d12` | DirectX 12 games |
| `dinput8` | DirectInput games |
| `dxgi` | DirectX Graphics Infrastructure |
| `wininet` | WinINet games |
| `winhttp` | WinHTTP games |
| `dbghelp` | Debug Help Library |

## Supported Games with Hardcoded Fixes

The wrapper scripts automatically handle launcher redirects for:

1. **Cyberpunk 2077** - REDprelauncher → bin/x64/Cyberpunk2077.exe
2. **Witcher 3** - REDprelauncher → bin/x64_dx12/witcher3.exe
3. **Baldur's Gate 3** - LariLauncher → bin/bg3_dx11.exe
4. **HITMAN 3 / World of Assassination** - Launcher → Retail/HITMAN3.exe
5. **SYNCED** - sop_launcher → SYNCED.exe
6. **2K Launcher Games** - LauncherPatcher → game exe
7. **Warhammer 40,000: Darktide** - Launcher → binaries/Darktide.exe
8. **Warhammer: Vermintide 2** - Launcher → binaries_dx12/vermintide2_dx12.exe
9. **Satisfactory** - FactoryGameSteam → Engine/Binaries/Win64/FactoryGameSteam-Win64-Shipping.exe
10. **Final Fantasy XIV** - ffxivboot → game/ffxiv_dx11.exe
11. **Forza Horizon 5** - Auto-detected

Plus automatic **Unreal Engine** game detection for any UE4/UE5 title.

## Files Included

### DLSS Enabler v4.0
- `version.dll` (27MB) - Main loader with OptiScaler and DXGI hooks built-in

### DLSS Enabler v3.x Base Runtime
- `_nvngx.dll` - NvAPI wrapper
- `nvngx-wrapper.dll` - NvAPI wrapper
- `nvapi64-proxy.dll` - NVIDIA API proxy
- `dlssg_to_fsr3_amd_is_better.dll` - FSR3 frame generation backend
- `dlss-finder.bin` - DLSS library finder

### Wrapper Scripts (~/dlss/ installation only)
- `install` - Main wrapper with flag support
- `uninstall` - Uninstaller with backup restore
- `install-{method}` - Per-method wrappers (9 variants)

## Configuration

Optional `nvngx.ini` will be created in game directory:

```ini
[DLSS]
Enabled = true

[DLSSG]
Enabled = true

[Logging]
Enabled = true
```

## Requirements

- Linux system with Wine/Proton
- AMD or Intel GPU
- Game with DLSS support
- Steam or compatible launcher

## Troubleshooting

Logs are created in game directory:
- `dlss-enabler.log`
- `dlssg-to-fsr3.log`
- `nvngx.log`

Check wrapper logs (Steam wrapper mode):
```bash
tail -f /tmp/fgmod-install.log  # If using wrapper
```

## Backup and Restore

All installation methods automatically back up existing game DLLs with `.bak` extension:
- Injection DLL (version.dll, winmm.dll, etc.)
- dxgi.dll (if game ships with one)
- d3d11.dll / d3d12.dll (if present)
- nvapi64.dll / nvapi64-proxy.dll (if present)

To restore original files manually:
```bash
cd /path/to/game
for f in *.bak; do mv "$f" "${f%.bak}"; done
```

## Uninstallation

### Steam Wrapper Mode

Simply change launch options:
```bash
~/dlss/uninstall %command%
```

Run the game once, then remove the launch option.

### Manual Installation

```bash
cd ~/dlss  # or wherever you cloned
./uninstall.sh /path/to/game [injection_method]
```

This removes all DLSS Enabler files and restores backups automatically.

### Complete Removal (Wrapper Mode)

```bash
rm -rf ~/dlss
```

Then restore backups manually in each game directory.

## Technical Details

DLSS Enabler v4.0 is an experimental tech preview that:
- Embeds OptiScaler for upscaling
- Provides multi-frame generation beyond standard 2x
- Includes context-aware artifact prevention
- Supports runtime upscaler switching

For AMD/Intel GPUs, v4.0 requires v3.x runtime files to provide NvAPI emulation and GPU spoofing.

### Architecture

```
Game Launch → Wrapper Script
    ↓
Detect game directory (args, env vars, UE detection, hardcoded fixes)
    ↓
Copy DLLs to game directory
    ↓
Backup existing DLLs (.bak)
    ↓
Rename version.dll → injection_method.dll
    ↓
Set WINEDLLOVERRIDES
    ↓
Launch game
```

## Comparison: Wrapper vs Manual

| Feature | Wrapper Mode | Manual Mode |
|---------|-------------|-------------|
| Installation | One-liner curl | Git clone |
| Per-game setup | Steam launch option | Run script per game |
| Game detection | Automatic | Manual path |
| Launcher fixes | Built-in (11 games) | Manual |
| UE game detection | Automatic | Manual |
| Uninstall | One launch | Run uninstall.sh |
| Cross-launcher | Steam-focused | Universal |

## License

This is a redistribution package. Original components:
- DLSS Enabler by artur07305: https://github.com/artur-graniszewski/DLSS-Enabler
- OptiScaler: Embedded in v4.0
- Nukem's DLSS-G to FSR3 mod: https://github.com/Nukem9/dlssg-to-fsr3

## Disclaimer

DLSS Enabler v4.0 is experimental and not recommended for production gaming. Use at your own risk.

For stable alternative, use OptiScaler v0.9.0 standalone.

## Credits

Inspired by [Decky-Framegen](https://github.com/xXJSONDeruloXx/Decky-Framegen) and [fgmod](https://github.com/FakeMichau/fgmod).
