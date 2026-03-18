# Music Theory & Software Implementation

<!-- category: template -->

## Overview

Music theory fundamentals — scales, modes, chords, progressions, modulation, rhythm — with MIDI implementation details, notation software, score processing libraries, and open source music resources.
[FILL: How this project uses music theory — composition tool, analysis, generative music, education, MIDI processing]

## Project Configuration

- Language: [FILL: Python / JavaScript / C++ / Rust / Java]
- MIDI library: [FILL: mido, pretty_midi, @tonejs/midi, RtMidi, midly]
- Notation library: [FILL: music21, Abjad, VexFlow, OSMD, Verovio]
- Audio engine: [FILL: Tone.js, FluidSynth, SuperCollider, Csound, Web Audio API]
- Score format: [FILL: MusicXML, MIDI, LilyPond, ABC, Humdrum]

## Scales and Modes

### Major and minor scales

| Scale | Interval Pattern | Example (A) | Character |
|-------|-----------------|-------------|-----------|
| **Major (Ionian)** | W-W-H-W-W-W-H | A B C# D E F# G# | Bright, happy, resolved |
| **Natural minor (Aeolian)** | W-H-W-W-H-W-W | A B C D E F G | Sad, dark |
| **Harmonic minor** | W-H-W-W-H-W+H-H | A B C D E F G# | Exotic, augmented 2nd (F–G#) |
| **Melodic minor (asc)** | W-H-W-W-W-W-H | A B C D E F# G# | Jazz minor, raised 6th+7th |

W = whole step (2 semitones), H = half step (1 semitone)

### Church modes

| Mode | Degree | Interval Pattern | Character | Common Uses |
|------|--------|-----------------|-----------|-------------|
| **Ionian** | I | W-W-H-W-W-W-H | Bright, resolved | Pop, classical, hymns |
| **Dorian** | ii | W-H-W-W-W-H-W | Minor but warm | Jazz, funk, Celtic |
| **Phrygian** | iii | H-W-W-W-H-W-W | Dark, Spanish | Flamenco, metal |
| **Lydian** | IV | W-W-W-H-W-W-H | Dreamy, floating | Film scores, prog rock |
| **Mixolydian** | V | W-W-H-W-W-H-W | Bluesy major | Blues, rock, folk |
| **Aeolian** | vi | W-H-W-W-H-W-W | Natural minor | Rock, pop ballads |
| **Locrian** | vii | H-W-W-H-W-W-W | Unstable, diminished | Metal, jazz (rare as tonic) |

**Relative modes** share the same notes: C Ionian = D Dorian = E Phrygian = F Lydian = G Mixolydian = A Aeolian = B Locrian.

**Parallel modes** share the same root: C Ionian vs C Dorian vs C Mixolydian — same starting note, different intervals.

### Other scales

| Scale | Formula | Notes |
|-------|---------|-------|
| **Pentatonic major** | 1 2 3 5 6 | Remove 4th and 7th from major |
| **Pentatonic minor** | 1 b3 4 5 b7 | Relative minor of pentatonic major |
| **Blues** | 1 b3 4 b5 5 b7 | Pentatonic minor + blue note (b5) |
| **Whole tone** | W-W-W-W-W-W | Only 2 transpositions exist; dreamy |
| **Diminished (H-W)** | H-W-H-W-H-W-H-W | 8 notes; over diminished chords |
| **Diminished (W-H)** | W-H-W-H-W-H-W-H | 8 notes; over dominant 7b9 chords |
| **Chromatic** | all 12 semitones | H-H-H-H-H-H-H-H-H-H-H-H |

### Exotic scales

| Scale | Intervals from Root | Character |
|-------|-------------------|-----------|
| **Phrygian dominant** | 1 b2 3 4 5 b6 b7 | Flamenco, Arabic, Jewish liturgical |
| **Hungarian minor** | 1 2 b3 #4 5 b6 7 | Dramatic, Eastern European |
| **Double harmonic** | 1 b2 3 4 5 b6 7 | Middle Eastern, Indian |
| **Hirajoshi** | 1 2 b3 5 b6 | Japanese pentatonic, melancholic |
| **Yo** | 1 2 4 5 6 | Japanese pentatonic, bright folk |
| **In** | 1 b2 4 5 b6 | Japanese pentatonic, dark |

- [FILL: Which scales/modes are used in this project]

## Chord Theory

### Triads

| Type | Formula | Example (C) | Sound |
|------|---------|-------------|-------|
| **Major** | 1 3 5 | C E G | Bright, stable |
| **Minor** | 1 b3 5 | C Eb G | Sad, dark |
| **Diminished** | 1 b3 b5 | C Eb Gb | Tense, unstable |
| **Augmented** | 1 3 #5 | C E G# | Mysterious, unresolved |

### Seventh chords

| Type | Formula | Symbol | Example (C) |
|------|---------|--------|-------------|
| **Major 7th** | 1 3 5 7 | Cmaj7 | C E G B |
| **Minor 7th** | 1 b3 5 b7 | Cm7 | C Eb G Bb |
| **Dominant 7th** | 1 3 5 b7 | C7 | C E G Bb |
| **Diminished 7th** | 1 b3 b5 bb7 | Cdim7 | C Eb Gb A |
| **Half-diminished** | 1 b3 b5 b7 | Cm7b5 | C Eb Gb Bb |

### Extended and altered chords

| Type | Formula | Notes |
|------|---------|-------|
| **9th** | 1 3 5 b7 9 | Dominant 9th |
| **Major 9th** | 1 3 5 7 9 | Smooth jazz staple |
| **Minor 9th** | 1 b3 5 b7 9 | Rich minor color |
| **11th** | 1 (3) 5 b7 9 11 | Often omits 3rd (clashes with 11) |
| **13th** | 1 3 5 b7 9 (11) 13 | Full extension, often omits 11th |
| **sus2** | 1 2 5 | Open, ambiguous |
| **sus4** | 1 4 5 | Wants to resolve to 3rd |
| **add9** | 1 3 5 9 | No 7th (unlike 9th chord) |
| **7#9** | 1 3 5 b7 #9 | "Hendrix chord" — aggressive |
| **7b9** | 1 3 5 b7 b9 | Dark dominant |
| **7#11** | 1 3 5 b7 #11 | Lydian dominant |

### Inversions

| Inversion | Bottom Note | Example (C major) | Figured Bass |
|-----------|------------|-------------------|--------------|
| Root position | Root | C E G | 5/3 |
| 1st inversion | 3rd | E G C | 6/3 |
| 2nd inversion | 5th | G C E | 6/4 |
| 3rd (7th chords) | 7th | Bb C E G | 4/2 |

### Diatonic chords of the major scale

| Degree | Roman | Triad | 7th Chord | Mode |
|--------|-------|-------|-----------|------|
| I | I | Major | maj7 | Ionian |
| II | ii | minor | min7 | Dorian |
| III | iii | minor | min7 | Phrygian |
| IV | IV | Major | maj7 | Lydian |
| V | V | Major | dom7 | Mixolydian |
| VI | vi | minor | min7 | Aeolian |
| VII | vii° | diminished | m7b5 | Locrian |

Uppercase = major, lowercase = minor, ° = diminished.

### Nashville number system
- Numbers replace chord names for easy transposition: 1 = tonic, 4 = subdominant, 5 = dominant
- Dash for minor: `2-` = minor ii chord
- Example: `1 - 4 - 5 - 1` in key of G = G - C - D - G

## Chord Progressions

### Common progressions

| Progression | Roman Numerals | Example (C) | Genre |
|-------------|---------------|-------------|-------|
| Three-chord | I - IV - V | C - F - G | Rock, folk, country |
| Pop canon | I - V - vi - IV | C - G - Am - F | Pop (most common) |
| Jazz ii-V-I | ii7 - V7 - Imaj7 | Dm7 - G7 - Cmaj7 | Jazz (foundational) |
| 50s doo-wop | I - vi - IV - V | C - Am - F - G | Early rock, doo-wop |
| 12-bar blues | I I I I / IV IV I I / V IV I V | Standard form | Blues, rock |
| Circle of fifths | vi - ii - V - I | Am - Dm - G - C | Jazz, classical |
| Andalusian | i - bVII - bVI - V | Am - G - F - E | Flamenco, classical |
| Pachelbel Canon | I-V-vi-iii-IV-I-IV-V | C-G-Am-Em-F-C-F-G | Classical, pop |
| Royal Road | IV - V - iii - vi | F - G - Em - Am | J-pop, anime |

### Cadences

| Cadence | Progression | Effect |
|---------|------------|--------|
| **Perfect authentic** | V - I (root pos, tonic in soprano) | Strongest resolution |
| **Imperfect authentic** | V - I (inverted or non-tonic soprano) | Resolved but weaker |
| **Plagal** | IV - I | "Amen" cadence, gentle |
| **Half** | x - V | Unresolved, "question" |
| **Deceptive** | V - vi | Surprise, avoids resolution |
| **Phrygian half** | iv6 - V (in minor) | b2→1 in bass, Spanish flavor |

### Voice leading principles
1. **Minimal motion** — move each voice the smallest interval possible
2. **Common tones** — keep shared notes in the same voice
3. **Contrary motion** — outer voices move in opposite directions
4. **Resolve tendency tones** — leading tone (7th degree) resolves up; chordal 7ths resolve down
5. **Avoid parallel 5ths/octaves** — classical rule, relaxed in pop/jazz

### Secondary dominants
A dominant chord resolving to a diatonic chord other than I:
- **V/V**: D7 → G (in C major)
- **V/vi**: E7 → Am
- **V/ii**: A7 → Dm
- **V/IV**: C7 → F

### Borrowed chords (modal interchange)
Chords from the parallel minor used in major:
- **bVI** (Ab in C major), **bVII** (Bb), **iv** (Fm), **bIII** (Eb)
- **bVI - bVII - I**: common in film scores and rock
- **Picardy third**: ending minor-key piece on major I

### Tritone substitution
Replace V7 with a dominant 7th a tritone away: G7 → Db7 (both share the tritone B–F). Creates chromatic bass: Dm7 - Db7 - Cmaj7.

## Modulation (Key Changes)

### Common modulation targets
- **To dominant (V)**: C major → G major (most natural)
- **To relative minor (vi)**: C major → A minor (same key signature)
- **To parallel minor**: C major → C minor
- **To subdominant (IV)**: C major → F major
- **Up a half step**: "truck driver's modulation" — final chorus energy lift

### Modulation techniques

| Technique | How It Works |
|-----------|-------------|
| **Pivot chord** | Chord shared between both keys serves as bridge (e.g., Em = iii in C, vi in G) |
| **Direct/abrupt** | Jump to new key without preparation — dramatic contrast |
| **Chromatic** | Semitone voice leading connects keys via altered chords |
| **Common-tone** | Hold shared note(s) while harmony changes around them |
| **Sequential** | Repeat pattern at successively higher/lower pitch until new key establishes |

### Modal mixture
- Using chords from parallel mode: Fm (iv from C minor) in C major
- **Dorian borrowing**: major IV chord in minor key (F major in A minor, from A Dorian)
- [FILL: Modulation and modal interchange patterns used in this project]

## Rhythm and Time

### Time signatures

| Category | Examples | Feel |
|----------|---------|------|
| **Simple** (beat divides by 2) | 2/4 (march), 3/4 (waltz), 4/4 (common time) | Even subdivision |
| **Compound** (beat divides by 3) | 6/8 (jig), 9/8 (slip jig), 12/8 (slow blues) | Triplet feel |
| **Odd/asymmetric** | 5/4 (Take Five), 7/8 (Balkan), 11/8, 13/8 | Grouped (e.g., 7/8 = 2+2+3) |

### Note durations and MIDI ticks

| Note | Beats (4/4) | MIDI Ticks (480 PPQ) |
|------|-------------|---------------------|
| Whole | 4 | 1920 |
| Half | 2 | 960 |
| Quarter | 1 | 480 |
| Eighth | 1/2 | 240 |
| Sixteenth | 1/4 | 120 |
| Thirty-second | 1/8 | 60 |
| Dotted quarter | 1.5 | 720 |
| Triplet eighth | 1/3 | 160 |

**PPQ (Pulses Per Quarter Note)**: timing resolution. Common values: 480 (most software), 960 (high-res).

### Feel and groove
- **Straight**: even subdivision (50/50 eighth notes)
- **Swing**: long-short pattern (~67/33 ratio); jazz approximates triplet feel
- **Shuffle**: pronounced swing, common in blues/boogie
- MIDI swing: offset "and" beats by percentage (60-67% for downbeat portion)

### Polyrhythm vs polymeter
- **Polyrhythm**: different groupings over same span (3 against 2)
- **Polymeter**: different time signatures simultaneously (3/4 vs 4/4 — bar lengths differ)

## MIDI Implementation

### Core reference

| Concept | Details |
|---------|---------|
| Note numbers | 0–127 (C-1 to G9). **C4 = 60** (middle C). **A4 = 69** (440 Hz) |
| Velocity | 0–127. pp≈30, p≈50, mp≈65, mf≈80, f≈95, ff≈110, fff≈127 |
| Channels | 1–16. **Channel 10 = percussion** (General MIDI) |
| Formula | `MIDI note = 12 × (octave + 1) + pitch_class` (C=0, C#=1, ..., B=11) |

### Message types

| Message | Status | Data | Notes |
|---------|--------|------|-------|
| Note On | 0x9n | note, velocity | velocity 0 = Note Off |
| Note Off | 0x8n | note, velocity | release velocity |
| Control Change | 0xBn | CC#, value | see CC table below |
| Program Change | 0xCn | program | instrument selection (0–127) |
| Pitch Bend | 0xEn | LSB, MSB | 14-bit (0–16383), center = 8192, default ±2 semitones |
| Channel Aftertouch | 0xDn | pressure | whole channel |
| Poly Aftertouch | 0xAn | note, pressure | per-note |

### Control Change (CC) messages

| CC# | Name | Range | Notes |
|-----|------|-------|-------|
| 1 | Modulation | 0–127 | Vibrato, expression |
| 7 | Volume | 0–127 | Channel volume |
| 10 | Pan | 0–127 | 0=left, 64=center, 127=right |
| 11 | Expression | 0–127 | Dynamic sub-volume |
| 64 | Sustain pedal | 0–63=off, 64–127=on | Damper pedal |
| 65 | Portamento | 0–63=off, 64–127=on | Glide |
| 91 | Reverb send | 0–127 | Effects level |
| 93 | Chorus send | 0–127 | Effects level |
| 120 | All Sound Off | 0 | Emergency silence |
| 123 | All Notes Off | 0 | Panic button |

### General MIDI instrument families (Program Change 0–127)
0–7 Piano, 8–15 Chromatic Percussion, 16–23 Organ, 24–31 Guitar, 32–39 Bass, 40–47 Strings, 48–55 Ensemble, 56–63 Brass, 64–71 Reed, 72–79 Pipe, 80–87 Synth Lead, 88–95 Synth Pad, 96–103 Synth FX, 104–111 Ethnic, 112–119 Percussive, 120–127 Sound FX.

### MIDI file format
- **Type 0**: single track (all channels interleaved) — simple but hard to edit
- **Type 1**: multi-track (one per instrument) — most common for production
- **Type 2**: independent sequences — rarely used
- Structure: header chunk (`MThd`) + track chunks (`MTrk`) with delta-time encoded events
- Meta events: tempo (0x51), time signature (0x58), key signature (0x59), track name (0x03)

### MIDI 2.0 key differences
- 32-bit resolution for velocity, controllers, pitch bend (vs 7/14-bit)
- Per-note controllers and pitch bend (not just per-channel)
- 256 channels (16 groups × 16 channels)
- Bidirectional capability inquiry (MIDI-CI)
- Backward compatible with MIDI 1.0 via Universal MIDI Packets (UMP)

## Software Libraries

### MIDI processing

| Library | Language | License | Description |
|---------|----------|---------|-------------|
| **mido** | Python | MIT | MIDI file I/O and real-time port access |
| **pretty_midi** | Python | MIT | High-level analysis, piano roll representation |
| **music21** | Python | BSD-3 | Comprehensive musicology — analysis, generation, corpus |
| **mingus** | Python | GPL-3 | Music theory: scales, chords, progressions, LilyPond output |
| **MIDIUtil** | Python | MIT | Pure Python MIDI file writing |
| **pyfluidsynth** | Python | LGPL | FluidSynth bindings, SoundFont rendering |
| **Tone.js** | JavaScript | MIT | Web Audio framework — synths, effects, scheduling |
| **@tonejs/midi** | JavaScript | MIT | MIDI file parser/encoder for Tone.js |
| **JZZ** | JavaScript | MIT | Full MIDI library, Web MIDI API polyfill |
| **Web MIDI API** | Browser | W3C | Native browser MIDI device access (Chrome, Edge, Firefox) |
| **RtMidi** | C++ | MIT-like | Cross-platform real-time MIDI I/O |
| **libremidi** | C++20 | BSD | Modern RtMidi fork, MIDI 1 & 2, file I/O |
| **midly** | Rust | MIT | MIDI file decoder/encoder, zero-copy |
| **midir** | Rust | MIT | Real-time MIDI I/O (like RtMidi) |
| **JFugue** | Java | Apache-2 | Music programming: `"C5q D5q E5h"` pattern syntax |

- [FILL: Which MIDI libraries this project uses]

### Score notation and rendering

| Library | Language | License | Description |
|---------|----------|---------|-------------|
| **LilyPond** | CLI (C++/Scheme) | GPL | Text → PDF/SVG, highest quality engraving |
| **MuseScore Studio** | Desktop (C++/Qt) | GPL-3 | GUI notation editor, MusicXML 4.0, playback |
| **Abjad** | Python | GPL-3 | Programmatic score building on LilyPond |
| **music21** | Python | BSD-3 | Analysis, generation, MusicXML/MIDI/Humdrum I/O |
| **VexFlow** | TypeScript | MIT | Browser notation + tablature rendering (Canvas/SVG) |
| **OSMD** | TypeScript | BSD-3 | MusicXML rendering in browser (uses VexFlow) |
| **Verovio** | C++/JS | LGPL-3 | MEI, MusicXML, Humdrum, ABC → SVG. Bindings for Python, Java, JS |
| **alphaTab** | JS/.NET | MPL-2 | Tablature + notation, reads Guitar Pro files, built-in synth |
| **PyGuitarPro** | Python | LGPL-3 | Read/write Guitar Pro 3/4/5 files |
| **TuxGuitar** | Desktop (Java) | LGPL-2.1 | Open source Guitar Pro alternative |

- [FILL: Notation/rendering tools used in this project]

## Score Formats

| Format | Extension | Type | Best For |
|--------|-----------|------|----------|
| **MusicXML** | .musicxml, .mxl | XML | Industry standard interchange, all notation software |
| **MEI** | .mei | XML | Academic archival, rich metadata, critical editions |
| **ABC notation** | .abc | Text | Folk music, extremely compact and human-readable |
| **LilyPond** | .ly | Text | Highest quality typesetting, programmable (Scheme) |
| **MIDI** | .mid | Binary | Universal playback, timing + notes (no notation detail) |
| **Humdrum (\*\*kern)** | .krn | Text | Music analysis, multi-voice encoding |
| **MuseScore** | .mscz | ZIP/XML | Full fidelity for MuseScore editor |
| **Guitar Pro** | .gp, .gp5, .gpx | Binary | Tablature, no public spec (reverse-engineered) |

- MusicXML 4.0: linked score+parts, concert pitch, swing, Nashville chord styles
- MIDI stores performance data (timing, velocity) but not notation (beaming, slurs, dynamics text, lyrics)
- [FILL: Score formats used in this project]

## Free Score and MIDI Repositories

| Repository | Content | Formats | Size |
|-----------|---------|---------|------|
| **IMSLP** | Public domain classical | PDF scans, some MusicXML | 736K+ scores, 226K+ works |
| **Mutopia Project** | Public domain, typeset | LilyPond, PDF, MIDI | 2,124+ pieces |
| **MuseScore.com** | Community arrangements | .mscz, PDF, MIDI, MusicXML | Millions (mix free/Pro) |
| **KernScores** | Computational analysis | Humdrum (\*\*kern) | 108K+ files, 7.9M notes |
| **music21 corpus** | Bundled with library | MusicXML, \*\*kern, ABC, MIDI | Bach chorales, folk songs, etc. |
| **Lakh MIDI Dataset** | ML research | MIDI | 176K unique MIDI files |
| **Internet Archive** | Various archives | MIDI, SoundFonts | 500+ SoundFont collections |
| **Musical Artifacts** | Community repository | SoundFonts, SFZ, samples | Curated free samples |

- [FILL: Score/MIDI data sources used in this project]

## Tablature

### Guitar tablature notation
- Six lines = six strings (low E bottom, high E top)
- Numbers = fret positions
- Symbols: `h` hammer-on, `p` pull-off, `b` bend, `/` slide up, `\` slide down, `~` vibrato, `x` muted

### Tools
- **TuxGuitar**: open source editor, reads GP3/4/5, MIDI, MusicXML
- **alphaTab**: JS/browser tablature rendering, reads GP3–7, built-in synth
- **PyGuitarPro**: Python read/write for Guitar Pro files
- **VexFlow**: also renders tablature alongside standard notation
- [FILL: Tablature tools and formats used]

## Audio Synthesis

### SoundFonts
- **FluidSynth** (v2.5, LGPL): renders MIDI via SF2/SF3 SoundFont files
- Free SoundFonts: FluidR3_GM, GeneralUser GS, MuseScore General, Timbres of Heaven
- Repositories: [Musical Artifacts](https://musical-artifacts.com/), [SFZ Instruments](https://sfzinstruments.github.io/), [Polyphone](https://www.polyphone.io/)

### Audio programming environments

| Tool | Language | License | Best For |
|------|----------|---------|----------|
| **Csound** | Own DSL | LGPL | Algorithmic composition, sound design, WebAssembly |
| **SuperCollider** | sclang | GPL-3 | Real-time synthesis, live coding, generative music |
| **Sonic Pi** | Ruby DSL | MIT | Education, live coding performances |
| **ChucK** | Own language | GPL | Precise timing, on-the-fly code modification |

- [FILL: Audio synthesis tools and SoundFonts used]

## Key Constraints

- [FILL: Musical scope — Western tonal, microtonal, atonal, non-Western]
- [FILL: Target accuracy — educational approximation vs. musicological rigor]
- [FILL: Real-time requirements — latency budget for live performance]
- [FILL: MIDI version — MIDI 1.0 (7-bit) vs MIDI 2.0 (32-bit)]
- [FILL: Output format — audio playback, notation, MIDI file, score PDF]

## Where to Look

- music21 docs: https://music21.readthedocs.io/
- Tone.js docs: https://tonejs.github.io/
- LilyPond docs: https://lilypond.org/doc/
- MusicXML spec: https://www.w3.org/2021/06/musicxml40/
- MIDI spec: https://midi.org/specifications
- IMSLP: https://imslp.org/
- Mutopia: https://www.mutopiaproject.org/
- Lakh MIDI: https://colinraffel.com/projects/lmd/
- FluidSynth: https://www.fluidsynth.org/
- [FILL: Project-specific music theory and software references]

## Common Pitfalls

- Confusing relative and parallel modes — C Dorian (Bb major notes) vs D Dorian (C major notes)
- MIDI velocity 0 treated as Note Off — always check for orphaned notes
- Channel 10 is percussion in GM — instruments on channel 10 will play as drums
- PPQ mismatch between files — normalize tick values when combining MIDI from different sources
- Swing quantization destroying feel — apply swing as offset percentage, not rigid triplet grid
- Enharmonic spelling (C# vs Db) — musically different in notation, identical in MIDI
- MusicXML export losing articulations — validate round-trip fidelity between notation tools
- SoundFont quality varies wildly — test with target SoundFont before committing to MIDI-based output
- [FILL: Project-specific gotchas encountered]


## midi-writer-js

# midi-writer-js Skill

<!-- category: template -->

## Overview
midi-writer-js is a JavaScript library for programmatically generating MIDI files, compatible with both browser environments and Node.js. It provides a high-level API for creating tracks, adding notes, setting tempo/time signature, and exporting the result as a `.mid` file or base64 data URI.
[FILL: How midi-writer-js is used in this project — e.g., exporting chord progressions, generating backing tracks, one-shot exports vs. real-time generation]

## Core Setup
- Version: [FILL: midi-writer-js version pinned in package.json]
- Import style: [FILL: ESM (`import MidiWriter from 'midi-writer-js'`) or CJS (`require`)]
- Browser vs Node: [FILL: Which environment(s) this project targets for MIDI export]
- Integration: [FILL: How the MIDI export hooks into the rest of the app — e.g., triggered by a "Download MIDI" button, called from a service/util module]

## API Patterns

### Basic Track Construction
```js
const track = new MidiWriter.Track();
track.setTempo(120);
track.addEvent(new MidiWriter.ProgramChangeEvent({ instrument: 1 }));
track.addEvent(new MidiWriter.NoteEvent({
  pitch: ['C4', 'E4', 'G4'],
  duration: '1',
  sequential: false, // false = chord, true = arpeggio
}));
const writer = new MidiWriter.Writer([track]);
const dataUri = writer.dataUri(); // or writer.buildFile() for Buffer
```

### Chord Progression Export
- Each chord maps to a `NoteEvent` with an array of pitch strings
- Duration values: `'1'` whole, `'2'` half, `'4'` quarter, `'8'` eighth, `'d4'` dotted quarter, etc.
- [FILL: How chord objects in this project are translated to pitch arrays — e.g., which field holds note names, enharmonic spelling conventions]

## Architecture & Patterns
[FILL: Where MIDI generation lives in the codebase — dedicated service, utility function, component-level handler]
- Pattern: [FILL: e.g., pure function `progressionToMidi(chords) => Blob` vs. class-based service]
- Structure: [FILL: File(s) responsible for MIDI export logic]
- Output: [FILL: How the file is delivered to the user — `<a download>` trigger, FileSaver.js, Node `fs.writeFile`, etc.]

## Project Conventions
[FILL: Project-specific conventions around MIDI export]
- Naming: [FILL: Naming for export functions, generated filenames, e.g., `${progressionName}-${bpm}bpm.mid`]
- Organization: [FILL: Path to MIDI utility/service files]
- Tempo source: [FILL: Where BPM comes from — global state, per-progression setting, hardcoded default]
- Instrument: [FILL: Default GM program number used, e.g., `0` = Acoustic Grand Piano]

## Key Constraints
- [FILL: Browser download approach — data URI vs. Blob URL, IE/Safari compatibility needs]
- [FILL: Max polyphony or track count requirements]
- Note pitch format must be a string like `'C4'`, `'F#3'` — not MIDI numbers (use `NoteEvent` pitch array, not `wait` offsets, for chords)
- Sequential vs. chord: `sequential: false` groups pitches into a chord; `sequential: true` plays them one after another
- [FILL: Any constraints on file size or duration for the export use case]

## Workflow
- Development: [FILL: How to test MIDI export locally — e.g., open generated file in DAW, use online MIDI player]
- Building: [FILL: Any bundler config needed — midi-writer-js ships CJS; confirm ESM interop if using Vite/esbuild]
- Debugging: [FILL: Tools used to inspect generated MIDI — e.g., MIDI Monitor, `midi-file` npm package for parsing output in tests]

## Where to Look
- Source code: [FILL: Path to MIDI export utility, e.g., `src/lib/midi-export.ts`]
- Types/interfaces: [FILL: Path to type definitions for chord/note structures passed into the exporter]
- Examples: [FILL: Path to existing export usage in the codebase]
- Docs: https://grimmdude.com/MidiWriterJS/docs/ and https://github.com/grimmdude/MidiWriterJS

## Dependencies & Related Skills
- [FILL: Related skill for chord/music-theory data structures fed into MIDI export]
- [FILL: File-save utility used alongside midi-writer-js, e.g., `file-saver`, native `<a>` download]
- [FILL: Audio playback skill/library if MIDI export complements in-browser playback]

## Common Pitfalls
- Pitch strings are case-sensitive and octave-required: `'c4'` may fail — use `'C4'`
- `writer.dataUri()` returns a full `data:audio/midi;base64,...` string; strip the prefix if you need raw base64
- Each `Track` is independent — tempo must be set per-track if using multiple tracks
- [FILL: Any discovered issues with the version in use — e.g., ESM import quirks under specific bundler versions]
- [FILL: Known enharmonic spelling issues, e.g., `Bb4` vs `A#4` and which the project standardizes on]