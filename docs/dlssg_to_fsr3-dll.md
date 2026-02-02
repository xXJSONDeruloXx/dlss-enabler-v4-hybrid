# dlssg_to_fsr3_amd_is_better.dll - FSR3 Frame Generation Backend

## Overview

**File:** `dlssg_to_fsr3_amd_is_better.dll`  
**Size:** 2.9 MB  
**Type:** Frame generation engine (DLSS-G to FSR3 translator)  
**Author:** Nukem9  
**Version:** 0.100 (bundled with DLSS Enabler v3.x)  

The core frame generation engine that replaces NVIDIA's proprietary DLSS-G (Deep Learning Super Sampling - Frame Generation) with AMD's open FSR 3.1 frame interpolation. This is what actually generates the extra frames between real rendered frames.

## Purpose

DLSS-G is NVIDIA's AI-accelerated frame generation technology (2x frame rate boost). It requires:
- RTX 40-series GPU (Ada Lovelace architecture)
- Optical Flow Accelerator hardware
- NVIDIA driver support

FSR3 Frame Generation provides similar functionality:
- Works on any GPU (AMD, NVIDIA, Intel)
- Software-based optical flow
- Multi-frame generation (2x, 3x, 4x)
- Open-source AMD FidelityFX SDK

This DLL intercepts DLSS-G calls and routes them to FSR3.

## Architecture

### Frame Interpolation Pipeline

```
Game renders Frame N
    ↓
DLSS-G enabled → intercept
    ↓
FSR3 FrameInterpolator
    ↓
Analyze motion vectors
    ↓
Generate interpolated frame(s)
    ↓
Output Frame N, N+0.5 [, N+0.33, N+0.66] (2x/3x/4x)
    ↓
Present to display
```

### Key Components

1. **FFFrameInterpolator** - Core frame generation class
2. **FFFrameInterpolatorDX** - DirectX implementation
3. **FFFrameInterpolatorVK** - Vulkan implementation
4. **FrameInterpolationCounters** - Performance metrics
5. **FfxFrameInterpolationDebugViewport** - Debug visualization

## Exported Functions

No traditional export table. Loaded dynamically by `version.dll` / `_nvngx.dll` and called via internal interfaces.

## Key Features

### 1. Multi-Frame Generation

Standard DLSS-G: 2x mode only (1 interpolated frame)

FSR3 in this DLL: Supports multiple modes
- **2x mode** - 1 interpolated frame (60 FPS → 120 FPS)
- **3x mode** - 2 interpolated frames (60 FPS → 180 FPS)
- **4x mode** - 3 interpolated frames (60 FPS → 240 FPS)

Frame placement:
```
2x: [Real, Interpolated, Real, Interpolated, ...]
3x: [Real, Int1, Int2, Real, Int1, Int2, ...]
4x: [Real, Int1, Int2, Int3, Real, Int1, Int2, Int3, ...]
```

### 2. Optical Flow Analysis

Software-based motion vector analysis:
- Pixel motion tracking between frames
- Object velocity estimation
- Occlusion detection
- Disocclusion handling

Parameters:
```
minInterpolationOffset
maxInterpolationOffset
subPixelInterpolationOffsetBits
```

### 3. AMD GPU Optimizations

Specific AMD extensions used:
```
vkCmdWriteBufferMarkerAMD
vkCmdWriteBufferMarker2AMD
VK_AMD_device_coherent_memory
VK_AMD_buffer_marker
```

Likely provides better performance on AMD hardware through direct memory access and efficient command buffer markers.

### 4. Debug Viewport

Visualization modes:
- Motion vector overlay
- Interpolation confidence heatmap
- Frame timing graph
- Artifact detection overlay

Accessed via in-game overlay menu (`` ` `` key).

## Technical Details

### Frame Interpolation Algorithm

1. **Motion Vector Extraction** - Uses game's native motion vectors or derives from depth buffer
2. **Optical Flow Computation** - Calculates per-pixel motion between frames
3. **Interpolation Weight Calculation** - Determines confidence for each interpolated pixel
4. **Color Interpolation** - Blends pixels based on motion and confidence
5. **Artifact Mitigation** - Detects and corrects ghosting/judder

### Interpolation Quality Modes

Configurable tradeoff between quality and performance:
- **Low** - Fast interpolation, more artifacts
- **Medium** - Balanced (default)
- **High** - Slower but cleaner output
- **Ultra** - Maximum quality, highest overhead

### Performance Overhead

Approximate frame time cost:
- 2x mode: ~2-3 ms
- 3x mode: ~3-5 ms
- 4x mode: ~4-8 ms

Scales with resolution and complexity.

### Memory Requirements

Additional VRAM usage:
- Motion vector buffers: ~50 MB (4K)
- Interpolated frame buffers: ~100 MB per interpolated frame
- Total: ~200-400 MB depending on mode and resolution

## Configuration

### Config File

Optional `dlssg_to_fsr3.ini` in game directory:

```ini
[FrameGeneration]
Enabled = true
Mode = 2  ; 2x/3x/4x
Quality = Medium

[Debug]
ShowMotionVectors = false
ShowInterpolationConfidence = false
Logging = true
```

### Runtime Configuration

Accessible via DLSS Enabler overlay menu:
- Frame generation enable/disable
- Mode selection (2x/3x/4x)
- Quality preset
- Debug visualizations

## Logging

Generates detailed logs:
- `dlssg-to-fsr3.log` (in game directory)

Log format:
```
[Init] dlssg-to-fsr3 v0.100 loaded
[Info] AMD FSR 3.1 Frame Generation will replace DLSS-G
[Note] This does NOT represent a native implementation of AMD FSR 3.1
[FrameGen] Mode: 2x, Quality: Medium
[FrameGen] Motion vectors detected: Native
[Perf] Frame interpolation time: 2.3 ms
```

## Compatibility

### Supported Graphics APIs

- DirectX 11 (FFFrameInterpolatorDX)
- DirectX 12 (FFFrameInterpolatorDX)
- Vulkan (FFFrameInterpolatorVK)

### Supported GPUs

Any GPU with compute shader support:
- AMD Radeon RX 5000+ (best performance)
- NVIDIA GTX 1000+ / RTX series
- Intel Arc A-series

### Game Requirements

Games must provide:
- Motion vectors (native or derived)
- Depth buffer access
- Consistent frame pacing

Works best with:
- Native DLSS-G support (motion vectors already exposed)
- Temporal upscaling (TAA/DLSS/FSR)

## Known Issues

### 4x Mode Artifacts

- Ghosting in fast camera motion
- Temporal instability
- Recommended: Use 3x max for best quality

### Motion Vector Quality

- Games with poor native motion vectors produce worse interpolation
- Particle effects may ghost
- UI elements can flicker

### VRR/G-Sync/FreeSync

- Frame pacing may be inconsistent
- Use fixed refresh rate cap for best results

## Reverse Engineering Notes

### Class Structure

Major classes found:
```cpp
class FFFrameInterpolator {
  // Base class for frame interpolation
};

class FFFrameInterpolatorDX : public FFFrameInterpolator {
  // DirectX implementation
};

class FFFrameInterpolatorVK : public FFFrameInterpolator {
  // Vulkan implementation
};

struct FrameInterpolationCounters_t {
  uint32_t interpolatedFrames;
  uint32_t droppedFrames;
  float avgInterpolationTime;
};
```

### String Analysis

Key debug strings:
```
"dlssg-to-fsr3 v{}.{} loaded"
"AMD FSR 3.1 Frame Generation will replace Nvidia DLSS-G Frame Generation"
"Note this does NOT represent a native implementation of AMD FSR 3.1"
"DLSSG.OutputInterpolated"
"computeInterpolatedColor"
"minInterpolationOffset"
"maxInterpolationOffset"
```

### AMD-Specific Code Paths

Vulkan extension checks:
```
VK_AMD_device_coherent_memory
VK_AMD_buffer_marker
vkCmdWriteBufferMarkerAMD
```

Indicates optimized paths for AMD GPUs.

## Source Code

Open-source project by Nukem9:
https://github.com/Nukem9/dlssg-to-fsr3

Built on AMD FidelityFX SDK:
https://github.com/GPUOpen-Effects/FidelityFX-SDK

## Version History

**v0.100** (bundled with DLSS Enabler v3.x)
- Initial stable release
- 2x/3x/4x frame generation modes
- DirectX 11/12 and Vulkan support
- AMD GPU optimizations

**Earlier versions:**
- Experimental builds with 2x mode only
- DirectX 12 only

## Usage in Hybrid Installation

Critical for frame generation:

1. `version.dll` calls DLSS-G API
2. Intercept routed to `dlssg_to_fsr3_amd_is_better.dll`
3. FSR3 interpolates frames
4. Interpolated frames presented to display

Without this DLL, frame generation (DLSS-G) will not work.

## Comparison: DLSS-G vs FSR3 Frame Gen

| Feature | NVIDIA DLSS-G | FSR3 Frame Gen (this DLL) |
|---------|---------------|---------------------------|
| GPU Requirement | RTX 40-series only | Any DX12/Vulkan GPU |
| Frame Modes | 2x only | 2x, 3x, 4x |
| Optical Flow | Hardware OFA | Software compute |
| Latency | ~10-15 ms | ~15-25 ms |
| Quality | Excellent | Good to Very Good |
| Artifacts | Minimal | Moderate (especially 4x) |
| Open Source | No | Yes (AMD FidelityFX) |

## Performance Tips

1. **Use 3x mode max** - 4x produces too many artifacts
2. **Enable native motion vectors** - Much better than derived
3. **Cap frame rate** - Use fixed 120/144/180 Hz cap
4. **Disable VRR** - Frame pacing more consistent with fixed rate
5. **Quality: Medium** - Best balance for most games

## Troubleshooting

### Ghosting Issues
- Lower frame generation mode (4x → 3x → 2x)
- Increase quality setting
- Check if game has native motion vectors

### Low FPS Despite Frame Gen
- Frame generation doesn't help if GPU-bound
- Need at least 40-50 base FPS for good results
- Check base game performance first

### Stuttering
- Disable VRR
- Use fixed frame rate cap
- Check for shader compilation stutter

## Future Development

Nukem9 actively maintains the project. Potential improvements:
- Better artifact mitigation
- Lower latency
- More efficient compute shaders
- Game-specific profiles
