# _nvngx.dll - NvAPI Wrapper (DLSS Enabler v3.x)

## Overview

**File:** `_nvngx.dll`  
**Size:** 186 KB  
**Type:** NVSDK_NGX API wrapper  
**Version:** DLSS Enabler v3.x component  

A critical component for AMD/Intel GPU support. This DLL implements the NVIDIA GameWorks SDK (NGX) API, allowing non-NVIDIA GPUs to execute DLSS/DLSS-G calls by redirecting them to alternative upscalers and frame generation backends.

## Purpose

On AMD and Intel GPUs, games expect to call NVIDIA's proprietary `nvngx.dll` for DLSS features. Since these GPUs don't have native DLSS support, `_nvngx.dll` acts as a shim that:

1. Implements NVSDK_NGX API surface
2. Translates DLSS calls to FSR/XeSS equivalents
3. Provides compatibility layer for DLSS-G frame generation

## Exported Functions

### DirectX 11 API

```c
NVSDK_NGX_D3D11_Init
NVSDK_NGX_D3D11_Init_Ext
NVSDK_NGX_D3D11_Init_ProjectID
NVSDK_NGX_D3D11_Shutdown
NVSDK_NGX_D3D11_Shutdown1
NVSDK_NGX_D3D11_CreateFeature
NVSDK_NGX_D3D11_ReleaseFeature
NVSDK_NGX_D3D11_EvaluateFeature
NVSDK_NGX_D3D11_AllocateParameters
NVSDK_NGX_D3D11_DestroyParameters
NVSDK_NGX_D3D11_GetParameters
NVSDK_NGX_D3D11_GetCapabilityParameters
NVSDK_NGX_D3D11_GetFeatureRequirements
NVSDK_NGX_D3D11_GetScratchBufferSize
```

### DirectX 12 API

```c
NVSDK_NGX_D3D12_Init
NVSDK_NGX_D3D12_Init_Ext
NVSDK_NGX_D3D12_Init_ProjectID
NVSDK_NGX_D3D12_Shutdown
NVSDK_NGX_D3D12_Shutdown1
NVSDK_NGX_D3D12_CreateFeature
NVSDK_NGX_D3D12_ReleaseFeature
NVSDK_NGX_D3D12_EvaluateFeature
NVSDK_NGX_D3D12_AllocateParameters
NVSDK_NGX_D3D12_DestroyParameters
NVSDK_NGX_D3D12_GetParameters
NVSDK_NGX_D3D12_GetCapabilityParameters
NVSDK_NGX_D3D12_GetFeatureRequirements
NVSDK_NGX_D3D12_GetScratchBufferSize
```

### CUDA API

```c
NVSDK_NGX_CUDA_Init
NVSDK_NGX_CUDA_Init_Ext
NVSDK_NGX_CUDA_Init_ProjectID
NVSDK_NGX_CUDA_Shutdown
NVSDK_NGX_CUDA_CreateFeature
NVSDK_NGX_CUDA_ReleaseFeature
NVSDK_NGX_CUDA_EvaluateFeature
NVSDK_NGX_CUDA_AllocateParameters
NVSDK_NGX_CUDA_DestroyParameters
NVSDK_NGX_CUDA_GetParameters
NVSDK_NGX_CUDA_GetCapabilityParameters
NVSDK_NGX_CUDA_GetScratchBufferSize
```

### Vulkan API

```c
NVSDK_NGX_VULKAN_Init
NVSDK_NGX_VULKAN_Init_Ext
NVSDK_NGX_VULKAN_Init_Ext2
NVSDK_NGX_VULKAN_Shutdown
NVSDK_NGX_VULKAN_Shutdown1
NVSDK_NGX_VULKAN_CreateFeature
NVSDK_NGX_VULKAN_CreateFeature1
NVSDK_NGX_VULKAN_ReleaseFeature
NVSDK_NGX_VULKAN_EvaluateFeature
NVSDK_NGX_VULKAN_AllocateParameters
NVSDK_NGX_VULKAN_DestroyParameters
NVSDK_NGX_VULKAN_GetCapabilityParameters
NVSDK_NGX_VULKAN_GetScratchBufferSize
NVSDK_NGX_VULKAN_PopulateParameters_Impl
```

## How It Works

### Call Flow

```
Game calls DLSS
    ↓
NVSDK_NGX_D3D12_CreateFeature(DLSS_UPSCALER)
    ↓
_nvngx.dll receives call
    ↓
Maps DLSS to FSR 3.1 / XeSS
    ↓
Returns fake "DLSS feature" handle
    ↓
Game calls NVSDK_NGX_D3D12_EvaluateFeature
    ↓
_nvngx.dll executes FSR/XeSS upscaling
    ↓
Returns upscaled frame to game
```

### Feature Translation

| NVIDIA Feature | AMD/Intel Translation |
|----------------|----------------------|
| DLSS Upscaler | FSR 3.1 or XeSS |
| DLSS-G Frame Generation | FSR3 Frame Gen (via dlssg_to_fsr3) |
| DLSS Ray Reconstruction | Pass-through or disabled |

## Dependencies

### Loaded by

- `version.dll` (DLSS Enabler v4.0)
- Game engines looking for `nvngx.dll`

### Loads

- `nvapi64-proxy.dll` - For GPU spoofing
- Possibly `libxess.dll` or `amd_fidelityfx_*.dll` (not included in hybrid package)

## Naming Convention

The underscore prefix (`_nvngx.dll`) distinguishes this wrapper from:
- `nvngx.dll` - Real NVIDIA GameWorks SDK library
- `nvngx-wrapper.dll` - Additional wrapper layer (also in hybrid package)

## Configuration

No standalone config file. Behavior controlled by:
- Presence of `nvngx-wrapper.dll`
- Calls from `version.dll`
- Game's NGX API usage patterns

## Logging

Logs NGX API calls to:
- `nvngx.log` (in game directory)

Example log entries:
```
NVSDK_NGX_D3D12_Init: App ID: 12345
NVSDK_NGX_D3D12_CreateFeature: DLSS_UPSCALER requested
Feature handle created: 0xABCD1234
```

## Compatibility

### Supported GPUs

- AMD Radeon RX 5000 series and newer
- Intel Arc A-series
- Any GPU with DirectX 12 or Vulkan support

### Supported Upscalers

- AMD FSR 2.x / 3.x
- Intel XeSS
- (DLSS pass-through on NVIDIA, but defeats the purpose)

## Technical Details

### Size Justification

186 KB is relatively small because:
- No upscaling code (delegates to external backends)
- Thin wrapper around NGX API
- Minimal logic, mostly call translation

### Symbol Information

PDB file referenced:
```
nvngx.pdb
```

Build info:
- MSVC compiler
- Release build
- Export table fully populated

### Memory Layout

Exports approximately 80 functions across 4 graphics APIs (D3D11, D3D12, Vulkan, CUDA).

## Reverse Engineering Notes

### Key Strings

```
nvngx.dll
nvngx.pdb
DbgHelpCreateUserDump
DbgHelpCreateUserDumpW
InitializeCriticalSectionEx
```

### Function Naming Pattern

All exports follow NVIDIA's official NGX SDK naming:
```
NVSDK_NGX_{API}_{Function}
```

Where:
- `API` = D3D11, D3D12, VULKAN, CUDA
- `Function` = Init, CreateFeature, EvaluateFeature, etc.

### No Obfuscation

Clean export table, standard Windows DLL structure, no anti-debug or packing.

## Usage in Hybrid Installation

In the v3.x + v4.0 hybrid setup:

1. `version.dll` loads `_nvngx.dll` at runtime
2. Game calls DLSS API → `version.dll` → `_nvngx.dll`
3. `_nvngx.dll` translates to FSR/XeSS
4. Results returned through call chain

Required for AMD/Intel support. Without it, v4.0 cannot emulate NVIDIA features.

## Relationship to nvngx-wrapper.dll

`_nvngx.dll` and `nvngx-wrapper.dll` are similar (same size: 186 KB), but serve slightly different roles:
- `_nvngx.dll` - Primary NGX implementation
- `nvngx-wrapper.dll` - Additional wrapper layer (possibly for chaining or specific game compatibility)

Both are needed in the hybrid installation.

## Source Code

Part of DLSS Enabler v3.x:
https://github.com/artur-graniszewski/DLSS-Enabler

Source files likely:
- `nvngx_impl.cpp`
- `nvsdk_ngx_shims.cpp`

## Alternative: Native NVIDIA nvngx.dll

On NVIDIA GPUs, games use the real `nvngx.dll` from:
```
C:\Program Files\NVIDIA Corporation\Ansel\nvngx.dll
C:\Program Files\NVIDIA Corporation\NVIDIA NGX\nvngx.dll
```

Size: ~500 KB - 2 MB (much larger, contains actual DLSS implementation)
