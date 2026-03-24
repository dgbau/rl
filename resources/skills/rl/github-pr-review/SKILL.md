---
name: github-pr-review
description: "Fetching and addressing GitHub PR review comments from Copilot, Greptile, and human reviewers. Includes provider-calibrated triage, verification, ticket management, and conditional spec updates. Use when in review mode or when PR feedback needs to be addressed."
---

# GitHub PR Review

The Ralph Loop pulls all PR review comments (Copilot, Greptile, and human), triages them with provider-calibrated skepticism, and acts on each according to its classification.

## Fetching Reviews

Reviews are fetched automatically by `rl loop review`. The fetcher (`libexec/rl-fetch-reviews`) writes to `.rl/pr-reviews.md` with comments grouped by source:
- **Greptile Summary** (issue comment with confidence score and analysis)
- **Human Review Comments** (highest priority)
- **Greptile Review Comments** (codebase-aware inline findings)
- **Copilot/Bot Review Comments**
- **Review Summaries** (top-level review comments)

Each comment includes: author, file path, line number, comment body, and diff hunk. Issue comments (Greptile summary) use `issue_comment_id` instead of `comment_id`.

## Triage Categories

| Category | Examples | Action |
|----------|----------|--------|
| **Code fix** | Bug, missing null check, style issue, unused import | Fix code directly, note on ticket |
| **Design concern** | "This API should be paginated", "Consider using X pattern" | Amend ticket or create new task |
| **Spec gap** | "What happens when user has no permissions?", "Edge case not handled" | Update specs (if `USE_OPENSPEC=true` in `.rl/config`) or note in `LESSONS.md` |
| **Invalid** | Misread diff, already fixed, doesn't apply | Document why, skip |

## Provider-Calibrated Verification

Before acting on any comment, calibrate your skepticism by provider:

| Provider | Trust level | Guidance |
|----------|-------------|----------|
| **Human** | Highest priority | May reflect business context or domain knowledge not visible in code |
| **Greptile** | Codebase-aware, generally reliable | Has indexed the full repo — findings tend to be accurate. Still verify. |
| **Copilot** | High false-positive rate | Often flags style preferences or suggests breaking changes. Verify thoroughly. |

For all providers:
1. **Read the actual current code** (not just the diff hunk -- hunks can be stale)
2. **Check if already fixed** by a subsequent commit
3. **Verify the claim** -- is the reviewer correct about the behavior?
4. **Assess impact** -- will the suggested change break anything?

### Reading Greptile Summaries

When a Greptile summary is present in `pr-reviews.md`:
- Read the **confidence score** for analysis certainty
- Read **mermaid diagrams** if present for change impact visualization
- The summary provides context, but **individual inline findings are what need triage**

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

### Spec Gap (if USE_OPENSPEC=true in .rl/config)

When `USE_OPENSPEC=true` is set in `.rl/config`, spec gaps should be addressed in OpenSpec:

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

## Replying to and Resolving Comments

After fixing code and pushing, reply to each PR comment and resolve its thread.

### Comment ID Extraction

The review fetcher embeds comment IDs and GraphQL node IDs as HTML comments in the markdown output:

**Review comments** (inline — Copilot, Greptile, human):
```
<!-- comment_id: 12345678 node_id: PRR_kwDOxxxxxxx -->
```

**Issue comments** (timeline — Greptile summary):
```
<!-- issue_comment_id: 99999999 -->
```

The repository and PR number are in the header:
```
# PR Review Comments (PR #42)
Repository: `owner/repo`
```

### Manifest `comment_type` Field

The review manifest (`.rl/review-manifest.json`) uses `comment_type` to route replies:
- `"review"` — reply via PR comment API + resolve thread
- `"issue"` — reply via issue comment API (no thread resolution)

### Replying via GitHub API

```bash
# Get the fix commit SHA
COMMIT_SHA=$(git rev-parse --short HEAD)

# Reply to a specific comment
gh api "repos/{owner}/{repo}/pulls/{pr}/comments/{comment_id}/replies" \
  -f body="Fixed in ${COMMIT_SHA} — <brief description>"
```

### Resolving Threads via GraphQL

After replying, resolve the thread so it collapses in the PR:

```bash
# Get the thread ID from the comment's node_id
THREAD_ID=$(gh api graphql -f query='
  query {
    node(id: "{node_id}") {
      ... on PullRequestReviewComment {
        pullRequestReviewThread { id }
      }
    }
  }' --jq '.data.node.pullRequestReviewThread.id')

# Resolve the thread
gh api graphql -f query="
  mutation {
    resolveReviewThread(input: {threadId: \"$THREAD_ID\"}) {
      thread { isResolved }
    }
  }"
```

### Reply Guidelines

| Category | Reply |
|----------|-------|
| **Code fix** | "Fixed in `abc1234` — added null check for empty array case" |
| **Design concern** | "Tracked in ticket `pro-xxxx` for follow-up" |
| **Invalid** | "This doesn't apply — the variable is used in the closure on line N" |
| **Spec gap** | "Added to LESSONS.md / updated spec" |

- Keep replies concise (1-2 sentences)
- Always reference the commit SHA for code fixes
- For review comments (`comment_type: "review"`), always resolve the thread after replying (issue comments cannot be resolved)

## PR Safety

Ralph **never** merges or closes PRs. The review mode uses the [GitHub CLI](https://cli.github.com/) to:
- Create draft PRs (`gh pr create --draft`)
- Mark PRs as ready (`gh pr ready`)
- Edit PR descriptions (`gh pr edit`)
- Reply to review comments (`gh api .../replies`)

That's it. A human always performs the final merge.
