---
id: rl-m1tc
status: closed
deps: []
links: []
created: 2026-02-21T20:21:21Z
type: task
priority: 1
assignee: ""
tags: [electron, backpressure]
---
# Electron backpressure should include runtime smoke test

The electron skill warns about native module ABI mismatches and CJS/ESM issues, but backpressure only runs lint+test+build in Node.js. These failures only manifest at Electron runtime. Backpressure for Electron projects should include a smoke test that actually launches Electron, verifies the window loads, and exits. Without this, the build loop produces apps that pass all tests but crash on launch.

## Acceptance Criteria

Electron projects have a backpressure step that catches native module ABI mismatches and boot failures before committing.


## Notes

**2026-03-24T00:10:23Z**

Added resources/core/electron-smoke.sh — portable smoke test that launches Electron, waits for boot, catches ABI/CJS crashes. Integrated into rl-install: HAS_ELECTRON flag, appends 'bash .rl/electron-smoke.sh' to backpressure, copies script to .rl/ on install. Handles Linux headless (xvfb-run) and CI (--no-sandbox).
