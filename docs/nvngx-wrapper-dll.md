# nvngx-wrapper.dll - Additional NGX Wrapper Layer

## Overview

**File:** `nvngx-wrapper.dll`  
**Size:** 186 KB  
**Type:** NVSDK_NGX API wrapper (secondary layer)  
**Version:** DLSS Enabler v3.x component  

An additional wrapper layer for NVSDK_NGX API, functionally similar to `_nvngx.dll`. Both DLLs are included in the hybrid installation, suggesting a layered or fallback architecture for maximum game compatibility.

## Purpose

Provides a secondary NGX API implementation layer. Likely used for:
1. Fallback when primary `_nvngx.dll` fails to load
2. Specific game compatibility (some games prefer different DLL names)
3. Call chaining between multiple NGX implementations
4. Redundancy in hooking infrastructure

## Exported Functions

Identical to `_nvngx.dll`:

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

## Relationship to _nvngx.dll

Both DLLs:
- Same size (186 KB)
- Same export table
- Same function signatures

Possible architectures:

### Theory 1: Fallback Chain
```
version.dll
    ↓
Tries to load nvngx-wrapper.dll
    ↓ (if fails)
Tries to load _nvngx.dll
    ↓ (if fails)
Tries to load system nvngx.dll
```

### Theory 2: Game-Specific Loading
```
Some games: LoadLibrary("nvngx-wrapper.dll")
Other games: LoadLibrary("_nvngx.dll")
```

### Theory 3: Call Chaining
```
version.dll → nvngx-wrapper.dll → _nvngx.dll → upscaler backend
```

Each layer adds specific compatibility fixes or transformations.

## Why Two Identical Wrappers?

### Hypothesis 1: Legacy Compatibility
Early DLSS Enabler versions may have used `nvngx-wrapper.dll`, later switched to `_nvngx.dll`. Both included for maximum compatibility with different game engine versions.

### Hypothesis 2: Load Order Control
Some games load DLLs in alphabetical order:
- `_nvngx.dll` (underscore sorts first)
- `nvngx-wrapper.dll` (sorts later)

Having both ensures one is loaded regardless of search order.

### Hypothesis 3: Redundancy
If one DLL fails to load (anti-cheat block, file corruption, permissions), the other serves as backup.

## Technical Details

### Identical Binary?

Likely NOT identical binaries, but functionally equivalent. Small differences possible:
- Build timestamps
- Debug symbols
- Internal string differences
- Minor code variations

### Symbol Information

PDB file referenced (same as _nvngx.dll):
```
nvngx.pdb
```

### Memory Footprint

186 KB in memory, same as `_nvngx.dll`. No significant overhead from having both.

## Logging

Uses same logging infrastructure:
- `nvngx.log` (shared with _nvngx.dll)

Log entries may indicate which wrapper was called:
```
[nvngx-wrapper] NVSDK_NGX_D3D12_Init called
[_nvngx] NVSDK_NGX_D3D12_CreateFeature called
```

Or they may be indistinguishable.

## Configuration

No standalone config. Behavior controlled by:
- DLSS Enabler main configuration
- Presence of other NGX DLLs
- Game's NGX API usage

## Compatibility

### Supported Games

Same as `_nvngx.dll`:
- Any game with DLSS support
- DirectX 11/12 or Vulkan
- Windows 7+

### Game Engine Compatibility

May provide specific fixes for:
- Unreal Engine 4/5
- Unity with HDRP
- Custom engines with unusual NGX usage

## Usage in Hybrid Installation

Always included alongside `_nvngx.dll`:

```
game/
├── version.dll (or other injection DLL)
├── _nvngx.dll ← Primary wrapper
├── nvngx-wrapper.dll ← Secondary wrapper
├── nvapi64-proxy.dll
├── dxgi.dll
└── dlssg_to_fsr3_amd_is_better.dll
```

Both copied by install script:
```bash
cp -v "$SCRIPT_DIR/_nvngx.dll" "$GAME_DIR/"
cp -v "$SCRIPT_DIR/nvngx-wrapper.dll" "$GAME_DIR/"
```

## Reverse Engineering Notes

### Exports Match Exactly

Both DLLs export the same ~80 functions. No differences in export table.

### Internal Differences

Without full disassembly, unclear if:
- Implementation differs
- Same source code, different builds
- One chains to the other

### Minimal Obfuscation

Standard Windows DLL. Clean export table. No packing.

## Performance Impact

Negligible. If both are loaded, small memory overhead (186 KB × 2 = 372 KB), but no runtime overhead unless both actively called.

## Source Code

Part of DLSS Enabler v3.x:
https://github.com/artur-graniszewski/DLSS-Enabler

Likely source files:
- `nvngx_wrapper.cpp`
- `nvngx_impl.cpp` (shared with _nvngx.dll)

## Known Issues

None specific to this component. Stable and compatible.

## Troubleshooting

### Conflicts

If game has issues with NGX wrappers:
1. Try removing `nvngx-wrapper.dll` (keep `_nvngx.dll`)
2. Try removing `_nvngx.dll` (keep `nvngx-wrapper.dll`)
3. Check logs to see which is actually being called

### Load Order

On Wine/Proton, ensure both are treated as native:
```bash
WINEDLLOVERRIDES="nvngx-wrapper=n;_nvngx=n;..."
```

Though typically not explicitly listed in overrides (loaded internally).

## Comparison: nvngx-wrapper.dll vs _nvngx.dll

| Feature | nvngx-wrapper.dll | _nvngx.dll |
|---------|-------------------|------------|
| Size | 186 KB | 186 KB |
| Exports | ~80 functions | ~80 functions |
| Purpose | Secondary wrapper | Primary wrapper |
| Required | Yes (for compatibility) | Yes (for AMD/Intel) |
| Load Priority | Uncertain | Uncertain |

## Is This DLL Necessary?

**Short answer:** Probably yes.

**Long answer:** Some games may only work with one or the other. Including both ensures maximum compatibility. The 186 KB overhead is trivial.

If disk space is critical, you could try removing `nvngx-wrapper.dll` and testing. Most games likely use `_nvngx.dll` primarily.

## Future Considerations

DLSS Enabler v4.0 may eventually consolidate these into a single wrapper, but for now, both are bundled in official distributions.

## Summary

A nearly identical companion to `_nvngx.dll`:
- Same size, same exports
- Purpose likely fallback or game-specific compatibility
- Always included in hybrid installation
- No known issues or conflicts
- Minimal overhead

Think of it as "NGX API wrapper, plan B" - there for when plan A (`_nvngx.dll`) doesn't work.
