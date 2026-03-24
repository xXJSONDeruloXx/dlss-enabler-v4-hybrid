#!/usr/bin/env bash
# OptiScaler wrapper mode uninstaller
# Usage: ~/dlss/uninstall %command%

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
  ue_exe=$(find "$exe_folder_path" -maxdepth 4 -mindepth 4 -path "*/Binaries/Win64/*.exe" -not -path "*/Engine/*" | head -1)
  if [[ -n "$ue_exe" ]]; then
    exe_folder_path=$(dirname "$ue_exe")
  fi
fi

if [[ ! -d "$exe_folder_path" ]]; then
  echo "Error: Could not resolve game directory!"
  exit 1
fi

echo "Uninstalling OptiScaler package from: $exe_folder_path"

FILES_TO_REMOVE=(
  "version.dll"
  "winmm.dll"
  "d3d11.dll"
  "d3d12.dll"
  "dinput8.dll"
  "dxgi.dll"
  "wininet.dll"
  "winhttp.dll"
  "dbghelp.dll"
  "fakenvapi.dll"
  "fakenvapi.ini"
  "fakenvapi.log"
  "dlssg_to_fsr3_amd_is_better.dll"
  "dlssg_to_fsr3.log"
  "OptiScaler.ini"
  "OptiScaler.log"
  "libxell.dll"
  "libxess.dll"
  "libxess_dx11.dll"
  "libxess_fg.dll"
  "amd_fidelityfx_dx12.dll"
  "amd_fidelityfx_framegeneration_dx12.dll"
  "amd_fidelityfx_upscaler_dx12.dll"
  "amd_fidelityfx_vk.dll"
  "_nvngx.dll"
  "nvngx-wrapper.dll"
  "nvapi64-proxy.dll"
  "dlss-finder.bin"
  "dlss-enabler.log"
  "nvngx.log"
  "nvngx.ini"
)

for file in "${FILES_TO_REMOVE[@]}"; do
  if [[ -f "$exe_folder_path/$file" ]]; then
    echo "Removing: $file"
    rm -f "$exe_folder_path/$file"
  fi
done

rm -rf "$exe_folder_path/D3D12_Optiscaler"
rm -rf "$exe_folder_path/plugins"

if compgen -G "$exe_folder_path/*.bak" > /dev/null; then
  echo "Restoring backups..."
  for backup in "$exe_folder_path"/*.bak; do
    if [[ -f "$backup" ]]; then
      original="${backup%.bak}"
      echo "Restoring: $(basename "$backup") -> $(basename "$original")"
      mv "$backup" "$original"
    fi
  done
else
  echo "No backup files found."
fi

echo "Uninstallation complete!"

while [[ $# -gt 0 && "$1" == "--" ]]; do
  shift
done

"$@"
