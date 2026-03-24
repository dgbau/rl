---
id: rl-hyfn
status: closed
deps: []
links: []
created: 2026-03-23T17:02:37Z
type: epic
priority: 0
assignee: David Bau
external-ref: openspec:greptile-reviews
---
# Greptile review provider support

Add Greptile as opt-in PR review provider alongside Copilot. Two boolean config settings, issue comments fetch, provider-aware re-triggering, no-new-reviews exit, calibrated triage.

## Acceptance Criteria

Both USE_COPILOT_REVIEWS and USE_GREPTILE_REVIEWS work independently and together. Review loop fetches, triages, fixes, replies to, and re-triggers Greptile reviews.


## Notes

**2026-03-24T00:02:28Z**

All children closed. Greptile review provider fully implemented: config, fetch, reply, loop integration, prompt calibration, and documentation.
