#!/bin/bash
# OptiScaler package uninstaller

set -e

usage() {
    echo "Usage: $0 <game_directory> [injection_method]"
    echo ""
    echo "Arguments:"
    echo "  game_directory    Path to game root (where .exe is located)"
    echo "  injection_method  version|winmm|d3d11|d3d12|dinput8|dxgi|wininet|winhttp|dbghelp (default: version)"
    echo ""
    echo "Example:"
    echo "  $0 ~/.steam/steam/steamapps/common/GameName"
    echo "  $0 /path/to/game winmm"
    exit 1
}

if [ $# -lt 1 ]; then
    usage
fi

GAME_DIR="$1"
INJECTION_METHOD="${2:-version}"
INJECTION_DLL="${INJECTION_METHOD}.dll"
VALID_METHODS=("version" "winmm" "d3d11" "d3d12" "dinput8" "dxgi" "wininet" "winhttp" "dbghelp")

if [[ ! " ${VALID_METHODS[*]} " =~ " ${INJECTION_METHOD} " ]]; then
    echo "Error: Invalid injection method: $INJECTION_METHOD"
    echo "Valid methods: ${VALID_METHODS[*]}"
    exit 1
fi

if [ ! -d "$GAME_DIR" ]; then
    echo "Error: Game directory does not exist: $GAME_DIR"
    exit 1
fi

echo "Uninstalling OptiScaler package..."
echo "Target: $GAME_DIR"
echo "Injection method: $INJECTION_DLL"
echo ""

echo "Files to remove:"
FILES_TO_REMOVE=(
    "$INJECTION_DLL"
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
)

for file in "${FILES_TO_REMOVE[@]}"; do
    if [ -f "$GAME_DIR/$file" ]; then
        echo "  $file"
    fi
done
if [ -d "$GAME_DIR/D3D12_Optiscaler" ]; then echo "  D3D12_Optiscaler/"; fi
if [ -d "$GAME_DIR/plugins" ]; then echo "  plugins/"; fi

echo ""
read -p "Proceed with uninstallation? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

echo ""
echo "Removing files..."
for file in "${FILES_TO_REMOVE[@]}"; do
    if [ -f "$GAME_DIR/$file" ]; then
        rm -v "$GAME_DIR/$file"
    fi
done

rm -rf "$GAME_DIR/D3D12_Optiscaler"
rm -rf "$GAME_DIR/plugins"

echo ""
BACKUP_COUNT=$(find "$GAME_DIR" -maxdepth 1 -name "*.bak" -type f 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 0 ]; then
    echo "Restoring backups..."
    for backup in "$GAME_DIR"/*.bak; do
        if [ -f "$backup" ]; then
            original="${backup%.bak}"
            echo "  $(basename "$backup") -> $(basename "$original")"
            mv "$backup" "$original"
        fi
    done
else
    echo "No backup files found."
fi

echo ""
echo "Uninstallation complete."
