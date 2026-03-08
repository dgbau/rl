# alphaTab Skill

<!-- category: template -->

## Overview
alphaTab is a cross-platform music notation and guitar tablature rendering library with integrated playback support via MIDI and SoundFont2 (SF2) files. It renders standard notation, guitar tabs, chord diagrams, and supports guitar-specific techniques (bends, slides, hammer-ons/pull-offs, vibrato, palm mute, etc.). Playback is handled through a Web Worker + AudioWorklet pipeline in browser environments.
[FILL: How alphaTab is used in THIS project — e.g. embedded score viewer, interactive tab editor, lesson playback tool]

## Core Setup
- Version: [FILL: alphaTab version — e.g. `@coderline/alphatab@^1.x`]
- SoundFont: [FILL: SF2 file path/URL used for playback — e.g. `assets/soundfonts/default.sf2`]
- Worker assets: alphaTab requires its own Web Worker scripts to be served as static assets; configure your bundler to copy `node_modules/@coderline/alphatab/dist/` to [FILL: output asset path]
- Integration: [FILL: How alphaTab is wired in — e.g. React component wrapper, vanilla JS, Angular directive]

## Architecture & Patterns
alphaTab separates the **API** (`AlphaTabApi`) from the **renderer** and **player** — the API is the single entry point for controlling all three.
- Initialization: [FILL: Where and how `AlphaTabApi` is instantiated — e.g. inside a `useEffect`, on mount lifecycle hook]
- Score loading: scores are loaded via `api.load(data, trackIndexes)` — data may be a URL, `ArrayBuffer`, or `Uint8Array` (Guitar Pro, MusicXML, alphaTeX formats supported)
- Pattern: [FILL: Primary usage pattern — e.g. single-score viewer, multi-track mixer, real-time cursor tracking]
- Structure: [FILL: How alphaTab-related code is organized — e.g. `src/components/ScoreViewer/`, `src/lib/alphatab/`]

## Rendering
- Renderer: alphaTab defaults to SVG; canvas renderer is available but less maintained
- Layout modes: `page` (full score, paginated) and `horizontal` (single scrolling line); set via `settings.display.layoutMode`
- Track visibility: pass track indexes to `api.load()` or update `api.settings.display.tracks` and call `api.updateSettings()`
- [FILL: Which tracks/instruments are rendered in this project and any custom display settings]

## Playback
- Requires `AlphaSynthWebWorker` and `AlphaSynthAudioWorkletOutput` assets to be accessible at [FILL: configured worker base path]
- Player is enabled via `settings.player.enablePlayer = true` and `settings.player.soundFont = '<url>'`
- Cursor tracking: subscribe to `api.playerPositionChanged` to sync UI with playback position
- [FILL: Any custom playback controls, looping, metronome, or speed adjustment features in this project]

## Project Conventions
[FILL: Project-specific patterns for alphaTab usage]
- Naming: [FILL: Naming conventions — e.g. `ScoreViewer`, `TabPlayer`, `useAlphaTab` hook]
- Organization: [FILL: Where alphaTab components/utilities live in the codebase]
- Settings: [FILL: Where shared `AlphaTabSettings` configuration is defined — e.g. `src/lib/alphatab/settings.ts`]
- Style: [FILL: CSS customization approach — alphaTab injects its own DOM; note any style overrides or container sizing conventions]

## Key Constraints
- alphaTab **must** be initialized in a browser context — no SSR; guard with [FILL: SSR escape hatch — e.g. `typeof window !== 'undefined'`, Next.js `dynamic` with `ssr: false`]
- Web Worker and AudioWorklet script paths must be resolvable at runtime; misconfigured `alphaTabWorkerScript` is a common source of silent playback failure
- [FILL: File format constraints — e.g. only Guitar Pro 5 (.gp5) files are used in this project]
- [FILL: Performance requirements — e.g. scores must render within Xms, max track count]
- [FILL: Any accessibility or mobile/touch considerations]

## Workflow
- Development: [FILL: How to serve alphaTab worker assets locally — e.g. Vite `assetsInclude`, Webpack `CopyPlugin` config]
- Building: [FILL: Build steps to ensure worker assets are copied to the output — e.g. `cp node_modules/@coderline/alphatab/dist/*.js public/`]
- Debugging: enable `settings.logging = alphaTab.LogLevel.Debug` to see verbose output; check browser DevTools Network tab to confirm SF2 and worker scripts load correctly

## Where to Look
- Configuration: [FILL: Path to alphaTab settings/config — e.g. `src/lib/alphatab/config.ts`]
- Source code: [FILL: Path to alphaTab integration code — e.g. `src/components/ScoreViewer/`]
- Types/interfaces: alphaTab ships its own TypeScript types via `@coderline/alphatab`; supplemental types at [FILL: project type path if any]
- Examples: [FILL: Path to existing score files or usage examples — e.g. `src/assets/scores/`]
- Docs: https://alphatab.net/docs/introduction

## Dependencies & Related Skills
- [FILL: Bundler skill — e.g. Vite or Webpack, needed to configure asset copying for workers]
- [FILL: Framework skill — e.g. React, Angular, or vanilla JS wrapper approach]
- Related packages: `@coderline/alphatab`; optionally `@coderline/alphatab-bundler-helpers` if available for your bundler

## Common Pitfalls
- **Worker path mismatch**: `settings.player.playerWorkerFile` must point to the exact served path of `alphatab.worker.js` — a 404 here causes playback to silently fail
- **SSR crash**: importing alphaTab at the module level in an SSR framework will throw — always lazy-load or guard with `typeof window !== 'undefined'`
- **SF2 not loaded**: playback starts but produces no sound — verify the SoundFont URL is correct and the file is fully downloaded before calling `api.play()`
- **Container sizing**: alphaTab renders into the container's current dimensions on init; if the container has zero size at mount time the layout will be empty — ensure the element is visible and sized before calling `new AlphaTabApi(el, settings)`
- [FILL: Project-specific gotchas discovered during development]