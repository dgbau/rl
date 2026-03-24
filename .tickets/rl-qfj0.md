---
id: rl-qfj0
status: closed
deps: [rl-spib, rl-vn7r, rl-7ppd]
links: []
created: 2026-03-23T17:03:04Z
type: task
priority: 1
assignee: David Bau
parent: rl-hyfn
---
# Provider-aware re-triggering and exit condition in rl-loop

Replace hardcoded 'gh pr edit --add-reviewer @copilot' with provider-conditional logic. When USE_GREPTILE_REVIEWS=true: post @greptileai issue comment. When USE_COPILOT_REVIEWS=true: keep existing re-request. Add no-new-reviews exit: compare current review IDs against .rl/last-review-ids.txt — if identical, exit with 'reviewer satisfied' message. Clean up last-review-ids.txt at start of review mode.

## Acceptance Criteria

Loop re-triggers correct provider(s). Loop exits when no new comment IDs appear. last-review-ids.txt cleaned up at mode start.


## Notes

**2026-03-24T00:00:24Z**

Implemented provider-conditional re-triggering (Greptile via @greptileai issue comment, Copilot via --add-reviewer), no-new-reviews exit condition using last-review-ids.txt diff, and cleanup of last-review-ids.txt at review mode start.
