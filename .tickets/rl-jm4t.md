---
id: rl-jm4t
status: closed
deps: []
links: []
created: 2026-03-23T17:02:48Z
type: task
priority: 0
assignee: David Bau
parent: rl-hyfn
---
# Rename copilot-reviews.md to pr-reviews.md

Rename OUTPUT_FILE in rl-fetch-reviews from copilot-reviews.md to pr-reviews.md. Update all references: PROMPT_review.md, github-pr-review skill (both resources/skills/rl/ and .rl/skills/), .gitignore, rl-migrate, rl-install, README.md, ARCHITECTURE.md, resources/core/README.md.

## Acceptance Criteria

No references to copilot-reviews.md remain in the codebase. Backpressure passes. Existing review workflow still works with new filename.


## Notes

**2026-03-23T17:08:33Z**

Renamed copilot-reviews.md to pr-reviews.md across all files: rl-fetch-reviews, .gitignore, rl-install, rl-migrate, ARCHITECTURE.md, README.md, resources/core/README.md, PROMPT_review.md, github-pr-review skill (both resources/skills/rl/ and .rl/skills/)
