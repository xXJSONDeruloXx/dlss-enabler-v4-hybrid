#!/usr/bin/env bash
# DLSS Enabler v4.0 Hybrid - One-liner installer
# Downloads and sets up ~/dlss/ for Steam wrapper usage

set -e

INSTALL_DIR="$HOME/dlss"
REPO_URL="https://github.com/xXJSONDeruloXx/dlss-enabler-v4-hybrid"
RELEASE_URL="$REPO_URL/archive/refs/heads/main.tar.gz"

echo "DLSS Enabler v4.0 Hybrid - Quick Setup"
echo "======================================="
echo ""
echo "Installing to: $INSTALL_DIR"
echo ""

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Download and extract
echo "Downloading latest version..."
cd "$INSTALL_DIR"
curl -L "$RELEASE_URL" -o dlss-enabler.tar.gz

echo "Extracting files..."
tar -xzf dlss-enabler.tar.gz --strip-components=1
rm dlss-enabler.tar.gz

# Create symlinks for wrapper scripts (no .sh extension)
echo "Setting up wrapper scripts..."
ln -sf "$INSTALL_DIR/install-wrapper.sh" "$INSTALL_DIR/install"
ln -sf "$INSTALL_DIR/uninstall-wrapper.sh" "$INSTALL_DIR/uninstall"

# Create per-method wrapper symlinks
METHODS=("version" "winmm" "d3d11" "d3d12" "dinput8" "dxgi" "wininet" "winhttp" "dbghelp")
for method in "${METHODS[@]}"; do
  ln -sf "$INSTALL_DIR/install-${method}-wrapper.sh" "$INSTALL_DIR/install-${method}"
done

# Make all scripts executable
chmod +x "$INSTALL_DIR"/*.sh
chmod +x "$INSTALL_DIR/install"
chmod +x "$INSTALL_DIR/uninstall"
for method in "${METHODS[@]}"; do
  chmod +x "$INSTALL_DIR/install-${method}"
done

echo ""
echo "Installation complete!"
echo ""
echo "=========================================="
echo "Usage - Add to Steam launch options:"
echo "=========================================="
echo ""
echo "Install (default version.dll):"
echo "  ~/dlss/install %command%"
echo ""
echo "Install with specific method:"
echo "  ~/dlss/install --method=winmm %command%"
echo "  ~/dlss/install --method=dxgi %command%"
echo ""
echo "Uninstall:"
echo "  ~/dlss/uninstall %command%"
echo ""
echo "Available methods:"
echo "  version, winmm, d3d11, d3d12, dinput8, dxgi,"
echo "  wininet, winhttp, dbghelp"
echo ""
echo "Per-method wrappers (alternative):"
echo "  ~/dlss/install-winmm %command%"
echo "  ~/dlss/install-dxgi %command%"
echo "  (and 7 more...)"
echo ""
echo "Manual installation (traditional):"
echo "  cd ~/dlss"
echo "  ./install.sh /path/to/game [method]"
echo ""
