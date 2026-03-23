---
id: rl-o8ic
status: open
deps: [rl-jm4t, rl-vn7r]
links: []
created: 2026-03-23T17:03:11Z
type: task
priority: 1
assignee: David Bau
parent: rl-hyfn
---
# Update PROMPT_review.md and github-pr-review skill

Update PROMPT_review.md: rename copilot-reviews.md to pr-reviews.md, replace 'be especially skeptical of Copilot' with provider-calibrated verification (all: verify independently; Copilot: high FP rate; Greptile: codebase-aware higher accuracy; Human: highest priority). Add guidance for reading Greptile summary (confidence score, mermaid diagrams). Update manifest format docs for comment_type field. Update github-pr-review skill in resources/skills/rl/.

## Acceptance Criteria

PROMPT_review.md references pr-reviews.md, has provider-calibrated triage, documents comment_type manifest field. github-pr-review skill updated.

