# Data Visualization

<!-- category: template -->

## Overview

Build accessible, responsive, and performant data visualizations for the web.

## Library

[FILL: D3 / Observable Plot / Recharts / ECharts / Visx]

### Selection Guidance

| Library         | Best For                        | SSR | Bundle  |
|-----------------|---------------------------------|-----|---------|
| D3              | Full control, custom viz        | Yes | Modular |
| Observable Plot | Exploratory, concise API        | Yes | Small   |
| Recharts        | Standard React charts quickly   | Yes | Medium  |
| ECharts         | Dashboards, large datasets      | Yes | Large   |
| Visx            | Custom React + D3 primitives    | Yes | Modular |

## Responsive Charts

```typescript
// Use ResizeObserver — not window resize — for container-aware sizing
const observer = new ResizeObserver(([entry]) => {
  const { width, height } = entry.contentRect;
  updateChartDimensions(width, height);
});
observer.observe(containerRef.current!);

// Cleanup
return () => observer.disconnect();
```

- Always derive dimensions from the container, never hardcode pixel sizes
- Debounce resize handlers if redraw is expensive (>16ms)

## Accessibility (WCAG 2.1 AA)

- Provide `<title>` and `<desc>` elements inside SVG charts
- Use patterns, shapes, and labels in addition to color to encode data
- Ensure color contrast ratio >= 4.5:1 for text, >= 3:1 for graphical objects
- Add `role="img"` and `aria-label` to chart containers
- Provide a data table alternative (visible or screen-reader-only)
- Support keyboard focus for interactive elements (`tabindex`, arrow-key nav)

## Color Palettes

- Use colorblind-safe palettes: d3-scale-chromatic (`schemeTableau10`, `schemeObservable10`)
- For sequential data: single-hue gradient (e.g., `interpolateBlues`)
- For diverging data: two-hue gradient with neutral midpoint
- For categorical data: max 8-10 distinct hues; beyond that, use labels/patterns
- Test with a colorblindness simulator (e.g., Sim Daltonism, Coblis)

## SSR / Static Rendering

```typescript
// D3 + JSDOM for server-side SVG generation
import { JSDOM } from 'jsdom';
import * as d3 from 'd3';

const dom = new JSDOM('<!DOCTYPE html><body></body>');
const svg = d3.select(dom.window.document.body)
  .append('svg')
  .attr('xmlns', 'http://www.w3.org/2000/svg')
  .attr('viewBox', '0 0 800 400');

// ... build chart ...
const svgString = dom.window.document.body.innerHTML;
```

- For Next.js/Remix: render chart SVG on the server, hydrate interactivity on client
- Export static SVG/PNG for emails and reports

## Real-Time Data Updates

- Use enter/update/exit pattern (D3) or key-based reconciliation (React)
- Animate transitions (300-500ms) so users can track changes
- For streaming data (>1 update/sec): batch updates per animation frame
- Use a sliding window or circular buffer to bound memory

## Performance Tips

- Canvas for >5,000 data points; SVG for <5,000
- Virtualize off-screen elements in scrollable dashboards
- Use `will-change: transform` on animated SVG groups sparingly
- Pre-aggregate data server-side; avoid sending raw rows to the client

## Common Pitfalls

- Truncating axes without indicating breaks misleads users
- Pie charts are hard to read — prefer bar charts for comparisons
- Dual Y-axes create false correlations; use small multiples instead
- Missing zero-baseline on bar charts exaggerates differences
