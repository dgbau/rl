---
id: rl-efg3
status: closed
deps: []
links: []
created: 2026-02-21T18:10:23Z
type: task
priority: 1
assignee: ""
tags: [bootstrap, prompt]
---
# Bootstrap should not hard-code 3-8 ticket limit

PROMPT_bootstrap.md hard-codes '3-8 chunky task tickets' as a guideline. This is too rigid — large projects need more tickets, small changes need fewer. The bootstrap prompt should size tickets for quality and functionality, not hit an arbitrary count. Update the prompt to guide toward right-sized tickets based on project complexity.

## Acceptance Criteria

PROMPT_bootstrap.md no longer mandates 3-8 tickets. Guideline is based on ticket quality (each produces working tested code) rather than count.

