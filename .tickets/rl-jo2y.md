---
id: rl-jo2y
status: open
deps: []
links: []
created: 2026-03-24T04:13:42Z
type: task
priority: 3
assignee: David Bau
---
# Separate multiple Greptile issue comments in rl-fetch-reviews

When Greptile posts multiple timeline comments (initial summary + follow-ups), rl-fetch-reviews dumps all under a single '## Greptile Summary' heading. Should render the first as summary and additional ones as separate entries with their own headings so the triage agent can distinguish them.

## Acceptance Criteria

Multiple Greptile issue comments are rendered with distinct headings in pr-reviews.md

