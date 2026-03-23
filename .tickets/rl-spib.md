---
id: rl-spib
status: open
deps: []
links: []
created: 2026-03-23T17:02:42Z
type: task
priority: 0
assignee: David Bau
parent: rl-hyfn
---
# Add review provider config settings

Add USE_COPILOT_REVIEWS (default true) and USE_GREPTILE_REVIEWS (default false) to: resources/core/ralphrc.template, .rl/config, and rl-loop config loading section. Pass to rl-fetch-reviews and rl-reply-reviews via env vars.

## Acceptance Criteria

Settings exist in ralphrc.template and .rl/config. rl-loop reads them with correct defaults. Backpressure passes.

