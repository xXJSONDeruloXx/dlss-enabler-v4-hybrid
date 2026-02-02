#!/usr/bin/env bash
# Generate per-method wrapper scripts

METHODS=("version" "winmm" "d3d11" "d3d12" "dinput8" "dxgi" "wininet" "winhttp" "dbghelp")

for method in "${METHODS[@]}"; do
  cat > "install-${method}-wrapper.sh" << WRAPPER
#!/usr/bin/env bash
# DLSS Enabler v4.0 Hybrid - ${method}.dll wrapper
exec "\$(dirname "\${BASH_SOURCE[0]}")/install-wrapper.sh" --method=${method} "\$@"
WRAPPER
  chmod +x "install-${method}-wrapper.sh"
  echo "Created: install-${method}-wrapper.sh"
done

echo "Done! Created ${#METHODS[@]} method-specific wrappers."
