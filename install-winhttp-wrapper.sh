#!/usr/bin/env bash
# DLSS Enabler v4.0 Hybrid - winhttp.dll wrapper
exec "$(dirname "${BASH_SOURCE[0]}")/install-wrapper.sh" --method=winhttp "$@"
