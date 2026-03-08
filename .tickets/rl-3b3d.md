---
id: rl-3b3d
status: closed
deps: []
links: []
created: 2026-02-21T17:46:18Z
type: feature
priority: 0
assignee: David Bau
tags: [create, cli]
---
# Add --no-prompt flag to rl create for programmatic project creation

rl create is interactive-only (all prompts use /dev/tty). Add CLI flags so it can be driven programmatically by tools like The Primer or Claude Code. Flags needed: --name, --preset, --app-name, --skills (comma-sep), --tailwind, --no-tailwind, --strict-ts, --no-strict-ts, --openspec, --no-openspec, --github, --no-github, --no-prompt (skip confirmation). When --no-prompt is passed with sufficient flags, skip all interactive prompts. Missing required flags (--name, --preset) should error.

## Acceptance Criteria

1. 'rl create --no-prompt --name my-app --preset apps --skills react,tailwind' works without TTY\n2. All existing interactive behavior preserved when no flags passed\n3. --no-prompt errors if --name or --preset missing\n4. Works from Claude Code and other non-TTY environments

