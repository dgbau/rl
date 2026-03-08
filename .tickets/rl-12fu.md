---
id: rl-12fu
status: closed
deps: []
links: []
created: 2026-02-21T17:39:02Z
type: task
priority: 2
assignee: David Bau
tags: [install, skills]
---
# Add detection signals for electron and anthropic-sdk to install.sh

install.sh auto-suggests skill templates based on detected dependencies. Add detection for: 'electron' in deps -> suggest electron skill, '@anthropic-ai/sdk' in deps -> suggest anthropic-sdk skill. Same pattern as existing stripe/shopify/wagmi detection.

## Acceptance Criteria

1. 'rl install' on a project with electron in package.json suggests the electron skill\n2. 'rl install' on a project with @anthropic-ai/sdk suggests the anthropic-sdk skill\n3. Both appear in the 'Suggested templates' output

