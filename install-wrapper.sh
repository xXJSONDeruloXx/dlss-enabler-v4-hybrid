#!/usr/bin/env bash
# OptiScaler wrapper mode
# Usage: ~/dlss/install [--method=METHOD] %command%

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INJECTION_METHOD="version"

for arg in "$@"; do
  if [[ "$arg" == --method=* ]]; then
    INJECTION_METHOD="${arg#--method=}"
  fi
done

VALID_METHODS=("version" "winmm" "d3d11" "d3d12" "dinput8" "dxgi" "wininet" "winhttp" "dbghelp")
if [[ ! " ${VALID_METHODS[*]} " =~ " ${INJECTION_METHOD} " ]]; then
  echo "Error: Invalid injection method: $INJECTION_METHOD"
  echo "Valid methods: ${VALID_METHODS[*]}"
  exit 1
fi

INJECTION_DLL="${INJECTION_METHOD}.dll"
exe_folder_path=""

for arg in "$@"; do
  if [[ "$arg" == *.exe ]]; then
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

if [[ -z "$exe_folder_path" && -n "$STEAM_COMPAT_INSTALL_PATH" ]]; then
  exe_folder_path="$STEAM_COMPAT_INSTALL_PATH"
fi

if [[ -d "$exe_folder_path/Engine" ]]; then
  echo "Unreal Engine game detected, searching for game executable..."
  ue_exe=$(find "$exe_folder_path" -maxdepth 4 -mindepth 4 -path "*/Binaries/Win64/*.exe" -not -path "*/Engine/*" | head -1)
  if [[ -n "$ue_exe" ]]; then
    exe_folder_path=$(dirname "$ue_exe")
    echo "Using UE game binary directory: $exe_folder_path"
  fi
fi

if [[ ! -d "$exe_folder_path" ]]; then
  echo "Error: Could not resolve game directory!"
  exit 1
fi

if [[ ! -w "$exe_folder_path" ]]; then
  echo "Error: No write permission to game folder!"
  exit 1
fi

echo "Installing OptiScaler package to: $exe_folder_path"
echo "Injection method: $INJECTION_DLL"

backup_if_exists() {
  local file="$1"
  if [[ -f "$file" && ! "$file" == *.bak ]]; then
    local backup="${file}.bak"
    if [[ ! -f "$backup" ]]; then
      echo "Backing up: $(basename "$file")"
      cp "$file" "$backup"
    fi
  fi
}

CONFIG_FILES=(
  "OptiScaler.ini"
  "fakenvapi.ini"
)

RUNTIME_FILES=(
  "fakenvapi.dll"
  "dlssg_to_fsr3_amd_is_better.dll"
  "libxell.dll"
  "libxess.dll"
  "libxess_dx11.dll"
  "libxess_fg.dll"
  "amd_fidelityfx_dx12.dll"
  "amd_fidelityfx_framegeneration_dx12.dll"
  "amd_fidelityfx_upscaler_dx12.dll"
  "amd_fidelityfx_vk.dll"
)

for file in "$exe_folder_path/$INJECTION_DLL" "$exe_folder_path/d3d11.dll" "$exe_folder_path/d3d12.dll"; do
  backup_if_exists "$file"
done
if [[ "$INJECTION_METHOD" == "dxgi" ]]; then
  backup_if_exists "$exe_folder_path/dxgi.dll"
fi
for file in "${RUNTIME_FILES[@]}" "${CONFIG_FILES[@]}"; do
  backup_if_exists "$exe_folder_path/$file"
done

for file in "${RUNTIME_FILES[@]}"; do
  cp -f "$SCRIPT_DIR/$file" "$exe_folder_path/"
done

for file in "${CONFIG_FILES[@]}"; do
  if [[ ! -f "$exe_folder_path/$file" ]]; then
    cp "$SCRIPT_DIR/$file" "$exe_folder_path/"
  fi
done

mkdir -p "$exe_folder_path/D3D12_Optiscaler" "$exe_folder_path/plugins"
cp -f "$SCRIPT_DIR/D3D12_Optiscaler/D3D12Core.dll" "$exe_folder_path/D3D12_Optiscaler/"
cp -f "$SCRIPT_DIR/plugins/OptiPatcher.asi" "$exe_folder_path/plugins/"
cp -f "$SCRIPT_DIR/version.dll" "$exe_folder_path/$INJECTION_DLL"

echo "Installation complete!"

export WINEDLLOVERRIDES="${INJECTION_METHOD}=n,b${WINEDLLOVERRIDES:+,$WINEDLLOVERRIDES}"

FILTERED_ARGS=()
for arg in "$@"; do
  if [[ "$arg" == --method=* ]]; then
    continue
  fi
  FILTERED_ARGS+=("$arg")
done

while [[ ${#FILTERED_ARGS[@]} -gt 0 && "${FILTERED_ARGS[0]}" == "--" ]]; do
  FILTERED_ARGS=("${FILTERED_ARGS[@]:1}")
done

"${FILTERED_ARGS[@]}"
