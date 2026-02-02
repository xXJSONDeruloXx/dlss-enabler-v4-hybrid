# version.dll - DLSS Enabler v4.0 Main Loader

## Overview

**File:** `version.dll` (DLSS_Enabler.dll renamed)  
**Size:** 27 MB  
**Type:** All-in-one injection DLL  
**Version:** 4.0.0.2+  

The main entry point for DLSS Enabler v4.0. This is a massive DLL containing the complete OptiScaler upscaling engine, frame generation logic, and runtime hooking infrastructure.

## Architecture

### Core Components

1. **OptiScaler Integration** - Built-in upscaling engine
2. **Frame Generation Engine** - Multi-frame generation (2x/3x/4x)
3. **NvAPI Emulation** - NVIDIA API compatibility layer
4. **DirectX/Vulkan Hooks** - Graphics API interception
5. **Menu Overlay System** - In-game configuration UI

### Injection Methods Supported

The DLL can be renamed to any of these for injection:
- `version.dll` (most common)
- `winmm.dll` (audio API proxy)
- `d3d11.dll` (DirectX 11)
- `d3d12.dll` (DirectX 12)
- `dxgi.dll` (DirectX Graphics Infrastructure)
- `dinput8.dll` (DirectInput)
- `wininet.dll` (WinINet)
- `winhttp.dll` (WinHTTP)
- `dbghelp.dll` (Debug Help Library)

## Key Features

### 1. OptiScaler Upscaling

Built-in upscaling backends:
- FSR 3.1 (AMD FidelityFX Super Resolution)
- XeSS (Intel Xe Super Sampling)
- DLSS proxy (via nvngx.dll on AMD/Intel)

Configuration flags:
```
--dlss-nvngx=proxy    # Use external nvngx.dll
--dlss-nvngx=sys      # Use system NVIDIA libraries
--dlss-nvngx=embedded # Use built-in implementation
--dlss-nvngx=native   # Pass through to real DLSS
```

### 2. Frame Generation

Supports multiple frame generation modes:
- 2x (standard double frame rate)
- 3x (triple frame generation)
- 4x (quadruple frame generation)

Adaptive frame generation:
- Enables FG only when FPS drops below threshold
- Backs off when FPS is already high
- Prevents over-generation artifacts

### 3. SSRTGI (Screen-Space Ray-Traced Global Illumination)

High-performance lighting enhancement:
- Indirect lighting and color bounce
- Minimal performance overhead
- Uses temporal data from upscaling pipeline

### 4. GPU Spoofing

Device ID spoofing for AMD/Intel GPUs:
```
VendorId: 0x10DE (NVIDIA)
DeviceId: Configurable (e.g., RTX 4090)
```

Hooks:
- `D3DKMTQueryAdapterInfo` - DirectX Kernel Mode Thunk
- `IDXGIAdapter::GetDesc` - DXGI adapter queries
- Vulkan physical device queries

## Runtime Behavior

### Initialization Sequence

1. **DLL Load** - Game loads renamed DLL as injection method
2. **Working Mode Detection** - Determines role (proxy, native, etc.)
3. **Original DLL Chain-loading** - Loads real system DLL
4. **Hook Installation** - Intercepts graphics API calls
5. **OptiScaler Init** - Initializes upscaling backend
6. **Frame Generation Setup** - Configures FG pipeline

### Library Dependencies

External DLLs loaded at runtime:
- `_nvngx.dll` - NvAPI wrapper (AMD/Intel support)
- `nvapi64-proxy.dll` - NVIDIA API proxy
- `dlssg_to_fsr3_amd_is_better.dll` - FSR3 frame gen backend
- `libxess.dll` - XeSS upscaler (optional)
- `amdxcffx64.dll` - AMD FidelityFX (optional)

### DirectX 12 Hooks

```
NVSDK_NGX_D3D12_Init
NVSDK_NGX_D3D12_CreateFeature
NVSDK_NGX_D3D12_EvaluateFeature
NVSDK_NGX_D3D12_ReleaseFeature
NVSDK_NGX_D3D12_Shutdown
NVSDK_NGX_D3D12_GetFeatureRequirements
```

### Vulkan Hooks

```
NVSDK_NGX_VULKAN_Init
NVSDK_NGX_VULKAN_CreateFeature
NVSDK_NGX_VULKAN_EvaluateFeature
NVSDK_NGX_VULKAN_ReleaseFeature
NVSDK_NGX_VULKAN_Shutdown
```

## Configuration

### Overlay Menu

Press `` ` `` (tilde/backtick) in-game to open configuration overlay.

Settings:
- Upscaler selection (FSR 3.1, XeSS, DLSS)
- Frame generation mode (2x/3x/4x)
- Adaptive FG toggle
- SSRTGI enable/disable
- Debug visualizations

### Config File

Optional `nvngx.ini` in game directory:

```ini
[DLSS]
Enabled = true

[DLSSG]
Enabled = true

[Logging]
Enabled = true
```

## Logging

Generates detailed logs:
- `dlss-enabler.log` - Main initialization and hook logs
- `nvngx.log` - NvAPI emulation calls
- `dlssg-to-fsr3.log` - Frame generation events

## AMD/Intel GPU Support

**Critical:** On non-NVIDIA GPUs, `version.dll` requires:
- `_nvngx.dll` - NvAPI wrapper
- `nvngx-wrapper.dll` - Additional wrapper
- `nvapi64-proxy.dll` - API proxy with GPU spoofing

Without these, v4.0 cannot function on AMD/Intel hardware.

## Technical Details

### Working Modes

**Proxy Mode** (`--dlss-nvngx=proxy`)
- Loads external `nvngx.dll` / `_nvngx.dll`
- Used for AMD/Intel GPU support
- Provides NvAPI emulation

**Native Mode** (`--dlss-nvngx=native`)
- Pass-through to real NVIDIA DLSS
- Only for NVIDIA GPUs with DLSS support

**Embedded Mode** (`--dlss-nvngx=embedded`)
- Uses built-in OptiScaler exclusively
- No external DLSS dependencies

### Memory Footprint

Size breakdown:
- OptiScaler engine: ~15 MB
- Frame generation shaders: ~8 MB
- Hook trampolines and runtime: ~4 MB

### Performance Impact

Frame generation overhead:
- 2x: ~2-5 ms
- 3x: ~3-7 ms
- 4x: ~4-10 ms

SSRTGI overhead:
- ~1-3 ms (context-dependent)

## Compatibility

### Supported Games

Any DirectX 11/12 or Vulkan game with native DLSS support.

Known working:
- Cyberpunk 2077
- Spider-Man Remastered
- Portal RTX
- Alan Wake 2

### Known Issues

- 4x frame generation may produce artifacts in fast motion
- Some games crash if previous DLSS Enabler versions are present
- Experimental tech preview, not production-ready

## Build Info

Compiled with:
- MSVC (Windows)
- Likely C++17/20
- Static linking of OptiScaler
- Release build with optimizations

## Reverse Engineering Notes

### Symbols Found

Major classes/namespaces:
- `OptiScaler::*`
- `FSR31FeatureDx11`, `FSR31FeatureDx12`, `FSR31FeatureVk`
- `KernelHooks::*`
- `NtdllHooks::*`
- `IFeature`, `IFeature_Dx12`, `IFeature_Vk`

### String Analysis

Key debug strings:
```
"OptiScaler working as {injection_method}.dll"
"CheckWorkingMode OptiScaler working as native upscaler"
"OptiScaler can't find original {dll_name}.dll!"
"If FSR3.1 doesn't work, try enabling OptiScaler Direct3D hooks"
```

### Anti-Analysis

Minimal obfuscation:
- Standard release build
- No packing/encryption
- Debug symbols stripped
- Logging provides insight into execution flow

## Usage in Hybrid Installation

In the hybrid v3.x + v4.0 setup:

1. Copy `version.dll` to game directory as chosen injection DLL
2. Ensure v3.x runtime files are present (`_nvngx.dll`, etc.)
3. Configure Wine overrides: `WINEDLLOVERRIDES="version=n,b;nvapi64=n,b;dxgi=n,b"`
4. Launch game, press `` ` `` for menu

## Source Code

Proprietary/closed-source. Original DLSS Enabler v3.x is available at:
https://github.com/artur-graniszewski/DLSS-Enabler

v4.0 source not publicly released.
