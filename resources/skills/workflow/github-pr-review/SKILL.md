---
name: github-pr-review
description: "Fetching and addressing GitHub PR review comments from Copilot and human reviewers. Includes triage, verification, ticket management, and conditional spec updates. Use when in review mode or when PR feedback needs to be addressed."
---

# GitHub PR Review

The Ralph Loop pulls all PR review comments (Copilot + human), triages them, and acts on each according to its classification.

## Fetching Reviews

```bash
./ralph/fetch-reviews.sh
```

This writes to [`ralph/copilot-reviews.md`](../../ralph/copilot-reviews.md) with comments grouped by source:
- **Human Review Comments** (higher priority)
- **Copilot/Bot Review Comments**
- **Review Summaries** (top-level review comments)

Each comment includes: author, file path, line number, comment body, and diff hunk.

## Triage Categories

| Category | Examples | Action |
|----------|----------|--------|
| **Code fix** | Bug, missing null check, style issue, unused import | Fix code directly, note on ticket |
| **Design concern** | "This API should be paginated", "Consider using X pattern" | Amend ticket or create new task |
| **Spec gap** | "What happens when user has no permissions?", "Edge case not handled" | Update specs (if `USE_OPENSPEC=true` in `.ralphrc`) or note in `LESSONS.md` |
| **Invalid** | Misread diff, already fixed, doesn't apply | Document why, skip |

## Verification Protocol

Before acting on any comment:

1. **Read the actual current code** (not just the diff hunk -- hunks can be stale)
2. **Check if already fixed** by a subsequent commit
3. **Verify the claim** -- is the reviewer correct about the behavior?
4. **Assess impact** -- will the suggested change break anything?

## Acting on Comments

### Code Fix
```bash
# Fix the code, then:
tk add-note <ticket-id> "Fixed per review: <summary>"
```

### Design Concern --> Amend Ticket
```bash
# If within scope of existing ticket:
tk add-note <ticket-id> "Design feedback: <summary>"
# Then edit .tickets/<id>.md to update Design section

# If new scope:
tk create "<title>" -t task --parent <epic-id> -p 2 \
  -d "<description>" --acceptance "<done criteria>"
```

### Spec Gap (if USE_OPENSPEC=true in .ralphrc)

When `USE_OPENSPEC=true` is set in `.ralphrc`, spec gaps should be addressed in OpenSpec:

```
# If active change exists:
# Edit openspec/changes/<change-id>/specs/<domain>/spec.md
# Add missing requirements in ADDED or MODIFIED sections

# If already archived:
# Append to LESSONS.md for next change cycle
```

When OpenSpec is not enabled, record spec gaps in [`LESSONS.md`](../../LESSONS.md) for future reference.

### Invalid
No code changes. Optionally document reasoning in commit message.

## PR Safety

Ralph **never** merges or closes PRs. The review mode uses the [GitHub CLI](https://cli.github.com/) to:
- Create draft PRs (`gh pr create --draft`)
- Mark PRs as ready (`gh pr ready`)
- Edit PR descriptions (`gh pr edit`)

That's it. A human always performs the final merge.
