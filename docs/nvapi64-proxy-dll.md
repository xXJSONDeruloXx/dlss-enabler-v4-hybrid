# nvapi64-proxy.dll - NVIDIA API Proxy with GPU Spoofing

## Overview

**File:** `nvapi64-proxy.dll`  
**Size:** 1.3 MB  
**Type:** NVIDIA API proxy and GPU identity spoofer  
**Version:** DLSS Enabler v3.x component  

The most critical component for making AMD/Intel GPUs appear as NVIDIA hardware. This DLL intercepts all NVIDIA-specific API calls (NvAPI) and provides fake responses that make games believe they're running on an NVIDIA GeForce RTX GPU.

## Purpose

Games with DLSS/DLSS-G support perform GPU capability checks using NVIDIA's proprietary NvAPI. Without proper responses, they refuse to enable DLSS features. This proxy:

1. Implements complete NvAPI interface
2. Spoofs GPU VendorID and DeviceID
3. Emulates NVIDIA driver version
4. Provides fake GPU capabilities
5. Translates NVIDIA-specific extensions to generic DirectX/Vulkan calls

## Core Functionality

### GPU Identity Spoofing

Default spoof target:
```
VendorID: 0x10DE (NVIDIA Corporation)
DeviceID: 0x2684 (GeForce RTX 4090)
GPU Name: "NVIDIA GeForce RTX 4090"
Architecture: Ada Lovelace
CUDA Cores: 16384
```

Adjustable via configuration to spoof different NVIDIA GPUs.

### NvAPI Function Groups

#### System Information
```c
NvAPI_Initialize
NvAPI_GetInterfaceVersionString
NvAPI_GetErrorMessage
NvAPI_SYS_GetDisplayDriverInfo
NvAPI_SYS_GetDriverAndBranchVersion
NvAPI_QueryInterface
```

#### GPU Enumeration
```c
NvAPI_EnumPhysicalGPUs
NvAPI_EnumLogicalGPUs
NvAPI_EnumNvidiaDisplayHandle
NvAPI_GetLogicalGPUFromPhysicalGPU
NvAPI_GetPhysicalGPUFromGPUID
NvAPI_GetGPUIDfromPhysicalGPU
```

#### GPU Properties
```c
NvAPI_GPU_GetArchInfo
NvAPI_GPU_GetPCIIdentifiers
NvAPI_GPU_GetFullName
NvAPI_GPU_GetGpuCoreCount
NvAPI_GPU_GetAllClockFrequencies
NvAPI_GPU_GetLogicalGpuInfo
NvAPI_GPU_GetConnectedDisplayIds
NvAPI_GPU_GetAdapterIdFromPhysicalGpu
```

#### CUDA Support
```c
NvAPI_GPU_CudaEnumComputeCapableGpus
```

#### Display Management
```c
NvAPI_DISP_GetDisplayIdByDisplayName
NvAPI_DISP_GetGDIPrimaryDisplayId
NvAPI_Disp_SetOutputMode
NvAPI_Disp_GetOutputMode
NvAPI_Mosaic_GetDisplayViewportsByResolution
NvAPI_SYS_GetDisplayIdFromGpuAndOutputId
NvAPI_SYS_GetGpuAndOutputIdFromDisplayId
```

#### DirectX Integration
```c
NvAPI_D3D_SetResourceHint
NvAPI_D3D_GetObjectHandleForResource
NvAPI_D3D_GetSleepStatus
NvAPI_D3D_GetLatency
NvAPI_D3D_SetSleepMode
NvAPI_D3D_SetLatencyMarker
NvAPI_D3D_Sleep
```

#### DirectX 11 Extensions
```c
NvAPI_D3D11_IsNvShaderExtnOpCodeSupported
NvAPI_D3D11_BeginUAVOverlap
NvAPI_D3D11_EndUAVOverlap
NvAPI_D3D11_SetDepthBoundsTest
```

#### DirectX 12 Extensions
```c
NvAPI_D3D12_GetRaytracingCaps
NvAPI_D3D12_IsNvShaderExtnOpCodeSupported
NvAPI_D3D12_SetNvShaderExtnSlotSpaceLocalThread
NvAPI_D3D12_GetRaytracingAccelerationStructurePrebuildInfoEx
NvAPI_D3D12_BuildRaytracingAccelerationStructureEx
NvAPI_D3D12_NotifyOutOfBandCommandQueue
NvAPI_D3D12_SetAsyncFrameMarker
```

#### Driver Settings
```c
NvAPI_DRS_CreateSession
```

## How It Works

### Initialization Sequence

```
Game startup
    ↓
LoadLibrary("nvapi64.dll") [hooked]
    ↓
Returns nvapi64-proxy.dll
    ↓
NvAPI_Initialize called
    ↓
Proxy detects real GPU (AMD/Intel)
    ↓
Sets up spoof data (RTX 4090)
    ↓
Returns NVAPI_OK
```

### GPU Query Example

```
Game: NvAPI_EnumPhysicalGPUs(&gpuList, &count)
    ↓
Proxy: Returns fake GPU handle (0xDEADBEEF)
    ↓
Game: NvAPI_GPU_GetFullName(handle, name)
    ↓
Proxy: Returns "NVIDIA GeForce RTX 4090"
    ↓
Game: NvAPI_GPU_GetArchInfo(handle, &arch)
    ↓
Proxy: Returns NV_GPU_ARCH_AD100 (Ada Lovelace)
    ↓
Game: Enables DLSS features
```

### VendorID/DeviceID Injection

Hooks into:
- DXGI: `IDXGIAdapter::GetDesc()`
- DirectX: `D3DKMTQueryAdapterInfo`
- Vulkan: `vkGetPhysicalDeviceProperties`

Replaces real values:
```
Real AMD GPU:
  VendorID: 0x1002
  DeviceID: 0x73FF (RX 6800 XT)

Spoofed:
  VendorID: 0x10DE
  DeviceID: 0x2684 (RTX 4090)
```

## Logging

Generates detailed logs:
- `fakenvapi.log` (in game directory)

Log format:
```
[NvAPI_Initialize] Called
[NvAPI_EnumPhysicalGPUs] Returning 1 GPU
[NvAPI_GPU_GetFullName] GPU 0: NVIDIA GeForce RTX 4090
[NvAPI_GPU_GetPCIIdentifiers] VendorID: 0x10DE, DeviceID: 0x2684
```

## Configuration

No standalone config file in v3.x. Spoof target likely hardcoded or controlled by other components.

Possible override methods:
- Environment variables
- Registry keys
- Config file in game directory

## Technical Details

### Size Analysis

1.3 MB is substantial for a proxy DLL. Contains:
- Complete NvAPI function table (~100+ functions)
- GPU capability database
- Driver version spoofing logic
- DirectX/Vulkan extension translation
- Error message strings

### Driver Version Spoofing

Returns fake NVIDIA driver version:
```
Driver Version: 560.81 (or latest stable)
Branch: r560_00
```

Games check driver version to determine DLSS support availability.

### CUDA Capability Emulation

For games checking CUDA support:
```
CUDA Compute Capability: 8.9 (Ada Lovelace)
CUDA Cores: 16384
SM Count: 128
```

### Memory Reporting

Returns fake VRAM amounts:
```
Dedicated Video Memory: 24 GB (RTX 4090 standard)
```

Actual AMD/Intel VRAM values hidden.

## Compatibility

### Supported Real GPUs

Any GPU with DirectX 12 or Vulkan support:
- AMD Radeon RX 5000+
- Intel Arc A-series
- Even older GPUs (though DLSS performance may suffer)

### Game Compatibility

Works with games performing:
- NvAPI GPU enumeration
- DLSS capability checks
- NVIDIA driver version checks
- GPU architecture queries

Known working games:
- Cyberpunk 2077
- Spider-Man Remastered
- Portal RTX
- Alan Wake 2
- Any Unreal Engine 5 game with DLSS

## Reverse Engineering Notes

### Key Strings

```
"RTX 4090"
"NvAPI_QueryInterface (0x{:x}): Unknown interface ID"
"NvAPI_Initialize"
"NvAPI_GetInterfaceVersionString"
```

### Export Table

Approximately 50+ exported NvAPI functions visible in DLL export table.

Additional functions accessed via `NvAPI_QueryInterface` (function ID lookup):
```c
NvAPI_QueryInterface(0x0150E828); // NvAPI_GetGPUArchInfo
```

### No Obfuscation

Standard Windows DLL structure. Export names visible. Some internal functions accessed by ID for obfuscation resistance.

## Usage in Hybrid Installation

Critical for AMD/Intel support:

1. `version.dll` loads `nvapi64-proxy.dll`
2. Game calls NvAPI functions
3. Proxy spoofs NVIDIA GPU identity
4. Game enables DLSS features
5. Calls routed to `_nvngx.dll` for actual upscaling

Without this proxy, games refuse to enable DLSS on non-NVIDIA hardware.

## Relationship to Real nvapi64.dll

| Real NVIDIA nvapi64.dll | nvapi64-proxy.dll |
|------------------------|-------------------|
| Size: ~800 KB | Size: 1.3 MB |
| Talks to NVIDIA driver | Emulates driver responses |
| Windows system directory | Game directory |
| Real GPU queries | Fake GPU responses |

## Known Limitations

### NVIDIA-Exclusive Features

Cannot emulate:
- NVIDIA Reflex (low latency mode)
- NVIDIA Broadcast (AI noise removal)
- NVIDIA Ansel (photo mode)
- Ray tracing optimizations (DXR falls back to standard)

Games requesting these features receive "not supported" responses.

### Performance Disclaimers

Spoofing RTX 4090 doesn't magically give RTX 4090 performance. DLSS upscaling runs via FSR/XeSS, which may be:
- Slightly slower than native DLSS
- Different quality characteristics
- Fewer optimization passes

## Security Considerations

This DLL performs deep API hooking and spoofing. Some anti-cheat systems may flag it:
- Easy Anti-Cheat
- BattlEye
- Vanguard (Valorant)

DO NOT use in multiplayer games with anti-cheat. Risk of ban.

## Source Code

Part of DLSS Enabler v3.x:
https://github.com/artur-graniszewski/DLSS-Enabler

Likely source files:
- `nvapi_proxy.cpp`
- `nvapi_spoof.cpp`
- `gpu_identity.cpp`

## Alternative: dxvk-nvapi

For Linux/Proton users, an alternative to nvapi64-proxy.dll:
https://github.com/jp7677/dxvk-nvapi

Provides similar NvAPI translation layer for Wine/Proton environments.
