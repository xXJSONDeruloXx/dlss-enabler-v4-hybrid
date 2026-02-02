# dxgi.dll - DirectX Graphics Infrastructure Proxy (DLSS Enabler v3.x)

## Overview

**File:** `dxgi.dll`  
**Size:** 72 KB  
**Type:** DXGI adapter enumeration proxy  
**Version:** DLSS Enabler v3.x component  

A lightweight proxy for DirectX Graphics Infrastructure (DXGI) adapter enumeration. This DLL intercepts calls to `CreateDXGIFactory` and related functions to facilitate GPU adapter queries on non-NVIDIA hardware.

## Purpose

DXGI is Microsoft's graphics abstraction layer in Windows. Games use it to:
- Enumerate GPUs
- Query GPU capabilities
- Create swap chains
- Manage display outputs

This proxy ensures that:
1. Games can enumerate AMD/Intel GPUs correctly
2. Adapter queries return expected data structures
3. Compatibility with DLSS Enabler's GPU spoofing

## Important Note: Two Different dxgi.dll Roles

### Role 1: v3.x Adapter Proxy (This File)

**When injection method ≠ dxgi:**
- Coexists with `version.dll` (renamed to something else)
- Provides adapter enumeration support
- Small shim, minimal functionality

### Role 2: v4.0 Injection DLL

**When injection method = dxgi:**
- `version.dll` renamed to `dxgi.dll`
- 27 MB all-in-one loader
- Replaces this 72 KB proxy

**This document describes the v3.x 72 KB proxy version.**

## Exported Functions

### Core DXGI Factory Functions

```c
CreateDXGIFactory
CreateDXGIFactory1
CreateDXGIFactory2
```

These are the primary entry points for DirectX applications to initialize DXGI.

### What It Does

1. **Intercept factory creation calls**
2. **Chain to system dxgi.dll** (C:\Windows\System32\dxgi.dll)
3. **Wrap adapter enumeration** methods
4. **Log adapter queries** for debugging

## How It Works

### Call Flow

```
Game calls CreateDXGIFactory1
    ↓
dxgi.dll (this proxy) receives call
    ↓
Loads system C:\Windows\System32\dxgi.dll
    ↓
Calls system CreateDXGIFactory1
    ↓
Wraps returned IDXGIFactory interface
    ↓
Returns wrapped factory to game
    ↓
Game calls factory->EnumAdapters
    ↓
Proxy intercepts, logs, passes through
    ↓
Returns adapter list to game
```

### Adapter Enumeration

When game enumerates adapters:

```cpp
IDXGIFactory* factory;
CreateDXGIFactory1(__uuidof(IDXGIFactory), (void**)&factory);

// These calls are intercepted:
factory->EnumAdapters(0, &adapter);        // IDXGIFactory
factory->EnumAdapters1(0, &adapter);       // IDXGIFactory1
factory->EnumAdapterByLuid(luid, &adapter); // IDXGIFactory4
factory->EnumAdapterByGpuPreference(...);   // IDXGIFactory6
```

## Logging

Detailed adapter enumeration logs:

```
IDXGIFactory.EnumAdapters: adapter: 0
IDXGIFactory.EnumAdapters: succeeded
IDXGIFactory1.EnumAdapters1: adapter: 0
IDXGIFactory1.EnumAdapters1: succeeded
IDXGIFactory4.EnumAdapterByLuid: LUID: 0x12345
IDXGIFactory4.EnumAdapterByLuid: succeeded
IDXGIFactory6.EnumAdapterByGpuPreference: succeeded
```

On failure:
```
IDXGIFactory.EnumAdapters: failed
IDXGIFactory1.EnumAdapters1: failed
```

## Technical Details

### Size Justification

72 KB is tiny because:
- No actual graphics code
- Simple function interception
- Thin wrapper around system DXGI
- Minimal logging infrastructure

### DXGI Version Support

Supports all DXGI interface versions:
- `IDXGIFactory` (DirectX 10.0)
- `IDXGIFactory1` (DirectX 10.1)
- `IDXGIFactory2` (DirectX 11.1)
- `IDXGIFactory3` (DirectX 11.3)
- `IDXGIFactory4` (DirectX 12)
- `IDXGIFactory5` (Windows 10 1803)
- `IDXGIFactory6` (Windows 10 1903)
- `IDXGIFactory7` (Windows 11)

### System DLL Chain-Loading

Loads original DXGI from:
```
C:\Windows\System32\dxgi.dll
```

This is the real Microsoft implementation. The proxy just wraps it.

## Reverse Engineering Notes

### Key Strings

```
"CreateDXGIFactory"
"CreateDXGIFactory1"
"CreateDXGIFactory2"
"IDXGIFactory6.EnumAdapterByGpuPreference"
"IDXGIFactory6.EnumAdapterByGpuPreference: succeeded"
"IDXGIFactory6.EnumAdapterByGpuPreference: failed"
"IDXGIFactory4.EnumAdapterByLuid: LUID:"
"IDXGIFactory4.EnumAdapterByLuid: succeeded"
"IDXGIFactory4.EnumAdapterByLuid: failed"
"IDXGIFactory1.EnumAdapters1: adapter:"
"IDXGIFactory1.EnumAdapters1: succeeded"
"IDXGIFactory1.EnumAdapters1: failed"
"IDXGIFactory.EnumAdapters: adapter:"
"IDXGIFactory.EnumAdapters: succeeded"
"IDXGIFactory.EnumAdapters: failed"
"IsProcessorFeaturePresent"
"IsDebuggerPresent"
```

### No GPU Spoofing

This DLL does NOT perform GPU spoofing. That's the job of `nvapi64-proxy.dll`.

This proxy only:
- Logs adapter enumeration
- Ensures compatibility with DLSS Enabler's other components
- Provides debugging information

### Clean Export Table

Standard Windows DLL:
- 3 exports: CreateDXGIFactory, CreateDXGIFactory1, CreateDXGIFactory2
- No obfuscation
- No anti-debug

## Usage in Hybrid Installation

### When Injection Method ≠ dxgi

Example: Using `version.dll` injection

```
game/
├── version.dll (v4.0 - 27MB)
├── dxgi.dll (v3.x proxy - 72KB) ← This file
├── _nvngx.dll
├── nvapi64-proxy.dll
└── dlssg_to_fsr3_amd_is_better.dll
```

Both DLLs coexist:
- `version.dll` handles injection and main logic
- `dxgi.dll` handles adapter enumeration support

Wine override:
```bash
WINEDLLOVERRIDES="version=n,b;nvapi64=n,b;dxgi=n,b" %COMMAND%
```

### When Injection Method = dxgi

This 72 KB file is **NOT copied**. Instead, `version.dll` is renamed to `dxgi.dll`.

```
game/
├── dxgi.dll (v4.0 - 27MB, renamed from version.dll)
├── _nvngx.dll
├── nvapi64-proxy.dll
└── dlssg_to_fsr3_amd_is_better.dll
```

Wine override:
```bash
WINEDLLOVERRIDES="dxgi=n,b;nvapi64=n,b" %COMMAND%
```

Our install script handles this conflict correctly:
```bash
if [ "$INJECTION_METHOD" != "dxgi" ]; then
    cp dxgi.dll "$GAME_DIR/"  # Copy v3.x proxy
fi
```

## Compatibility

### Supported Windows Versions

Windows 7 and later (DXGI present in all versions).

### Supported DirectX Versions

DirectX 10 through DirectX 12. Any game using DXGI.

### Known Issues

None specific to this component. Very simple and stable.

## Comparison: v3.x dxgi.dll vs System dxgi.dll

| v3.x Proxy (this file) | System dxgi.dll |
|------------------------|-----------------|
| 72 KB | ~600 KB |
| Logging wrapper | Full implementation |
| Game directory | C:\Windows\System32 |
| Wraps system DXGI | Direct driver communication |
| Custom logging | Windows event logs |

## Logging Configuration

No config file. Logging always enabled (minimal overhead).

## Performance Impact

Negligible. Simple function interception adds <0.1 ms overhead per call.

Adapter enumeration happens:
- Once at game startup
- Occasionally during resolution changes
- Not per-frame, so no FPS impact

## Source Code

Part of DLSS Enabler v3.x:
https://github.com/artur-graniszewski/DLSS-Enabler

Likely source file:
- `dxgi_proxy.cpp`

## Alternative: dxvk

For Linux/Proton users, DXVK provides full DXGI translation:
https://github.com/doitsujin/dxvk

DXVK translates DirectX to Vulkan, while this proxy just logs and wraps native DXGI.

## Why Is This Needed?

### Without This Proxy

Games using DXGI + DLSS Enabler might:
- Fail to enumerate adapters correctly
- Miss GPU capability checks
- Have timing issues with factory creation

### With This Proxy

- Clean adapter enumeration
- Detailed logs for troubleshooting
- Compatibility layer for DLSS Enabler components

## Troubleshooting

### Game Won't Start

If game crashes at startup with dxgi.dll present:
- Check if another dxgi.dll mod is installed (conflict)
- Verify Wine override includes `dxgi=n,b`
- Try removing dxgi.dll (not always required)

### Adapter Not Detected

If game doesn't see GPU:
- Check logs for "EnumAdapters: failed"
- Ensure Wine prefix is configured correctly
- Verify real GPU is visible in Wine

## Future Considerations

This is a v3.x component. DLSS Enabler v4.0 may eventually eliminate the need for this proxy by:
- Handling adapter enumeration internally
- Better integration with system DXGI
- Reduced DLL count

## Summary

This is a simple, stable, tiny proxy that:
- Wraps DXGI factory creation
- Logs adapter enumeration
- Provides compatibility support
- Coexists with v4.0 (unless using dxgi injection)

Not glamorous, but essential for AMD/Intel GPU support in the hybrid installation.
