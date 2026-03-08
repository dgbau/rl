# Tone.js Skill

<!-- category: template -->

## Overview
Tone.js is a Web Audio framework for building synthesizers, samplers, and musical sequencing applications in the browser. It wraps the Web Audio API with a high-level, musical abstraction layer covering oscillators, envelopes, effects, transport scheduling, and more.
[FILL: How Tone.js is used in this project — e.g. generative composition, interactive instrument, step sequencer, audio visualizer]

## Core Setup
- Version: [FILL: Tone.js version in use, e.g. `^14.x`]
- Configuration: [FILL: How Tone.js is initialised — e.g. `Tone.start()` on user gesture, custom AudioContext, sample preloading strategy]
- Integration: [FILL: How Tone.js wires into the rest of the stack — e.g. React state, Svelte stores, plain JS event bus]

## Audio Architecture
[FILL: High-level signal chain and design decisions for this project]
- Signal chain: [FILL: How audio nodes are connected — instruments → effects → destination]
- Transport: [FILL: Whether `Tone.Transport` is used, tempo/time signature, loop regions]
- Instruments: [FILL: Which built-in instruments are used — Synth, PolySynth, Sampler, Player, etc.]
- Effects: [FILL: Which effects are used — Reverb, Delay, Chorus, Distortion, etc.]

## Scheduling & Timing
- Pattern/sequencing: [FILL: How sequences are authored — `Tone.Sequence`, `Tone.Pattern`, `Tone.Part`, manual `Transport.scheduleRepeat`]
- Time notation: [FILL: Preferred time notation used in this project — bars:beats:sixteenths, seconds, note values]
- Quantisation: [FILL: Any quantisation or swing settings applied]

## Project Conventions
[FILL: Project-specific patterns, naming conventions, file locations]
- Naming: [FILL: Naming conventions — e.g. `createDrumSynth()` factory functions, `useTone` hooks]
- Organisation: [FILL: Where audio code lives — e.g. `src/audio/`, `src/instruments/`, `src/sequences/`]
- Style: [FILL: Code style preferences — e.g. always dispose nodes on unmount, never construct instruments inside render loops]

## Key Constraints
- [FILL: Browser compatibility requirements — Web Audio API support matrix]
- [FILL: Mobile/autoplay policy handling — must call `Tone.start()` inside a user gesture]
- [FILL: Latency or performance budget — e.g. max polyphony, sample file size limits]
- [FILL: Asset loading strategy — remote CDN vs bundled samples, preload gates]
- [FILL: Memory management rules — when and how to call `.dispose()` on nodes]

## Workflow
- Development: [FILL: How to run the dev server and test audio locally — e.g. `pnpm nx serve <app>`]
- Building: [FILL: Any audio-asset pipeline steps — sample copying, format conversion, manifest generation]
- Debugging: [FILL: Debugging approach — browser Web Audio inspector, `Tone.getContext().rawContext`, logging transport state]

## Where to Look
- Configuration: [FILL: Path to Tone.js initialisation — e.g. `src/audio/context.ts`]
- Source code: [FILL: Main audio source directory — e.g. `src/audio/`]
- Instruments: [FILL: Path to instrument definitions — e.g. `src/audio/instruments/`]
- Sequences: [FILL: Path to sequence/pattern definitions — e.g. `src/audio/sequences/`]
- Samples: [FILL: Path to audio sample assets — e.g. `public/samples/` or `assets/audio/`]
- Docs: https://tonejs.github.io/docs/

## Dependencies & Related Skills
- [FILL: UI framework skill if applicable — e.g. React, Svelte, Vue]
- [FILL: Build tool skill — e.g. Vite, webpack, for handling audio asset imports]
- [FILL: Related packages — e.g. `@tonejs/midi` for MIDI file parsing, `standardized-audio-context` for test environments]

## Common Pitfalls
- `Tone.start()` must be called from a user-initiated event; calling it at module load time will be blocked by browser autoplay policy
- Constructing new instruments or effects inside hot render paths (e.g. React re-renders) causes audio glitches and memory leaks — instantiate once, reuse
- [FILL: Any project-specific gotchas discovered during development]
- [FILL: Known issues with the chosen Tone.js version or interop with bundler]
- Forgetting to call `.dispose()` on instruments/effects leaks AudioContext nodes; enforce disposal in component teardown or store cleanup