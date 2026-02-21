# WebGPU

<!-- category: template -->

## Overview

Modern GPU programming on the web using WebGPU and WGSL, covering render and
compute pipelines, progressive enhancement, and resource management.

## Device Initialization

```typescript
async function initWebGPU(canvas: HTMLCanvasElement) {
  if (!navigator.gpu) throw new Error('WebGPU not supported');
  const adapter = await navigator.gpu.requestAdapter();
  if (!adapter) throw new Error('No GPU adapter found');
  const device = await adapter.requestDevice();
  const context = canvas.getContext('webgpu')!;
  context.configure({ device, format: navigator.gpu.getPreferredCanvasFormat(), alphaMode: 'premultiplied' });
  return { device, context };
}
```

## WGSL Shader Example

```wgsl
struct VertexOutput {
  @builtin(position) position: vec4f,
  @location(0) color: vec3f,
};

@vertex
fn vs_main(@location(0) pos: vec3f, @location(1) color: vec3f) -> VertexOutput {
  var out: VertexOutput;
  out.position = vec4f(pos, 1.0);
  out.color = color;
  return out;
}

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4f {
  return vec4f(in.color, 1.0);
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
pass.dispatchWorkgroups(Math.ceil(dataSize / 64)); // 64 = workgroup size
pass.end();
device.queue.submit([encoder.finish()]);
```

- Compute shaders run parallel workgroups; choose workgroup size (64/128/256) based on hardware
- Use storage buffers for read/write data, uniform buffers for constants

## Progressive Enhancement

```typescript
async function getRenderer(canvas: HTMLCanvasElement) {
  // Tier 1: WebGPU
  if (navigator.gpu) {
    try { return await initWebGPURenderer(canvas); } catch {}
  }
  // Tier 2: WebGL 2
  const gl = canvas.getContext('webgl2');
  if (gl) return initWebGL2Renderer(gl);
  // Tier 3: Canvas 2D
  return initCanvas2DRenderer(canvas.getContext('2d')!);
}
```

- Feature-detect `navigator.gpu` — do not assume availability
- WebGPU coverage is growing but not universal; always provide fallback

## Buffer Management

- Create buffers with `device.createBuffer({ size, usage })` and write via `device.queue.writeBuffer()`
- Reuse buffers; avoid creating/destroying per frame
- Use `GPUBufferUsage.COPY_DST` for CPU-updated data; staging buffers with `mapAsync` for readback

## Device Loss & Resource Cleanup

- Handle `device.lost` promise: reinitialize if `reason !== 'destroyed'`
- Store source data in CPU memory so it can be re-uploaded after device loss
- Call `.destroy()` on buffers, textures, query sets when no longer needed
- Unconfigure canvas context on unmount; in React, cleanup in `useEffect` return

## Performance Profiling

- Use `GPUComputePassTimestampWrites` / `GPURenderPassTimestampWrites` for GPU timing
- Chrome DevTools > Performance panel shows GPU tasks
- Minimize pipeline switches within a render pass
- Batch draw calls; use instanced rendering for repeated geometry
- Avoid excessive `mapAsync` calls; they stall the pipeline
- Keep shader complexity proportional to screen coverage (early-Z, discard)
