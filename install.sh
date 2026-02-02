#!/bin/bash
# DLSS Enabler v4.0 + v3.x Hybrid Installer
# Linux + AMD GPU support

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    echo "Usage: $0 <game_directory> [injection_method]"
    echo ""
    echo "Arguments:"
    echo "  game_directory    Path to game root (where .exe is located)"
    echo "  injection_method  version|winmm|d3d11|d3d12|dinput8|dxgi|wininet|winhttp|dbghelp (default: version)"
    echo ""
    echo "Common methods by game:"
    echo "  version   - Most games (default)"
    echo "  winmm     - Cyberpunk 2077, games with existing version.dll"
    echo "  d3d11     - DX11 games"
    echo "  d3d12     - DX12 games"
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

V4_DLL="$SCRIPT_DIR/version.dll"
if [ ! -f "$V4_DLL" ]; then
    echo "Error: version.dll not found in $SCRIPT_DIR"
    exit 1
fi

if [ -f "$GAME_DIR/$INJECTION_DLL" ]; then
    echo "Warning: $INJECTION_DLL exists in game directory"
    read -p "Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Installing DLSS Enabler v4.0 Hybrid..."
echo "Target: $GAME_DIR"
echo "Injection: $INJECTION_DLL"
echo ""

# Copy v3.x base files
cp -v "$SCRIPT_DIR/_nvngx.dll" "$GAME_DIR/"
cp -v "$SCRIPT_DIR/nvngx-wrapper.dll" "$GAME_DIR/"
cp -v "$SCRIPT_DIR/nvapi64-proxy.dll" "$GAME_DIR/"

# Only copy dxgi.dll if NOT using it for injection (conflict avoidance)
if [ "$INJECTION_METHOD" != "dxgi" ]; then
    cp -v "$SCRIPT_DIR/dxgi.dll" "$GAME_DIR/"
fi

cp -v "$SCRIPT_DIR/dlssg_to_fsr3_amd_is_better.dll" "$GAME_DIR/"
cp -v "$SCRIPT_DIR/dlss-finder.bin" "$GAME_DIR/"
cp -v "$SCRIPT_DIR/dlss-enabler.log" "$GAME_DIR/"
cp -v "$SCRIPT_DIR/dlssg-to-fsr3.log" "$GAME_DIR/"
cp -v "$SCRIPT_DIR/nvngx.log" "$GAME_DIR/"

# Copy v4.0 as injection DLL
cp -v "$V4_DLL" "$GAME_DIR/$INJECTION_DLL"

# Create default config if needed
if [ ! -f "$GAME_DIR/nvngx.ini" ]; then
    cat > "$GAME_DIR/nvngx.ini" << 'EOF'
[DLSS]
Enabled = true

[DLSSG]
Enabled = true

[Logging]
Enabled = true
EOF
    echo "Created: nvngx.ini"
fi

echo ""
echo "Installation complete."
echo ""
echo "Add to Steam launch options:"
echo ""

# Build Wine override based on injection method
WINE_OVERRIDE="${INJECTION_METHOD}=n,b;nvapi64=n,b"
if [ "$INJECTION_METHOD" != "dxgi" ]; then
    WINE_OVERRIDE="${WINE_OVERRIDE};dxgi=n,b"
fi

echo "WINEDLLOVERRIDES=\"${WINE_OVERRIDE}\" %COMMAND%"
echo ""
echo "Injection method: $INJECTION_DLL"
if [ "$INJECTION_METHOD" == "dxgi" ]; then
    echo "Note: dxgi.dll proxy skipped (using dxgi for injection)"
fi
echo ""
echo "Check logs in game directory if issues occur."
