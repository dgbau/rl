---
id: rl-8r4o
status: open
deps: []
links: []
created: 2026-02-21T17:38:50Z
type: feature
priority: 1
assignee: ""
tags: [skills, ai]
---
# rl skills new --global should auto-fill skill content with Claude

When creating a new global skill template via 'rl skills new --global <name>', the command currently just copies the empty _TEMPLATE.md with [FILL] markers. It should invoke Claude to generate actual technology-specific content based on the skill name, using the meta-template structure and existing skills as tone/style references. The user reviews and approves the generated content.

## Acceptance Criteria

1. 'rl skills new --global electron' generates a filled-in Electron skill (not empty template)\n2. Generated content matches the quality/style of existing hand-written skills\n3. User can review/edit before the skill is saved\n4. Falls back to empty template if Claude is unavailable

