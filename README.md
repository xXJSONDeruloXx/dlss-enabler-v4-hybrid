# DLSS Enabler v4.0 Hybrid for Linux + AMD

Hybrid installation package combining DLSS Enabler v4.0 with v3.x base runtime files for AMD/Intel GPU support on Linux via Wine/Proton.

## Features

- DLSS Enabler v4.0 experimental tech preview
- Multi-frame generation (3x, 4x modes)
- FSR 3.1 frame generation backend
- Full AMD/Intel GPU support
- Multiple DLL injection methods
- Wine/Proton optimized

## Quick Start

```bash
./install.sh /path/to/game [injection_method]
```

Default injection method: `version`

## Injection Methods

- `version` - Most games (default)
- `winmm` - Cyberpunk 2077, games with existing version.dll
- `d3d11` - DirectX 11 games
- `d3d12` - DirectX 12 games
- `dinput8` - DirectInput games
- `dxgi` - DirectX Graphics Infrastructure
- `wininet` - WinINet games
- `winhttp` - WinHTTP games
- `dbghelp` - Debug Help Library

## Steam Launch Options

Add to your game's launch options (script will show exact command):

```bash
WINEDLLOVERRIDES="version=n,b;nvapi64=n,b;dxgi=n,b" %COMMAND%
```

## Files Included

### DLSS Enabler v4.0
- `version.dll` (27MB) - Main loader with OptiScaler built-in

### DLSS Enabler v3.x Base Runtime
- `_nvngx.dll` - NvAPI wrapper
- `nvngx-wrapper.dll` - NvAPI wrapper
- `nvapi64-proxy.dll` - NVIDIA API proxy
- `dxgi.dll` - DirectX adapter proxy
- `dlssg_to_fsr3_amd_is_better.dll` - FSR3 frame generation backend
- `dlss-finder.bin` - DLSS library finder

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

## Technical Details

DLSS Enabler v4.0 is an experimental tech preview that:
- Embeds OptiScaler for upscaling
- Provides multi-frame generation beyond standard 2x
- Includes context-aware artifact prevention
- Supports runtime upscaler switching

For AMD/Intel GPUs, v4.0 requires v3.x runtime files to provide NvAPI emulation and GPU spoofing.

## Backup and Restore

The install script automatically backs up any existing game DLLs with `.bak` extension:
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

### Automatic (Recommended)

```bash
cd /path/to/dlss-enabler-v4-hybrid
./uninstall.sh /path/to/game [injection_method]
```

This removes all DLSS Enabler files and restores backups automatically.

### Manual

```bash
cd /path/to/game
rm -f version.dll _nvngx.dll nvngx-wrapper.dll nvapi64-proxy.dll \
      dxgi.dll dlssg_to_fsr3_amd_is_better.dll dlss-finder.bin \
      *.log nvngx.ini
```

Then restore backups:
```bash
for f in *.bak; do mv "$f" "${f%.bak}"; done
```

## License

This is a redistribution package. Original components:
- DLSS Enabler by artur07305: https://github.com/artur-graniszewski/DLSS-Enabler
- OptiScaler: Embedded in v4.0
- Nukem's DLSS-G to FSR3 mod: https://github.com/Nukem9/dlssg-to-fsr3

## Disclaimer

DLSS Enabler v4.0 is experimental and not recommended for production gaming. Use at your own risk.

For stable alternative, use OptiScaler v0.9.0 standalone.
