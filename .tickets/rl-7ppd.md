---
id: rl-7ppd
status: open
deps: [rl-vn7r]
links: []
created: 2026-03-23T17:02:59Z
type: task
priority: 1
assignee: David Bau
parent: rl-hyfn
---
# Reply to issue comments in rl-reply-reviews

Add comment_type field support to review manifest. For 'review' type: existing behavior (reply via pulls endpoint + resolve thread). For 'issue' type: reply via POST /repos/{o}/{r}/issues/{pr}/comments. Issue comments cannot be resolved, just replied to. Default comment_type to 'review' for backward compat.

## Acceptance Criteria

Manifest entries with comment_type 'issue' post replies via issues endpoint. Entries with comment_type 'review' (or missing) use existing behavior. Backpressure passes.

