#!/usr/bin/env bash
# DLSS Enabler v4.0 Hybrid - Wrapper Mode
# Usage: ~/dlss/install [--method=METHOD] %command%

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default injection method
INJECTION_METHOD="version"

# Parse arguments
for arg in "$@"; do
  if [[ "$arg" == --method=* ]]; then
    INJECTION_METHOD="${arg#--method=}"
  fi
done

# Validate injection method
VALID_METHODS=("version" "winmm" "d3d11" "d3d12" "dinput8" "dxgi" "wininet" "winhttp" "dbghelp")
if [[ ! " ${VALID_METHODS[@]} " =~ " ${INJECTION_METHOD} " ]]; then
  echo "Error: Invalid injection method: $INJECTION_METHOD"
  echo "Valid methods: ${VALID_METHODS[@]}"
  exit 1
fi

INJECTION_DLL="${INJECTION_METHOD}.dll"

# === Resolve Game Path ===
exe_folder_path=""

# Extract .exe from command-line arguments
for arg in "$@"; do
  if [[ "$arg" == *.exe ]]; then
    # Hardcoded game launcher redirects
    case "$arg" in
      *"Cyberpunk 2077"*)
        arg="${arg//REDprelauncher.exe/bin/x64/Cyberpunk2077.exe}"
        ;;
      *"Witcher 3"*)
        arg="${arg//REDprelauncher.exe/bin/x64_dx12/witcher3.exe}"
        ;;
      *"Baldurs Gate 3"*|*"Baldur's Gate 3"*)
        arg="${arg//Launcher\/LariLauncher.exe/bin/bg3_dx11.exe}"
        ;;
      *"HITMAN 3"*|*"HITMAN World of Assassination"*)
        arg="${arg//Launcher.exe/Retail/HITMAN3.exe}"
        ;;
      *"SYNCED"*)
        arg="${arg//Launcher\/sop_launcher.exe/SYNCED.exe}"
        ;;
      *"2KLauncher"*)
        arg="${arg//2KLauncher\/LauncherPatcher.exe/DoesntMatter.exe}"
        ;;
      *"Warhammer 40,000 DARKTIDE"*|*"Warhammer 40,000: Darktide"*)
        arg="${arg//launcher\/Launcher.exe/binaries/Darktide.exe}"
        ;;
      *"Warhammer Vermintide 2"*|*"Warhammer: Vermintide 2"*)
        arg="${arg//launcher\/Launcher.exe/binaries_dx12/vermintide2_dx12.exe}"
        ;;
      *"Satisfactory"*)
        arg="${arg//FactoryGameSteam.exe/Engine/Binaries/Win64/FactoryGameSteam-Win64-Shipping.exe}"
        ;;
      *"FINAL FANTASY XIV Online"*|*"Final Fantasy XIV"*)
        arg="${arg//boot\/ffxivboot.exe/game/ffxiv_dx11.exe}"
        ;;
      *"Forza Horizon 5"*)
        arg="${arg//ForzaHorizon5.exe/ForzaHorizon5.exe}"
        ;;
    esac
    
    exe_folder_path=$(dirname "$arg")
    break
  fi
done

# Fallback to STEAM_COMPAT_INSTALL_PATH
if [[ -z "$exe_folder_path" ]] && [[ -n "$STEAM_COMPAT_INSTALL_PATH" ]]; then
  exe_folder_path="$STEAM_COMPAT_INSTALL_PATH"
fi

# Detect Unreal Engine games
if [[ -d "$exe_folder_path/Engine" ]]; then
  echo "Unreal Engine game detected, searching for game executable..."
  ue_exe=$(find "$exe_folder_path" -maxdepth 4 -mindepth 4 \
    -path "*/Binaries/Win64/*.exe" -not -path "*/Engine/*" | head -1)
  
  if [[ -n "$ue_exe" ]]; then
    exe_folder_path=$(dirname "$ue_exe")
    echo "Using UE game binary directory: $exe_folder_path"
  fi
fi

# Validate directory
if [[ ! -d "$exe_folder_path" ]]; then
  echo "Error: Could not resolve game directory!"
  exit 1
fi

if [[ ! -w "$exe_folder_path" ]]; then
  echo "Error: No write permission to game folder!"
  exit 1
fi

echo "Installing DLSS Enabler v4.0 Hybrid to: $exe_folder_path"
echo "Injection method: $INJECTION_DLL"

# Function to backup a file if it exists
backup_if_exists() {
  local file="$1"
  if [[ -f "$file" ]] && [[ ! "$file" == *.bak ]]; then
    local backup="${file}.bak"
    if [[ ! -f "$backup" ]]; then
      echo "Backing up: $(basename "$file")"
      cp "$file" "$backup"
    fi
  fi
}

# Backup existing files
backup_if_exists "$exe_folder_path/$INJECTION_DLL"
if [[ "$INJECTION_METHOD" == "dxgi" ]]; then
  backup_if_exists "$exe_folder_path/dxgi.dll"
fi
backup_if_exists "$exe_folder_path/d3d11.dll"
backup_if_exists "$exe_folder_path/d3d12.dll"
backup_if_exists "$exe_folder_path/nvapi64.dll"
backup_if_exists "$exe_folder_path/nvapi64-proxy.dll"

# Copy v3.x base files
cp -f "$SCRIPT_DIR/_nvngx.dll" "$exe_folder_path/"
cp -f "$SCRIPT_DIR/nvngx-wrapper.dll" "$exe_folder_path/"
cp -f "$SCRIPT_DIR/nvapi64-proxy.dll" "$exe_folder_path/"
cp -f "$SCRIPT_DIR/dlssg_to_fsr3_amd_is_better.dll" "$exe_folder_path/"
cp -f "$SCRIPT_DIR/dlss-finder.bin" "$exe_folder_path/"

# Copy placeholder logs
cp -f "$SCRIPT_DIR/dlss-enabler.log" "$exe_folder_path/" 2>/dev/null || touch "$exe_folder_path/dlss-enabler.log"
cp -f "$SCRIPT_DIR/dlssg-to-fsr3.log" "$exe_folder_path/" 2>/dev/null || touch "$exe_folder_path/dlssg-to-fsr3.log"
cp -f "$SCRIPT_DIR/nvngx.log" "$exe_folder_path/" 2>/dev/null || touch "$exe_folder_path/nvngx.log"

# Copy v4.0 as injection DLL
cp -f "$SCRIPT_DIR/version.dll" "$exe_folder_path/$INJECTION_DLL"

# Create default config if needed
if [[ ! -f "$exe_folder_path/nvngx.ini" ]]; then
  cat > "$exe_folder_path/nvngx.ini" << 'EOF'
[DLSS]
Enabled = true

[DLSSG]
Enabled = true

[Logging]
Enabled = true
EOF
fi

echo "Installation complete!"

# Execute original command with Wine overrides
export WINEDLLOVERRIDES="${INJECTION_METHOD}=n,b;nvapi64=n,b${WINEDLLOVERRIDES:+,$WINEDLLOVERRIDES}"

# Filter out leading -- separators (from Steam launch options)
while [[ $# -gt 0 && "$1" == "--" ]]; do
  shift
done

"$@"
