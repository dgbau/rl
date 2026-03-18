---
id: rl-m1tc
status: open
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

