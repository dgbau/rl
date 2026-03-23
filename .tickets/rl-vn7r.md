---
id: rl-vn7r
status: closed
deps: [rl-spib, rl-jm4t]
links: []
created: 2026-03-23T17:02:54Z
type: task
priority: 0
assignee: David Bau
parent: rl-hyfn
---
# Fetch Greptile issue comments in rl-fetch-reviews

When USE_GREPTILE_REVIEWS=true, also hit GET /repos/{o}/{r}/issues/{pr}/comments. Filter to Greptile author (greptile[bot] or login containing greptile). Add author_type 'greptile' detection. Write Greptile summary as its own section with issue_comment_id annotation. Write Greptile inline comments in separate section. Respect provider toggles (skip Copilot when USE_COPILOT_REVIEWS=false). Write all fetched comment IDs to .rl/last-review-ids.txt for exit detection.

## Acceptance Criteria

With USE_GREPTILE_REVIEWS=true, Greptile issue comments appear in pr-reviews.md with correct sections and issue_comment_id annotations. With USE_COPILOT_REVIEWS=false, Copilot comments are excluded. last-review-ids.txt is written.


## Notes

**2026-03-23T23:51:16Z**

Implemented Greptile issue comment fetching in rl-fetch-reviews. Added: provider config defaults, greptile author_type detection, issue comments endpoint fetch, provider filtering (copilot/greptile toggles), separate output sections (Greptile Summary, Greptile inline, Copilot/Bot), and last-review-ids.txt for exit detection.
