#!/bin/bash
# DLSS Enabler v4.0 Hybrid Uninstaller
# Removes all DLSS Enabler files and restores backups

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

# Validate injection method
VALID_METHODS=("version" "winmm" "d3d11" "d3d12" "dinput8" "dxgi" "wininet" "winhttp" "dbghelp")
if [[ ! " ${VALID_METHODS[@]} " =~ " ${INJECTION_METHOD} " ]]; then
    echo "Error: Invalid injection method: $INJECTION_METHOD"
    echo "Valid methods: ${VALID_METHODS[@]}"
    exit 1
fi

if [ ! -d "$GAME_DIR" ]; then
    echo "Error: Game directory does not exist: $GAME_DIR"
    exit 1
fi

echo "Uninstalling DLSS Enabler v4.0 Hybrid..."
echo "Target: $GAME_DIR"
echo "Injection method: $INJECTION_DLL"
echo ""

# List files to be removed
echo "Files to remove:"
FILES_TO_REMOVE=(
    "$INJECTION_DLL"
    "_nvngx.dll"
    "nvngx-wrapper.dll"
    "nvapi64-proxy.dll"
    "dxgi.dll"
    "dlssg_to_fsr3_amd_is_better.dll"
    "dlss-finder.bin"
    "dlss-enabler.log"
    "dlssg-to-fsr3.log"
    "nvngx.log"
    "nvngx.ini"
)

for file in "${FILES_TO_REMOVE[@]}"; do
    if [ -f "$GAME_DIR/$file" ]; then
        echo "  $file"
    fi
done

echo ""
read -p "Proceed with uninstallation? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

# Remove DLSS Enabler files
echo ""
echo "Removing files..."
for file in "${FILES_TO_REMOVE[@]}"; do
    if [ -f "$GAME_DIR/$file" ]; then
        rm -v "$GAME_DIR/$file"
    fi
done

# Restore backups
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
echo ""
echo "Game should now run with original DLLs."
