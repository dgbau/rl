# WebGPU

<!-- category: template -->

## Overview

Modern GPU programming on the web using WebGPU and WGSL, covering render pipelines, compute pipelines, progressive enhancement, and the growing ecosystem of non-graphics GPU computing in the browser.
[FILL: How WebGPU is used in THIS project — rendering, compute, ML inference, or combination]

## Device Initialization

```typescript
async function initWebGPU(canvas?: HTMLCanvasElement) {
  if (!navigator.gpu) throw new Error('WebGPU not supported');
  const adapter = await navigator.gpu.requestAdapter();
  if (!adapter) throw new Error('No GPU adapter found');
  const device = await adapter.requestDevice();

  // Canvas context only needed for rendering — compute-only apps skip this
  if (canvas) {
    const context = canvas.getContext('webgpu')!;
    context.configure({ device, format: navigator.gpu.getPreferredCanvasFormat(), alphaMode: 'premultiplied' });
    return { device, context, adapter };
  }
  return { device, adapter };
}
```

## WGSL Shaders

### Render shader (vertex + fragment)
```wgsl
struct VertexOutput {
  @builtin(position) position: vec4f,
  @location(0) color: vec3f,
};

@vertex fn vs(@location(0) pos: vec3f, @location(1) color: vec3f) -> VertexOutput {
  var out: VertexOutput;
  out.position = vec4f(pos, 1.0);
  out.color = color;
  return out;
}

@fragment fn fs(in: VertexOutput) -> @location(0) vec4f {
  return vec4f(in.color, 1.0);
}
```

### Compute shader
```wgsl
@group(0) @binding(0) var<storage, read_write> data: array<f32>;

@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) id: vec3u) {
  let i = id.x;
  if (i >= arrayLength(&data)) { return; }
  data[i] = data[i] * 2.0;  // parallel operation on every element
}
```

## Compute Pipeline

```typescript
const computePipeline = device.createComputePipeline({
  layout: 'auto',
  compute: {
    module: device.createShaderModule({ code: computeShaderWGSL }),
    entryPoint: 'main',
  },
});

const encoder = device.createCommandEncoder();
const pass = encoder.beginComputePass();
pass.setPipeline(computePipeline);
pass.setBindGroup(0, bindGroup);
pass.dispatchWorkgroups(Math.ceil(dataSize / 64));
pass.end();
device.queue.submit([encoder.finish()]);
```

- Compute shaders run parallel workgroups; choose workgroup size (64/128/256) based on hardware
- Use `storage` buffers for read/write data, `uniform` buffers for constants
- No canvas or rendering needed — compute is fully independent of the graphics pipeline

## Non-Graphics Compute Applications

WebGPU's compute shaders enable GPU-accelerated parallel computation without drawing a single pixel. This is a rapidly growing area.

### ML / AI Inference in the Browser
Run trained models entirely client-side — no server round-trip, full data privacy:
- **Transformers.js** (Hugging Face): 100+ model architectures; `device: 'webgpu'` enables GPU acceleration
- **ONNX Runtime Web** (Microsoft): WebGPU backend achieves 19x speedup over WASM for Segment Anything encoder
- **MediaPipe** (Google): Powers Google Meet background blur/segmentation client-side
- **WebLLM** (MLC-AI): Runs LLMs in-browser — Llama-3.1-8B at ~41 tokens/second (~80% of native speed)
- **Whisper WebGPU**: Real-time speech recognition in 100 languages, fully local
- **Web Stable Diffusion**: Image generation entirely in-browser, sub-second with SD Turbo on high-end GPUs
- [FILL: Which ML/AI frameworks are used in this project, if any]

### Zero-Knowledge Proofs & Cryptography
Accelerate ZK proof generation, hashing, and elliptic curve operations client-side:
- **MSM (Multi-Scalar Multiplication)**: Penumbra Labs built a WebGPU Groth16 prover for client-side ZK proofs
- **STARK proving**: zkSecurity achieved 5x speedup on constraint polynomial evaluation via compute shaders
- **SHA-256 hashing**: Parallel GPU hashing implementations in WGSL
- **Limitation**: WGSL has no native 64-bit integers — large field elements must be decomposed into 32-bit limbs

### Physics Simulation & Fluid Dynamics
- **MLS-MPM fluid simulation**: ~100K particles on integrated GPU, ~300K on discrete GPU in real-time
- **N-body simulations**: Gravitational/particle simulations via compute shaders
- **Collision detection**: All-pairs collision for 14K bodies in 16ms on M1 MacBook Air (Surma's demo)

### Data Processing & Analytics
- **GPU radix sort**: Parallel sorting of large datasets via workgroup shared memory and prefix sums
- **Monte Carlo simulation**: 4x speedup over single-threaded CPU for financial modeling (500K iterations)
- **GPU-accelerated databases**: Trueno-DB claims 50-100x for analytics workloads via WebGPU
- **Parallel filtering/aggregation**: Any embarrassingly parallel data operation benefits

### Audio & Signal Processing
- **GPU-accelerated FFT**: Fast Fourier Transform for spectral analysis, ocean simulation
- **Real-time audio synthesis**: WebGPU + WebAudio API for parallel audio processing
- **Beat detection**: FFT-based analysis for music-reactive applications

### Video & Image Processing
- **WebCodecs + WebGPU pipeline**: Decode frames (WebCodecs) → process on GPU (WebGPU) → re-encode
- **Background segmentation**: Google Meet's background blur uses this pipeline
- **GPU-resident processing**: Frames stay on GPU, avoiding costly CPU-GPU transfers

### Procedural Generation
- **Terrain generation**: Perlin/Simplex/Worley noise evaluation at millions of points per frame
- **Texture synthesis**: Real-time procedural textures via compute shaders
- **Voxel generation**: Volumetric terrain and world generation

## Progressive Enhancement

```typescript
async function getRenderer(canvas: HTMLCanvasElement) {
  if (navigator.gpu) {
    try { return await initWebGPURenderer(canvas); } catch {}
  }
  const gl = canvas.getContext('webgl2');
  if (gl) return initWebGL2Renderer(gl);
  return initCanvas2DRenderer(canvas.getContext('2d')!);
}
```

- Feature-detect `navigator.gpu` — do not assume availability
- As of early 2026: Chrome (since 2023), Firefox 141+ (July 2025), Safari 26+ (September 2025)
- ~65% of users have WebGPU support; always provide fallback for the rest
- [FILL: Fallback strategy for this project]

## Buffer Management

- Create buffers with `device.createBuffer({ size, usage })` and write via `device.queue.writeBuffer()`
- Reuse buffers across frames; avoid creating/destroying per frame
- Use `GPUBufferUsage.COPY_DST` for CPU-updated data; staging buffers with `mapAsync` for readback
- **Minimize CPU-GPU transfers**: Keep data GPU-resident where possible; transfer overhead can eclipse compute gains for small inputs

## Device Loss & Resource Cleanup

- Handle `device.lost` promise: reinitialize if `reason !== 'destroyed'`
- Store source data in CPU memory so it can be re-uploaded after device loss
- Call `.destroy()` on buffers, textures, query sets when no longer needed
- Unconfigure canvas context on unmount; in React, cleanup in `useEffect` return

## WGSL Limitations to Know

- **No 64-bit integers**: Large numbers must be decomposed into 32-bit limbs (impacts cryptography, scientific computing)
- **No dynamic workgroup sizes**: Workgroup size must be compile-time constant
- **No recursion**: Loops must have statically analyzable bounds
- **Limited atomic operations**: `atomicAdd`, `atomicMax`, etc. on `atomic<u32>` / `atomic<i32>` only
- **Shader compilation time**: Can exceed computation time for complex shaders; cache compiled pipelines

## Performance

- Use `GPUComputePassTimestampWrites` / `GPURenderPassTimestampWrites` for GPU timing
- Chrome DevTools > Performance panel shows GPU tasks
- Minimize pipeline switches within a render pass
- Batch draw calls; use instanced rendering for repeated geometry
- Avoid excessive `mapAsync` calls; they stall the pipeline
- Profile before optimizing — CPU-GPU synchronization is often the real bottleneck, not compute

## Cross-Platform via wgpu

WebGPU's API has been adopted as a native cross-platform GPU abstraction via **wgpu** (Rust). Code targeting WebGPU can run natively on Vulkan, Metal, and DirectX 12 — making WebGPU skills applicable beyond the browser.

## Where to Look

- Spec: https://www.w3.org/TR/webgpu/
- WGSL spec: https://www.w3.org/TR/WGSL/
- WebGPU samples: https://webgpu.github.io/webgpu-samples/
- WebLLM: https://webllm.mlc.ai/
- Transformers.js: https://huggingface.co/docs/transformers.js/
- ONNX Runtime Web: https://onnxruntime.ai/docs/tutorials/web/
- wgpu (Rust): https://wgpu.rs/
- [FILL: Project-specific WebGPU resources]

## Common Pitfalls

- Assuming WebGPU is universally available — always feature-detect and provide fallback
- CPU-GPU data transfer overhead eclipsing compute gains for small workloads — batch operations
- Shader compilation stalls on first use — pre-compile pipelines during initialization
- GPU memory limits: browser tabs typically get 1-4GB VRAM; large ML models require quantization
- Cross-browser gaps: Firefox `importExternalTexture` for video frames not yet stable
- [FILL: Project-specific gotchas]
