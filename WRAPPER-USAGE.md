# Wrapper Mode Usage Guide

## Installation

### Quick Setup

```bash
curl -fsSL https://raw.githubusercontent.com/xXJSONDeruloXx/dlss-enabler-v4-hybrid/main/setup.sh | bash
```

This creates `~/dlss/` with all necessary files.

## Steam Launch Options

### Default Injection (version.dll)

```
~/dlss/install %command%
```

### Specific Injection Method

```
~/dlss/install --method=winmm %command%
~/dlss/install --method=dxgi %command%
~/dlss/install --method=d3d11 %command%
```

### Per-Method Wrappers (Alternative)

```
~/dlss/install-winmm %command%
~/dlss/install-dxgi %command%
~/dlss/install-d3d11 %command%
~/dlss/install-d3d12 %command%
~/dlss/install-dinput8 %command%
~/dlss/install-version %command%
~/dlss/install-wininet %command%
~/dlss/install-winhttp %command%
~/dlss/install-dbghelp %command%
```

## Uninstallation

### Temporary Uninstall (Test)

Change Steam launch options to:

```
~/dlss/uninstall %command%
```

Run the game **once**. This will:
1. Remove all DLSS Enabler files
2. Restore .bak backups
3. Launch the game normally

### Permanent Uninstall

After running the uninstall wrapper once, remove the launch option entirely. Game will run with restored original files.

### Complete Removal

```bash
rm -rf ~/dlss
```

Then manually restore any remaining .bak files in game directories.

## Supported Game Launchers

The wrapper automatically redirects these launchers to the actual game executable:

1. **Cyberpunk 2077** - `REDprelauncher.exe` → `bin/x64/Cyberpunk2077.exe`
2. **Witcher 3** - `REDprelauncher.exe` → `bin/x64_dx12/witcher3.exe`
3. **Baldur's Gate 3** - `Launcher/LariLauncher.exe` → `bin/bg3_dx11.exe`
4. **HITMAN 3** - `Launcher.exe` → `Retail/HITMAN3.exe`
5. **SYNCED** - `Launcher/sop_launcher.exe` → `SYNCED.exe`
6. **2K Launcher Games** - `2KLauncher/LauncherPatcher.exe` → game exe
7. **Darktide** - `launcher/Launcher.exe` → `binaries/Darktide.exe`
8. **Vermintide 2** - `launcher/Launcher.exe` → `binaries_dx12/vermintide2_dx12.exe`
9. **Satisfactory** - `FactoryGameSteam.exe` → `Engine/Binaries/Win64/FactoryGameSteam-Win64-Shipping.exe`
10. **Final Fantasy XIV** - `boot/ffxivboot.exe` → `game/ffxiv_dx11.exe`
11. **Forza Horizon 5** - Auto-detected

## Unreal Engine Games

The wrapper automatically detects Unreal Engine games by looking for `Engine/` directory and searching for the actual game binary in `Binaries/Win64/`.

Examples:
- Deep Rock Galactic
- Borderlands 3
- Fortnite
- Gears 5
- Any UE4/UE5 game

## Manual Mode (Traditional)

If you prefer explicit control:

```bash
cd ~/dlss
./install.sh /path/to/game/directory [method]
```

Then add to Steam launch options:
```
WINEDLLOVERRIDES="version=n,b;nvapi64=n,b" %COMMAND%
```

## Troubleshooting

### Wrapper Not Working

Check `/tmp/fgmod-install.log` for errors:

```bash
tail -f /tmp/fgmod-install.log
```

### Game Directory Not Detected

The wrapper looks for:
1. `.exe` in command arguments
2. `STEAM_COMPAT_INSTALL_PATH` env var
3. Unreal Engine `Engine/` directory

If detection fails, use manual mode instead.

### Wrong Injection Method

Try different methods:
- `winmm` - Cyberpunk, games with version.dll conflict
- `dxgi` - Most modern games
- `d3d11` / `d3d12` - DirectX games
- `version` - Default fallback

### Backup Files Not Restored

Manually restore:
```bash
cd /path/to/game
for f in *.bak; do mv "$f" "${f%.bak}"; done
```

## File Locations

### Wrapper Installation
```
~/dlss/
├── install                           ← Symlink to install-wrapper.sh
├── uninstall                        ← Symlink to uninstall-wrapper.sh
├── install-{method}                 ← 9 per-method symlinks
├── install-wrapper.sh               ← Main wrapper script
├── uninstall-wrapper.sh             ← Uninstaller script
├── install-{method}-wrapper.sh      ← 9 per-method wrappers
├── install.sh                       ← Traditional manual installer
├── uninstall.sh                     ← Traditional uninstaller
├── version.dll                      ← v4.0 main file (27MB)
├── _nvngx.dll                       ← v3.x base runtime
├── nvngx-wrapper.dll
├── nvapi64-proxy.dll
├── dlssg_to_fsr3_amd_is_better.dll
└── dlss-finder.bin
```

### Game Directory (After Install)
```
/path/to/game/
├── game.exe
├── {method}.dll                     ← version.dll renamed to injection method
├── {method}.dll.bak                 ← Original backup (if existed)
├── _nvngx.dll
├── nvngx-wrapper.dll
├── nvapi64-proxy.dll
├── dlssg_to_fsr3_amd_is_better.dll
├── dlss-finder.bin
├── nvngx.ini                        ← Config file
├── dlss-enabler.log                 ← Runtime logs
├── dlssg-to-fsr3.log
└── nvngx.log
```

## Examples

### Example 1: Cyberpunk 2077

```
Game Properties → Launch Options:
~/dlss/install --method=winmm %command%
```

Or:
```
~/dlss/install-winmm %command%
```

### Example 2: Witcher 3

```
~/dlss/install --method=version %command%
```

Or just:
```
~/dlss/install %command%
```

### Example 3: Baldur's Gate 3

```
~/dlss/install --method=dxgi %command%
```

Or:
```
~/dlss/install-dxgi %command%
```

### Example 4: Unreal Engine Game (e.g., Satisfactory)

```
~/dlss/install %command%
```

Automatically detects UE structure and finds correct binary.

## Advanced Usage

### Custom Wrapper

Create your own wrapper with custom logic:

```bash
#!/bin/bash
export CUSTOM_VAR="value"
exec ~/dlss/install --method=winmm "$@"
```

### Debugging

Enable debug mode in wrapper:
```bash
set -x  # Add to install-wrapper.sh
```

Check logs:
```bash
tail -f /tmp/fgmod-install.log
```

### Multiple Games

Each game gets its own installation in its game directory. The `~/dlss/` directory just holds the source files. You can install to unlimited games.
