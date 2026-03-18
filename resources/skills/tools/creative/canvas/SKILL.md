# Canvas & 2D Graphics

<!-- category: template -->

## Overview

High-performance 2D rendering with HTML Canvas, covering animation loops,
HiDPI displays, React integration, and when to choose Canvas over SVG.

## When to Use Canvas vs SVG

- **Canvas**: Large number of objects (>1000), pixel manipulation, games, real-time visualization
- **SVG**: Interactive charts with <500 elements, accessibility needs, CSS styling, DOM events per element

## HiDPI / Retina Setup

```typescript
function setupHiDPICanvas(canvas: HTMLCanvasElement, width: number, height: number) {
  const dpr = window.devicePixelRatio || 1;
  canvas.width = width * dpr;
  canvas.height = height * dpr;
  canvas.style.width = `${width}px`;
  canvas.style.height = `${height}px`;
  const ctx = canvas.getContext('2d')!;
  ctx.scale(dpr, dpr);
  return ctx;
}
```

## Animation Loop

```typescript
let animationId: number;

function animate(timestamp: DOMHighResTimeStamp) {
  // Clear previous frame
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  // Draw scene
  update(timestamp);
  render(ctx);

  animationId = requestAnimationFrame(animate);
}

// Start
animationId = requestAnimationFrame(animate);

// Stop — always cancel to avoid leaks
cancelAnimationFrame(animationId);
```

## OffscreenCanvas (Web Worker)

- Use `canvas.transferControlToOffscreen()` to hand canvas to a Web Worker
- Worker renders independently, keeping the main thread free for interaction
- Transfer the `OffscreenCanvas` via `postMessage` with transferable

## React Integration

```tsx
function CanvasComponent({ draw }: { draw: (ctx: CanvasRenderingContext2D) => void }) {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current!;
    const ctx = setupHiDPICanvas(canvas, canvas.clientWidth, canvas.clientHeight);
    let id = requestAnimationFrame(function loop() {
      draw(ctx);
      id = requestAnimationFrame(loop);
    });
    return () => cancelAnimationFrame(id);
  }, [draw]);

  return <canvas ref={canvasRef} style={{ width: '100%', height: '100%' }} />;
}
```

## Hit Testing

- Maintain a spatial data structure (quadtree, grid) for point-in-region queries
- Use `ctx.isPointInPath(path, x, y)` for complex shapes
- Convert mouse coordinates: subtract `canvas.getBoundingClientRect()` offsets

## Performance Checklist

- Batch draw calls; minimize state changes (`fillStyle`, `strokeStyle`)
- Use `ctx.save()`/`ctx.restore()` sparingly — prefer explicit resets
- Layer static content on a separate canvas underneath animated content
- Pre-render complex shapes to an offscreen canvas, then `drawImage()` them
- Avoid `getImageData()`/`putImageData()` in hot loops
- Profile with Chrome DevTools > Performance > Frames panel

## Accessibility

- Canvas is invisible to screen readers; provide `<div role="img" aria-label="...">` or hidden table
- For interactive canvases, implement keyboard navigation and ARIA live regions

## Common Pitfalls

- Forgetting `devicePixelRatio` causes blurry rendering on HiDPI screens
- Not cancelling `requestAnimationFrame` on unmount causes memory leaks
- Setting canvas size only via CSS (not `width`/`height` attributes) causes scaling artifacts
