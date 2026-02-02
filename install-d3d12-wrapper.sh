#!/usr/bin/env bash
# DLSS Enabler v4.0 Hybrid - d3d12.dll wrapper
exec "$(dirname "${BASH_SOURCE[0]}")/install-wrapper.sh" --method=d3d12 "$@"
