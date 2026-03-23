# Design: Greptile Review Provider Support

## Technical Approach

### Config Model

Two independent booleans in `.rl/config` and `ralphrc.template`:

```bash
USE_COPILOT_REVIEWS=true    # default true (backward compat)
USE_GREPTILE_REVIEWS=false   # default false (opt-in)
```

Both can be `true` simultaneously. The loop reads these to decide which providers to re-trigger and which comments to fetch.

### GitHub Comment Types

GitHub PRs have three distinct comment surfaces:

| Type | Endpoint | Used by |
|------|----------|---------|
| Review comments (inline) | `GET /repos/{o}/{r}/pulls/{pr}/comments` | Copilot, Greptile (inline findings), humans |
| Review summaries | `GET /repos/{o}/{r}/pulls/{pr}/reviews` | Copilot (formal review), humans |
| Issue comments (timeline) | `GET /repos/{o}/{r}/issues/{pr}/comments` | Greptile (summary + findings), bots, humans |

Greptile posts its **summary** as an issue comment and may post **inline findings** as review comments. The current fetch only hits the first two endpoints — we need to add the third.

### Author Detection

| Provider | Login pattern | `author_type` value |
|----------|--------------|---------------------|
| Copilot | `copilot-pull-request-reviewer` | `"copilot"` |
| Greptile | `greptile[bot]` or contains `greptile` | `"greptile"` |
| Other bots | `user.type == "Bot"` | `"bot"` |
| Humans | everything else | `"human"` |

### Fetch Changes (`rl-fetch-reviews`)

1. **New endpoint**: When `USE_GREPTILE_REVIEWS=true`, also fetch `GET /repos/{o}/{r}/issues/{pr}/comments`
2. **Filter**: Only include issue comments from Greptile (don't pull in random bot noise)
3. **Merge**: Issue comments get their own section in the output markdown, separate from inline comments
4. **No resolved-thread filtering for issue comments**: Issue comments don't have GitHub's thread resolution mechanism — instead, track "already seen" comment IDs to detect new-vs-old across iterations

### Output File Format (`pr-reviews.md`)

```markdown
# PR Review Comments (PR #123)

Branch: `feature/foo`
Repository: `org/repo`
Fetched: 2026-03-23 12:00:00 UTC

## Greptile Summary
<!-- issue_comment_id: 99999 -->

[Full Greptile summary with confidence score, file breakdown, diagrams]

## Review Summaries
### copilot-pull-request-reviewer (copilot) -- COMMENTED -- 2026-03-23T...
<!-- review_id: 111 -->
[Copilot review summary body]

## Human Review Comments (2)
### alice: `src/foo.ts` (line 42)
<!-- comment_id: 222 node_id: ABC -->
> [comment body]

## Greptile Review Comments (3)
### greptile[bot]: `src/bar.ts` (line 15)
<!-- comment_id: 333 node_id: DEF -->
> [inline finding]

## Copilot/Bot Review Comments (1)
### copilot-pull-request-reviewer: `src/baz.ts` (line 7)
<!-- comment_id: 444 node_id: GHI -->
> [comment body]
```

Key changes:
- Greptile summary gets its own top-level section (visible context, not actionable inline)
- Greptile inline comments get their own section (separate from Copilot/bot)
- Issue comments carry `issue_comment_id` (not `comment_id`) to distinguish reply mechanism

### Reply Changes (`rl-reply-reviews`)

The manifest gains a `comment_type` field:

```json
[
  {
    "comment_id": 333,
    "comment_type": "review",
    "category": "code-fix",
    "reply": "[Ralph] Fixed...",
    "resolve": true
  },
  {
    "comment_id": 99999,
    "comment_type": "issue",
    "category": "code-fix",
    "reply": "[Ralph] Fixed...",
    "resolve": false
  }
]
```

- `"review"` comments: reply via `POST /pulls/{pr}/comments` with `in_reply_to` + resolve thread (existing)
- `"issue"` comments: reply via `POST /issues/{pr}/comments` (new — just posts a reply, no thread resolution)

### Loop Changes (`rl-loop` review mode)

**Re-triggering** (replaces broken `gh pr edit --add-reviewer @copilot`):

```zsh
# Greptile: post @greptileai comment to re-trigger
if [[ "$USE_GREPTILE_REVIEWS" == "true" ]]; then
  gh api "repos/$REPO_FULL/issues/$pr_num/comments" \
    -X POST -f body="@greptileai" 2>/dev/null || true
fi

# Copilot: re-request review (keep for compat, even though it rarely works)
if [[ "$USE_COPILOT_REVIEWS" == "true" ]]; then
  gh pr edit "$pr_num" --add-reviewer "@copilot" 2>/dev/null || true
fi
```

**Exit condition** — "no new reviews" detector:

Track the set of comment IDs fetched each iteration. If a re-trigger produces zero new comment IDs compared to the previous iteration, the reviewer is satisfied — exit the loop. This prevents infinite cycling when Greptile re-reviews and posts no new comments.

```
Iteration 1: fetch → IDs {100, 101, 102} → fix → push → re-trigger → wait
Iteration 2: fetch → IDs {100, 101, 102} → no new IDs → exit ✓
```

Implementation: write fetched comment IDs to `.rl/last-review-ids.txt`, compare on next fetch.

### Prompt Changes (`PROMPT_review.md`)

- Rename reference from `copilot-reviews.md` to `pr-reviews.md`
- Replace "be especially skeptical of Copilot" with provider-calibrated guidance:
  - **All sources**: Independently verify every claim against current code
  - **Copilot**: Higher false-positive rate — verify extra carefully, especially style suggestions
  - **Greptile**: Codebase-aware, higher accuracy — still verify, but findings are generally reliable
  - **Human**: Highest priority, may reflect business context not visible in code
- Add: Greptile summary section should be read for context (confidence score, change analysis) but individual findings are what need triage
- Add: Mermaid diagrams in Greptile summaries are useful context — read them if present

### Lessons Pipeline (Future)

Greptile reviews (and all reviews) are valuable lesson material. The current LESSONS.md append mechanism exists but the review prompt only uses it for spec gaps. A future enhancement could:
- Auto-extract patterns from review comments that reveal non-obvious conventions
- Feed accepted review findings into skill updates via the review-to-skill pipeline

This is noted in the proposal but NOT in scope for this change.

## Key Decisions

1. **Two booleans, not a string**: `USE_COPILOT_REVIEWS` + `USE_GREPTILE_REVIEWS` rather than `REVIEW_PROVIDER="copilot,greptile"` — cleaner, no parsing, easy to toggle independently.

2. **Issue comments fetched only for Greptile**: We don't want to pull every bot comment from the timeline — only Greptile's. Filter by author during fetch.

3. **Separate sections in output**: Greptile summary, Greptile inline, Copilot inline, and human comments each get distinct sections so the review agent can apply appropriate trust calibration.

4. **Backward compatible defaults**: `USE_COPILOT_REVIEWS=true`, `USE_GREPTILE_REVIEWS=false` — existing users see no change.

5. **Comment ID tracking for exit**: Rather than a timer or fixed iteration count, track actual comment IDs to detect "no new feedback" — a reliable signal that the reviewer is satisfied.
