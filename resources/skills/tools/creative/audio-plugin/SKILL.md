# Audio Plugin Development (AU / VST3 / CLAP)

<!-- category: template -->

## Overview

Patterns and best practices for audio plugin development — synthesizers, effects, analyzers, and MIDI processors targeting VST3, Audio Unit, CLAP, and AAX formats.
[FILL: What this plugin does — synth, effect, analyzer, MIDI processor]

## Project Configuration

- Framework: [FILL: JUCE / iPlug2 / DPF / NIH-plug (Rust)]
- Target formats: [FILL: VST3, AU, CLAP, AAX — which subset]
- Build system: [FILL: CMake / Cargo (NIH-plug) / Projucer (legacy)]
- Platforms: [FILL: macOS, Windows, Linux — which subset]
- C++ standard: [FILL: C++17 / C++20 / Rust edition]
- GUI framework: [FILL: JUCE Components, custom GPU, egui/iced/VIZIA (Rust), web-based]

## Framework Options

| Framework | Language | License | Formats | Best For |
|-----------|----------|---------|---------|----------|
| **JUCE** | C++ | AGPLv3 / Commercial | VST3, AU, AAX, CLAP (v9) | Most plugins, largest ecosystem |
| **iPlug2** | C++ | zlib (permissive) | VST3, AU, AAX, CLAP, WAM | Permissive license, web audio |
| **DPF** | C++ | ISC (permissive) | VST3, LV2, CLAP | Linux focus, lightweight |
| **NIH-plug** | Rust | ISC (permissive) | VST3, CLAP | Memory safety, no AU/AAX |

- JUCE licensing: Free up to $20K annual revenue (Starter); Indie $50/month; Pro for larger companies
- VST3 SDK is MIT-licensed as of v3.8 (October 2025) — no licensing friction
- CLAP is MIT — completely free and open, created by Bitwig and u-he
- AAX requires Avid developer account + iLok for code signing

## Plugin Formats

| Format | Platforms | DAW Support | Install Path (macOS) |
|--------|-----------|-------------|---------------------|
| **VST3** | Win/Mac/Linux | Universal | `/Library/Audio/Plug-Ins/VST3` |
| **AU v2** | macOS | Logic, GarageBand, etc. | `/Library/Audio/Plug-Ins/Components` |
| **AU v3** | macOS/iOS | Logic, GarageBand, AUv3 hosts | App Extension (`.appex`) |
| **CLAP** | Win/Mac/Linux | Bitwig, REAPER, FL Studio, Studio One | `/Library/Audio/Plug-Ins/CLAP` |
| **AAX** | Win/Mac | Pro Tools only | `/Library/Application Support/Avid/Audio/Plug-Ins` |

- VST2 is discontinued — Steinberg no longer issues licenses
- AU must pass `auval` validation to appear in Logic Pro
- CLAP not yet supported by Ableton Live or Logic Pro
- [FILL: Which formats this project targets and why]

## Real-Time Audio Rules

**The audio callback has 1-10ms to complete. Violating these rules causes audible glitches.**

### Never do on the audio thread
| Forbidden | Why | Safe Alternative |
|-----------|-----|-----------------|
| `new` / `delete` / `malloc` | Unbounded latency, fragmentation | Pre-allocate in `prepareToPlay()`, memory pools |
| `std::mutex` / locks | Priority inversion, deadlock risk | `std::atomic<float>`, lock-free SPSC queues |
| File / network I/O | Kernel calls, unbounded latency | Lock-free ring buffer → separate I/O thread |
| `throw` / `catch` | Allocates, non-deterministic | Error codes, return values |
| `std::string`, `std::vector::push_back` | May allocate | Fixed-size buffers, pre-allocated containers |
| `printf` / `NSLog` | System calls | Lock-free log buffer, flush from another thread |

### Parameter thread safety
```cpp
// Simple values: std::atomic (lock-free on all platforms)
std::atomic<float> gain{1.0f};

// Structured data: lock-free SPSC queue
// Message thread → audio thread: preset data, wavetables
// Audio thread → message thread: meter values, waveform data
```

### Denormal handling
```cpp
// JUCE: RAII guard at top of processBlock()
juce::ScopedNoDenormals noDenormals;

// Manual (x86): set FTZ and DAZ flags
_mm_set_flush_zero_mode(_MM_FLUSH_ZERO_ON);
_mm_set_denormals_zero_mode(_MM_DENORMALS_ZERO_ON);
// ARM/NEON: denormals flushed to zero by default
```

- Denormalized floats (tiny values near zero) cause massive CPU spikes in IIR filters
- FPU flags are per-thread — safe to set without affecting other threads

## DSP Fundamentals

### Sample rates and buffer sizes
- Common rates: 44.1 kHz, 48 kHz, 96 kHz, 192 kHz
- Buffer sizes: 32–2048 samples (host-controlled, may vary between callbacks)
- Latency: `buffer_size / sample_rate × 1000` ms (e.g., 256 @ 44.1 kHz = 5.8 ms)
- **Always handle variable buffer sizes** — host may pass fewer samples than estimated

### SIMD optimization
- x86/x64: SSE, SSE2, AVX, AVX2, AVX-512
- ARM (Apple Silicon): NEON
- JUCE: `juce::dsp::SIMDRegister<float>` for portable SIMD
- Use Structure of Arrays (SoA) layout for cache-friendly SIMD access
- [FILL: SIMD strategy used — manual intrinsics, library abstractions, auto-vectorization]

### Common DSP building blocks
| Block | Implementation | Notes |
|-------|---------------|-------|
| Biquad filter | Direct Form II transposed | EQ, crossovers, tone shaping |
| FFT | JUCE `dsp::FFT`, FFTW, KFR, pffft | Convolution, spectrum analysis |
| Delay line | Circular buffer + fractional interpolation | Delay, chorus, flanger, reverb |
| Oscillator | Wavetable, PolyBLEP, phase accumulator | Anti-aliased for synths |
| Envelope | ADSR state machine | Linear or exponential segments |
| Oversampling | Upsample → process → downsample | Anti-aliasing for nonlinear processing |
| Convolution | FFT-based (uniform/non-uniform partitioned) | Reverb IRs, cabinet simulation |

## Parameter Management

### Parameter types
- **Float** (0.0–1.0 normalized): Gain, frequency, Q, mix
- **Int**: Algorithm selection, voice count
- **Bool**: Bypass, enable/disable
- **Choice**: Filter type, waveform shape

### Parameter smoothing
```cpp
// JUCE: prevents zipper noise from abrupt changes
juce::SmoothedValue<float> gainSmoothed;
gainSmoothed.reset(sampleRate, 0.02); // 20ms ramp

// In processBlock:
for (int i = 0; i < numSamples; ++i) {
    float g = gainSmoothed.getNextValue();
    sample *= g;
}
```

- Ramp time: 10–50 ms depending on parameter (shorter for frequently automated)
- One-pole filter alternative: `smoothed += alpha * (target - smoothed)`

### State save/restore
- JUCE: `AudioProcessorValueTreeState` for automatic XML serialization
- Include a version number in saved state for backward-compatible migrations
- `replaceState()` is NOT real-time safe — call from message thread only
- [FILL: State format — binary, XML, JSON — and versioning strategy]

### Presets
- Factory presets: bundled in plugin binary or resource folder
- User presets: `~/Library/Application Support/<Company>/<Plugin>/Presets/` (macOS)
- VST3 and CLAP have built-in preset discovery mechanisms
- [FILL: Preset management approach]

## MIDI

### MIDI 1.0
- 7-bit resolution (0–127) for most values, 14-bit for pitch bend
- 16 channels per port, channel-based expression

### MPE (MIDI Polyphonic Expression)
- Per-note expression using MIDI 1.0 — each note gets its own channel
- Zone-based: master channel + member channels
- Dimensions: pitch bend (per-note), pressure, slide (CC74)
- Supported by Serum, Vital, Surge, Pigments, and most modern synths

### MIDI 2.0
- 32-bit resolution (4 billion steps), per-note controllers without channel workarounds
- Universal MIDI Packets (UMP) — backward-compatible with MIDI 1.0
- JUCE 8 has infrastructure support; adoption still early (2025)

### CLAP note events
- Unified event queue for notes, parameters, and transport (no separate MIDI buffer)
- Unique note IDs enable true per-note addressing
- Non-destructive polyphonic modulation — host modulates per-voice, values return to base when released
- [FILL: MIDI/note handling requirements — MPE, note expression, MIDI CC mapping]

## GUI

### Framework options
| Approach | Pros | Cons |
|----------|------|------|
| JUCE Components | Mature, cross-platform, resolution-independent | CPU-based rendering, can be slow for complex UIs |
| Custom Metal/D3D12 | Maximum performance, pixel-perfect | Platform-specific code, significant effort |
| iPlug2 IGraphics | NanoVG/Skia/Canvas backends, flat CPU scaling | NanoVG depends on deprecated OpenGL on macOS |
| egui/iced/VIZIA (Rust) | GPU-accelerated, Rust safety | Rust-only, smaller ecosystem |
| Web-based (CLAP ext) | Familiar HTML/CSS/JS | Performance overhead, limited host integration |

- OpenGL is deprecated on macOS — prefer Metal for new GPU rendering
- Touch targets: 44x44px minimum for touch-enabled UIs (AUv3 on iPad)
- [FILL: GUI framework and rendering approach used]

## Common Plugin Types

### Synthesizers
- Polyphony management: voice allocation, voice stealing (oldest, quietest, lowest priority)
- Anti-aliasing: PolyBLEP for oscillators, oversampling for waveshaping
- Modulation matrix: sources (LFO, envelope, velocity) → destinations (filter, pitch, gain)
- Types: subtractive, FM/PM, wavetable, additive, physical modeling, granular

### Effects
- **EQ**: Biquad cascades (parametric), FFT-based (linear-phase)
- **Compressor**: Envelope detection (peak/RMS), gain computer, ballistics (attack/release), lookahead
- **Reverb**: Algorithmic (Schroeder/FDN), convolution (partitioned FFT)
- **Delay**: Circular buffer, fractional interpolation (Hermite/Lagrange), tempo sync, feedback with saturation
- **Distortion**: Waveshaping with oversampling (2–4x) to prevent aliasing

### Analyzers
- FFT-based spectrum display, level meters (peak/RMS/LUFS)
- Must not modify audio (pass-through)
- GPU rendering preferred for smooth visualization at 60fps

### MIDI processors
- Precise timing relative to musical position (PPQ)
- Proper note-on/note-off pairing — never orphan notes
- [FILL: Plugin type and specific DSP requirements]

## Neural Network Audio (Emerging)

| Library | Use Case | Notes |
|---------|----------|-------|
| **RTNeural** | Real-time NN inference (LSTM, GRU, Conv1D) | C++, production-proven, ~2% CPU for 40-layer model |
| **ANIRA** | Decoupled NN inference with thread pool | ONNX/LibTorch/TFLite backends, latency management |
| **ONNX Runtime** | CNN-based processing | Fast for stateless models |

- Applications: amp/cab modeling, audio-to-MIDI, intelligent EQ, denoising, source separation
- Challenge: inference must complete within buffer deadline or use separate thread with latency compensation
- [FILL: Whether this project uses ML-based DSP and which approach]

## Testing

### Validation tools
- **pluginval** (Tracktion): Cross-platform, CLI/CI-friendly, strictness levels 1–10 (minimum level 5)
- **auval**: Required for AU — must pass to appear in Logic Pro
- **VST3 Validator**: Included in VST3 SDK

### Testing hosts
- REAPER (flexible routing, debugging), Bitwig (CLAP features), JUCE AudioPluginHost (quick testing)
- Pro Tools Developer Build (free, loads unsigned AAX)

### Automated testing
- Unit test DSP: compare output against reference signals with known tolerance
- State round-trip: verify `getState()` → `setState()` preserves all parameters
- Multi-sample-rate: test at 44.1k, 48k, 96k, 192k
- Variable buffer sizes: test with 1, 64, 256, 1024, 2048 samples
- CI template: [Pamplejuce](https://github.com/sudara/pamplejuce) (JUCE + Catch2 + pluginval + GitHub Actions)
- [FILL: Test framework — Catch2, GoogleTest, Rust `#[test]`]

## Distribution

### macOS code signing & notarization
1. Code sign with Developer ID Application certificate (`codesign --timestamp`)
2. Package in `.pkg` or `.dmg` (required for notarization submission)
3. Submit via `xcrun notarytool submit`
4. Staple: `xcrun stapler staple <path>`
- Requires Apple Developer Program ($99/year)
- Automatable in CI — see Pamplejuce GitHub Actions workflows

### Windows code signing
- **Azure Trusted Signing**: $9.99/month, instant SmartScreen reputation, CI-friendly
- **OV/EV certificate**: $200–300/year from CA, stored on USB dongle or cloud KMS
- Without signing, Windows SmartScreen blocks installation

### Installers
- macOS: `.pkg` (pkgbuild + productbuild) or `.dmg` with drag-and-drop
- Windows: Inno Setup, WiX Toolset, NSIS
- [FILL: Distribution strategy — direct download, plugin marketplace, both]

## Project Structure

```
[FILL: Adapt to project layout]
src/
  PluginProcessor.h/cpp    # Audio processing (processBlock)
  PluginEditor.h/cpp       # GUI
  DSP/                     # DSP modules (filters, oscillators, effects)
  Parameters/              # Parameter definitions, smoothing, presets
  GUI/                     # Custom components, look-and-feel
Resources/
  Presets/                 # Factory presets
  IR/                      # Impulse responses (if convolution)
  Assets/                  # GUI images, fonts
tests/                     # Unit tests, DSP reference tests
```

## Key Constraints

- [FILL: Target latency budget and CPU percentage per instance]
- [FILL: Minimum buffer size support (some hosts use 32 samples)]
- [FILL: Target sample rates — must work at 44.1k through 192k]
- [FILL: Memory budget — especially for instruments with large sample libraries]
- [FILL: macOS minimum version (affects Metal availability)]
- Audio thread is real-time: no allocations, no locks, no I/O, no exceptions
- Support variable buffer sizes — host may change between callbacks
- All parameters must be automatable and smoothed

## Where to Look

- JUCE: https://juce.com/learn/documentation
- CLAP: https://github.com/free-audio/clap
- VST3 SDK: https://github.com/steinbergmedia/vst3sdk
- NIH-plug: https://github.com/robbert-vdh/nih-plug
- iPlug2: https://github.com/iPlug2/iPlug2
- Pamplejuce (CI template): https://github.com/sudara/pamplejuce
- pluginval: https://github.com/Tracktion/pluginval
- The Audio Programmer (community): https://www.theaudioprogrammer.com/
- [FILL: Project-specific resources, DSP references, design documents]

## Common Pitfalls

- Allocating memory in `processBlock()` — causes glitches; pre-allocate everything
- Forgetting `ScopedNoDenormals` — silent CPU spikes when signal goes quiet
- Not handling variable buffer sizes — host may pass different sizes between callbacks
- Parameter changes without smoothing — audible zipper noise during automation
- Testing only at 44.1 kHz — many users run 96 kHz or higher
- Assuming buffer alignment for SIMD — verify alignment or use unaligned loads
- AU failing `auval` — test early and often, especially `renderQuality` and tail time
- Not code-signing macOS builds — Gatekeeper blocks unsigned plugins entirely
- Orphaned MIDI notes — always pair note-on with note-off, especially on bypass/reset
- [FILL: Project-specific gotchas encountered]
