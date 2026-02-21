# Creative Coding (openFrameworks / Processing / p5.js)

<!-- category: template -->

## Overview

Patterns and best practices for creative coding — generative art, interactive installations, data visualization, audio-reactive visuals, and live performance using openFrameworks, Processing, and p5.js.
[FILL: What this project creates — generative art, installation, live visuals, data visualization, interactive experience]

## Project Configuration

- Framework: [FILL: openFrameworks / Processing / p5.js / combination]
- Version: [FILL: oF 0.12.x / Processing 4.x / p5.js 2.x]
- Renderer: [FILL: default, P2D, P3D, WEBGL, FX2D]
- Build system: [FILL: Xcode/VS/Make/CMake (oF), PDE (Processing), npm/CDN (p5.js)]
- Target: [FILL: desktop app, web, installation kiosk, mobile, projection]

## Framework Comparison

| Feature | openFrameworks | Processing | p5.js |
|---------|---------------|------------|-------|
| Language | C++ | Java | JavaScript |
| Performance | Highest | Medium | Medium (WebGL helps) |
| 3D | OpenGL direct | P3D (OpenGL) | WEBGL |
| Platform | Win/Mac/Linux/RPi/iOS/Android | Win/Mac/Linux | Any browser |
| Audio | ofSoundStream, addons | Minim, Sound | p5.sound |
| CV | ofxCv (OpenCV) | OpenCV library | ml5.js, MediaPipe |
| Shaders | GLSL via ofShader | GLSL via PShader | GLSL or p5.strands (JS) |
| Hardware | ofSerial (built-in) | Serial (built-in) | WebSerial / p5.serialport |
| Distribution | Native binary | Java app / export | Static web files |
| Best for | Installations, performance | Education, prototyping | Web, accessibility |

### openFrameworks (C++)
- Version 0.12.1 (May 2025), cross-platform native apps
- Project Generator for creating/updating projects with addons
- Core modules: ofGraphics, ofSound, ofVideo, of3d, ofMath, ofGL, ofSerial
- Addon ecosystem at [ofxaddons.com](https://ofxaddons.com)
- FBO workflow: `fbo.allocate()` → `fbo.begin()` → draw → `fbo.end()` → use texture
- Deploys to macOS, Windows, Linux, Raspberry Pi, iOS, Android

### Processing (Java)
- Version 4.5.2 (Jan 2026), Java 17+ based
- Renderers: JAVA2D (default/software), P2D (OpenGL 2D), P3D (OpenGL 3D), FX2D (JavaFX), PDF, SVG
- Modes: Java (default), Python (via py5), Android, p5.js export
- Export standalone apps for Win/Mac/Linux via File → Export Application
- Built-in PDF/SVG export for vector/print output

### p5.js (JavaScript)
- Version 2.2.1 (Feb 2026) — **p5.js 2.0 has breaking changes from 1.x**
- `preload()` removed (use Promises); array utilities removed (use native JS)
- New in 2.0: p5.strands (JS-authored shaders), OKLCH color mode, variable fonts, `textToContours()`
- Instance mode (recommended for embedding) vs global mode
- WebGL for 3D: `createCanvas(w, h, WEBGL)`
- Experimental WebGPU renderer in p5.js 2.2
- [p5.js Web Editor](https://editor.p5js.org/) for instant prototyping

## The Setup/Draw Loop

All three frameworks share the same fundamental pattern:

```
setup()  → runs once at startup (canvas size, load assets, initialize state)
draw()   → runs every frame (clear, compute, render)
```

- `frameRate(fps)` — target frame rate (default 60)
- `frameCount` — elapsed frames since start
- `noLoop()` / `loop()` — pause/resume the draw loop
- Frame timing: `deltaTime` (p5.js), `ofGetLastFrameTime()` (oF), `millis()` (all)

## 2D/3D Rendering

### Coordinate systems
- 2D: origin at top-left, Y-axis points down
- 3D/WebGL: origin at center, Y-axis points up (p5.js WEBGL) or down (oF, Processing P3D)

### Transformation stack
```
push()          // save current matrix state
  translate()   // move origin
  rotate()      // rotate around origin
  scale()       // scale from origin
  // draw here — transformations compose
pop()           // restore previous state
```

- oF: `ofPushMatrix()` / `ofPopMatrix()`, `ofTranslate()`, `ofRotate()`, `ofScale()`
- Processing/p5.js: `pushMatrix()`/`popMatrix()` or `push()`/`pop()`

### Shaders (GLSL)
- oF: `ofShader` with `shader.load("shader.vert", "shader.frag")`
- Processing: `PShader` with `loadShader("frag.glsl", "vert.glsl")`
- p5.js: `createShader()` / `loadShader()`, or **p5.strands** (write shaders in JS, portable across WebGL/WebGPU)
- Common uses: post-processing, generative patterns, ray marching, SDFs
- Ping-pong FBOs for multi-pass effects (blur, reaction-diffusion, fluid simulation)

## Generative Algorithms

### Noise and randomness
- **Perlin noise**: `noise(x, y, z)` (Processing/p5.js), `ofNoise(x, y, z)` (oF)
- **Simplex noise**: via libraries (OpenSimplex, FastNoise)
- `noiseSeed(seed)` / `randomSeed(seed)` — deterministic output for reproducible art
- `noiseDetail(octaves, falloff)` — controls complexity
- `randomGaussian()` — bell-curve distribution for natural variation

### Common generative techniques
| Technique | Description | Implementation |
|-----------|-------------|----------------|
| **Flow fields** | Grid of direction vectors (noise-driven), particles follow | 2D/3D noise → angle → velocity |
| **Particle systems** | Emit, move, age, die; forces (gravity, attraction) | Array of particles with position/velocity/lifespan |
| **Flocking (Boids)** | Separation + alignment + cohesion | Craig Reynolds' rules, spatial partitioning for performance |
| **L-systems** | String rewriting + turtle graphics | Axiom + rules → branching structures (plants, trees) |
| **Cellular automata** | Grid cells with neighbor rules | Game of Life, Wolfram rules, GPU via ping-pong FBOs |
| **Reaction-diffusion** | Two-chemical system (Gray-Scott) | GPU-accelerated, parameters: feed rate, kill rate |
| **Fractals** | Self-similar recursive structures | Mandelbrot, Julia sets, IFS (Barnsley fern) |
| **Voronoi / Delaunay** | Space partitioning from seed points | Organic cell patterns, mesh generation |
| **Truchet tiles** | Simple tiles with orientation-based patterns | Emergent complexity from tile rotation |
| **SDFs in shaders** | Distance functions for ray-marched 3D | Boolean ops via min/max, smooth blending |

- [FILL: Which generative techniques this project uses]

### Deterministic seeding for reproducible art
- Set `randomSeed()` and `noiseSeed()` at sketch start
- Critical for NFT platforms (Art Blocks uses hex hash → seed for all variables)
- Enables reproducing artwork at any resolution with identical composition
- [FILL: Seeding strategy if applicable]

## Color

### Color modes
- **RGB** — default in all frameworks (0–255)
- **HSB/HSL** — `colorMode(HSB, 360, 100, 100)` — intuitive for generative work (hue rotation, saturation control)
- **OKLCH** — new in p5.js 2.0, perceptually uniform with better hue uniformity than HSL
- **LAB** — perceptually uniform, available via libraries

### Best practices
- Never rely on color alone to convey information (accessibility)
- Establish a palette: complementary, analogous, triadic, or custom
- Test with colorblind simulation (protanopia, deuteranopia, tritanopia)
- HSB is usually better for generative work — rotate hue, control saturation/brightness independently

## Audio

### Audio analysis
- **FFT**: frequency spectrum → drive visuals by frequency bands
- **Amplitude**: overall volume → scale, pulse, trigger events
- **Beat detection**: energy threshold on low-frequency bands
- **Microphone input**: real-time audio-reactive visuals

### Framework-specific
- oF: `ofSoundStream` for I/O, `ofxFft`, `ofxAudioAnalyzer`
- Processing: `Minim` library (FFT, AudioInput, BeatDetect)
- p5.js: `p5.sound` library (`p5.FFT`, `p5.Amplitude`, `p5.AudioIn`)

### OSC (Open Sound Control)
- Lightweight UDP messaging between apps (Ableton, Max/MSP, TouchDesigner, other sketches)
- oF: `ofxOsc` (core addon); Processing: `oscP5`; p5.js: via WebSocket bridge
- [FILL: Audio/OSC integration requirements]

### MIDI
- oF: `ofxMidi`; Processing: `themidibus`; p5.js: Web MIDI API
- Map controller knobs/faders to visual parameters
- [FILL: MIDI hardware and mapping if applicable]

## Computer Vision

- **OpenCV**: oF has `ofxCv` (modern wrapper); Processing has OpenCV for Processing library
- **MediaPipe**: face mesh (468 landmarks), hand tracking (21 keypoints), pose estimation (33 keypoints) — browser via TensorFlow.js, native SDKs for mobile
- **ml5.js** (p5.js): BodyPose (MoveNet/BlazePose), HandPose, FaceMesh, ImageClassifier — all client-side
- **Common tasks**: blob tracking, contour detection, optical flow, background subtraction, face detection
- [FILL: CV features used and camera setup]

## Machine Learning

| Library | Framework | Models |
|---------|-----------|--------|
| **ml5.js** 1.0 | p5.js | BodyPose, HandPose, FaceMesh, ImageClassifier, SoundClassifier |
| **MediaPipe** | Any (JS/native) | Face, hands, pose, object detection, gesture recognition |
| **ofxTensorFlow2** | openFrameworks | TF2 models in C++ (Linux/macOS), style transfer, segmentation |
| **TensorFlow.js** | p5.js / web | Pre-trained models, custom training in-browser |
| **ONNX Runtime Web** | p5.js / web | ONNX models via WebAssembly/WebGL |

- ml5.js runs entirely client-side — no data leaves the device
- [FILL: ML models and use cases in this project]

## Hardware Integration

### Serial / Arduino
- oF: `ofSerial` (built-in) — bidirectional serial communication
- Processing: `Serial` library (built-in) — Processing was the original Arduino IDE basis
- p5.js: `p5.serialport` (via local server) or Web Serial API

### DMX / Lighting
- DMX512: standard protocol for stage lighting
- Art-Net: DMX over Ethernet/UDP for multiple universes
- oF: `ofxArtnet`, `ofxDmx`

### Video sharing (same machine)
- **Syphon** (macOS): GPU texture sharing between apps — zero-latency
- **Spout** (Windows): equivalent to Syphon, DirectX/OpenGL texture sharing
- Send frames to VJ software (Resolume), mapping tools (MadMapper), OBS
- oF: `ofxSyphon`, `ofxSpout`

- [FILL: Hardware peripherals and communication protocols used]

## Installation & Performance Art

### Fullscreen / kiosk
- oF: `ofSetFullscreen(true)`, multi-display via coordinate offsets
- Processing: `fullScreen()` in `settings()`, or `--present` flag
- p5.js: `fullscreen(true)` or CSS-based

### Projection mapping
- **ofxPiMapper**: open-source projection mapping for oF / Raspberry Pi
- **MadMapper**: industry-standard commercial tool, receive via Syphon/Spout
- **TouchDesigner**: node-based, built-in mapping and warping

### Long-running stability
- **Memory management**: avoid allocations in `draw()`; use object pools; profile regularly
- **Crash recovery**: watchdog scripts (systemd/launchd/cron) to auto-restart on crash
- **Auto-start on boot**: systemd service (Linux), launchd plist (macOS), Task Scheduler (Windows)
- **Disable OS interference**: auto-updates, sleep, screensaver, notifications
- **Logging**: file-based logs for post-mortem debugging
- [FILL: Installation environment — indoor/outdoor, runtime hours, network, displays]

## High-Resolution & Print Output

### Raster export
- Scale canvas by multiplier (2x, 4x, 8x) for high-res rendering
- `save("output.png")` / `saveFrame("frame-####.png")`
- Print standard: 300 DPI minimum for gallery prints

### Vector export
- Processing: built-in PDF and SVG renderers — `beginRecord(PDF, "output.pdf")`
- oF: `ofCairoRenderer` for PDF/SVG export
- p5.js: via p5.svg addon or manual SVG construction
- Vector output is resolution-independent — ideal for large-format prints

### NFT / generative art platforms
- Deterministic seeding for reproducible output at any resolution
- Art Blocks: hex hash → seed, resolution-independent rendering
- Test at multiple aspect ratios and resolutions
- [FILL: Output format and resolution requirements]

## Alternative Tools & Ecosystem

| Tool | Type | Language | Best For |
|------|------|----------|----------|
| **TouchDesigner** | Node-based | Python | Installations, live performance, DMX |
| **three.js** | Library | JavaScript | 3D web graphics, WebGPU |
| **Nannou** | Framework | Rust | Memory-safe creative coding |
| **Cinder** | Framework | C++ | Polished native apps (similar to oF) |
| **Hydra** | Live coder | JavaScript | Live-coded visuals, modular synth metaphor |
| **Sonic Pi** | Live coder | Ruby | Live-coded music, pairs with visual tools |
| **Unity/Unreal** | Engine | C#/C++ | Photorealistic installations, VR/AR |
| **Theatre.js** | Animation | JavaScript | Timeline-based motion design with three.js |
| **Shader Park** | Shader tool | JavaScript | JS-to-GLSL SDF transpiler |

## Performance Optimization

- Use GPU rendering (P2D/P3D, WEBGL, ofFbo + shaders) over CPU for complex graphics
- Spatial partitioning (quadtree, grid) for particle/agent systems with many interactions
- `noLoop()` + `redraw()` for static images — don't waste frames
- Off-screen rendering: `createGraphics()` (Processing/p5.js), `ofFbo` (oF)
- p5.js: Web Workers for heavy computation (manual integration)
- Typed arrays and direct `pixels[]` manipulation for image processing
- Profile before optimizing — rendering is usually the bottleneck, not logic

## Key Constraints

- [FILL: Target frame rate and resolution]
- [FILL: Deployment context — web browser, native app, kiosk, projection]
- [FILL: Input sources — mouse, touch, camera, microphone, MIDI, sensors]
- [FILL: Output — screen, projector, print, LED, web]
- [FILL: Runtime duration — one-off render, interactive session, permanent installation]

## Where to Look

- openFrameworks: https://openframeworks.cc/documentation/
- Processing: https://processing.org/reference/
- p5.js: https://p5js.org/reference/
- p5.js Web Editor: https://editor.p5js.org/
- ml5.js: https://ml5js.org/
- The Coding Train (tutorials): https://thecodingtrain.com/
- The Book of Shaders: https://thebookofshaders.com/
- Inigo Quilez (SDFs): https://iquilezles.org/articles/
- Morphogenesis resources: https://github.com/jasonwebb/morphogenesis-resources
- Awesome Creative Coding: https://github.com/terkelg/awesome-creative-coding
- [FILL: Project-specific references and inspiration]

## Common Pitfalls

- Allocating objects in `draw()` — grows memory every frame; pre-allocate or use object pools
- Not setting random/noise seeds — output changes every run, unreproducible
- Forgetting `push()`/`pop()` around transformations — transforms accumulate and corrupt later drawing
- p5.js 2.0 breaking changes — `preload()` removed, array utilities removed, vector API changed
- HSB color mode not set — colors look wrong when using hue/saturation/brightness values in RGB mode
- Blocking the draw loop with synchronous I/O — use async loading, threads, or Web Workers
- Testing only at one resolution — generative art should scale; use relative coordinates or explicit scale factors
- Not handling `windowResized()` / `ofWindowResized()` — canvas doesn't adapt to display changes
- oF addon version mismatches — verify addon compatibility with your oF version
- [FILL: Project-specific gotchas encountered]
