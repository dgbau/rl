# midi-writer-js Skill

<!-- category: template -->

## Overview
`midi-writer-js` is an npm library for programmatically generating standard MIDI (.mid) files from JavaScript/TypeScript. It provides an API for constructing tracks, adding notes, chords, and tempo/time-signature events, then serialising the result to a binary MIDI blob or base64 string.
[FILL: How the Export Service uses midi-writer-js — e.g. "converts internal ChordProgression objects to .mid file downloads via the `ExportService.toMidi()` method"]

## Core Setup
- Version: [FILL: e.g. `^3.1.1` — check `package.json`]
- Installation: `npm install midi-writer-js` (or pnpm/yarn equivalent for this workspace)
- TypeScript types: bundled — no `@types/` package needed
- Integration: [FILL: which app/lib in the Nx workspace owns the Export Service, e.g. `libs/export` or `apps/api`]

## Key API Concepts

### Building a MIDI file
```ts
import MidiWriter from 'midi-writer-js';

const track = new MidiWriter.Track();
track.setTempo(120);
track.addEvent(new MidiWriter.NoteEvent({
  pitch: ['C4', 'E4', 'G4'],  // chord as array of pitch strings
  duration: '1',               // whole note
  sequential: false,           // play simultaneously (chord), not arpeggio
}));

const writer = new MidiWriter.Writer([track]);
const midiBlob = writer.buildFile();  // Uint8Array
const base64   = writer.base64();
```

### Duration codes
| Code | Value |
|------|-------|
| `'1'` | whole |
| `'2'` | half |
| `'4'` | quarter |
| `'8'` | eighth |
| `'d4'` | dotted quarter |
| `'T4'` | quarter triplet |

## Architecture & Patterns
[FILL: Key design decisions, e.g. "Each chord in the progression becomes one NoteEvent; tempo and time signature are set once at track head"]
- Pattern: [FILL: e.g. "One `Track` per instrument/voice" or "Single track for all chords"]
- Mapping: [FILL: How internal chord/note types map to midi-writer-js pitch strings, e.g. `ChordNote → string[]` converter location]
- Output: [FILL: How the file is delivered — e.g. streamed HTTP response, saved to disk, returned as base64 data URL]

## Project Conventions
[FILL: Project-specific patterns for the Export Service]
- Naming: [FILL: e.g. file named `<progression-title>.mid`, slugified]
- Organization: [FILL: Path to ExportService source, e.g. `libs/export/src/lib/export.service.ts`]
- Pitch format: [FILL: Which pitch notation is used internally — scientific (C4) vs MIDI number — and where conversion happens]
- Style: [FILL: e.g. "Always set tempo and time signature before adding NoteEvents"]

## Key Constraints
- `NoteEvent` pitch values must be valid scientific-notation strings (`C4`, `F#3`) or MIDI numbers — validate before passing
- [FILL: Any chord-voicing limits, e.g. "max polyphony the target use case requires"]
- [FILL: File-size or duration constraints for exported MIDI]
- The library is **synchronous** — no async API; wrap in a worker/thread if called from a hot path
- [FILL: Browser vs Node target — `writer.buildFile()` returns `Uint8Array`; adapt for Node `Buffer` or browser `Blob` as needed]

## Workflow
- Development: [FILL: e.g. "Run `pnpm nx serve export-api` and use the `/export/midi` endpoint to download a test file"]
- Testing: [FILL: e.g. "Unit-test the mapping layer; use `writer.base64()` output and decode with a MIDI parser to assert note content"]
- Debugging: [FILL: e.g. "Open generated .mid in GarageBand / MuseScore to visually verify chord voicings and timing"]

## Where to Look
- Export Service source: [FILL: e.g. `libs/export/src/lib/`]
- Chord-to-pitch mapper: [FILL: e.g. `libs/export/src/lib/chord-to-midi.ts`]
- Types/interfaces: [FILL: e.g. `libs/domain/src/lib/chord-progression.ts`]
- Examples: [FILL: e.g. existing test fixtures in `libs/export/src/lib/__tests__/`]
- Docs: https://grimmdude.com/MidiWriterJS/docs/
- npm: https://www.npmjs.com/package/midi-writer-js
- GitHub: https://github.com/grimmdude/MidiWriterJS

## Dependencies & Related Skills
- [FILL: Domain model skill/types — e.g. `ChordProgression`, `ChordNote` interfaces]
- [FILL: HTTP delivery layer — e.g. Express route or NestJS controller that calls ExportService]
- [FILL: Any audio-playback library used alongside MIDI export (e.g. Tone.js, WebMIDI)]

## Common Pitfalls
- **Chord vs sequential**: `sequential: false` is required for chords; omitting it produces an arpeggio
- **Pitch casing**: pitch strings are case-sensitive — `C4` works, `c4` does not
- **Accidentals**: use `F#4` or `Bb4` — double-sharps/flats are not supported
- [FILL: Any project-specific gotchas discovered during integration]
- [FILL: Known edge cases with the chord-progression data model, e.g. enharmonic spelling mismatches]