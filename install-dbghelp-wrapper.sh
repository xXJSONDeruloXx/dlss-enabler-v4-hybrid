#!/usr/bin/env bash
# DLSS Enabler v4.0 Hybrid - dbghelp.dll wrapper
exec "$(dirname "${BASH_SOURCE[0]}")/install-wrapper.sh" --method=dbghelp "$@"
