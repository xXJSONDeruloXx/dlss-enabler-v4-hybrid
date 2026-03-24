#!/bin/bash
# OptiScaler package installer

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

if [ ! -f "$SCRIPT_DIR/version.dll" ]; then
    echo "Error: version.dll not found in $SCRIPT_DIR"
    exit 1
fi

backup_if_exists() {
    local file="$1"
    if [ -f "$file" ] && [[ ! "$file" == *.bak ]]; then
        local backup="${file}.bak"
        if [ ! -f "$backup" ]; then
            echo "Backing up: $(basename "$file") -> $(basename "$backup")"
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

echo "Installing OptiScaler package..."
echo "Target: $GAME_DIR"
echo "Injection: $INJECTION_DLL"
echo ""
echo "Checking for existing files to backup..."

backup_if_exists "$GAME_DIR/$INJECTION_DLL"
backup_if_exists "$GAME_DIR/d3d11.dll"
backup_if_exists "$GAME_DIR/d3d12.dll"
if [ "$INJECTION_METHOD" = "dxgi" ]; then
    backup_if_exists "$GAME_DIR/dxgi.dll"
fi
for file in "${RUNTIME_FILES[@]}" "${CONFIG_FILES[@]}"; do
    backup_if_exists "$GAME_DIR/$file"
done

echo ""
echo "Installing runtime files..."
for file in "${RUNTIME_FILES[@]}"; do
    cp -v "$SCRIPT_DIR/$file" "$GAME_DIR/"
done

for file in "${CONFIG_FILES[@]}"; do
    if [ ! -f "$GAME_DIR/$file" ]; then
        cp -v "$SCRIPT_DIR/$file" "$GAME_DIR/"
    fi
done

mkdir -p "$GAME_DIR/D3D12_Optiscaler" "$GAME_DIR/plugins"
cp -v "$SCRIPT_DIR/D3D12_Optiscaler/D3D12Core.dll" "$GAME_DIR/D3D12_Optiscaler/"
cp -v "$SCRIPT_DIR/plugins/OptiPatcher.asi" "$GAME_DIR/plugins/"

echo ""
echo "Installing injection DLL..."
cp -v "$SCRIPT_DIR/version.dll" "$GAME_DIR/$INJECTION_DLL"

echo ""
echo "Installation complete."
echo ""

BACKUP_COUNT=$(find "$GAME_DIR" -maxdepth 1 -name "*.bak" -type f | wc -l)
if [ "$BACKUP_COUNT" -gt 0 ]; then
    echo "Backups created:"
    ls -lh "$GAME_DIR"/*.bak 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
    echo ""
fi

echo "Add to Steam launch options:"
echo "WINEDLLOVERRIDES=\"${INJECTION_METHOD}=n,b\" %COMMAND%"
echo ""
echo "Insert opens OptiScaler overlay; Page Up/Down toggles performance stats."
