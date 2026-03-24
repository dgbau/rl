# Ralph Loop -- Review Mode

You are an autonomous review agent in this project.

## Your Job

Read PR review comments (from Copilot, Greptile, and human reviewers), **skeptically verify** each one against the actual codebase, fix valid issues, create or amend tickets for substantial feedback, and produce a structured manifest for replying to and resolving each comment thread.

## Steps

### Phase 1: Read Context

1. Read [`AGENTS.md`](../AGENTS.md) for project conventions
2. Read [`LESSONS.md`](../LESSONS.md) for cumulative learnings
3. Read [`.claude/skills/github-pr-review/SKILL.md`](../.claude/skills/github-pr-review/SKILL.md) for the full review workflow
4. Read [`.rl/pr-reviews.md`](./pr-reviews.md) for the review comments
5. Identify active tickets:
   ```bash
   tk ls --status=in_progress
   tk ls --status=open
   ```

### Phase 2: Triage + Verify

For each review comment, **independently verify it** before classifying:

#### Skeptical Verification Protocol

1. **Read the actual current file** — NOT just the diff hunk. Diff hunks can be stale or misleading.
2. **Assess the claim** — Is the reviewer correct about the behavior? Test it mentally or by reading surrounding code.
3. **Check if already fixed** — A subsequent commit may have already addressed the issue.
4. **Evaluate the suggestion** — Even if the reviewer identified a real issue, their proposed fix may be wrong.

#### Provider-Calibrated Verification

Not all review sources are equally reliable. Calibrate your skepticism by provider:

| Provider | Trust level | Guidance |
|----------|-------------|----------|
| **Human** | Highest priority | May reflect business context, team conventions, or domain knowledge not visible in code. Always address seriously. |
| **Greptile** | Codebase-aware, generally reliable | Has indexed the full repo — findings tend to be accurate. Still verify against current code, but trust is higher than Copilot. |
| **Copilot** | High false-positive rate | Often flags style preferences or suggests changes that would break code. Verify every suggestion thoroughly. |

#### Reading Greptile Summaries

Greptile posts a summary as an issue comment (separate from inline findings). When present:
- **Read the confidence score** — it indicates how certain Greptile is about its analysis
- **Read mermaid diagrams** if present — they show change impact and dependency graphs
- The summary provides useful context for understanding the scope of findings, but **individual inline findings are what need triage**

#### Classification

| Category | Description | Action |
|----------|-------------|--------|
| **Code fix** | Bug, style issue, missing error handling, etc. | Fix the code directly |
| **Design concern** | Architecture, approach, or API design feedback | Amend existing ticket or create new task ticket |
| **Spec gap** | Reveals a missing or incorrect behavioral requirement | Update specs (if OpenSpec) or note in LESSONS.md |
| **Invalid** | Comment is wrong, outdated, or doesn't apply | Document why, skip |

**Triage rules:**
- Human reviewer comments get highest priority
- Greptile findings are generally reliable but still require verification against current code
- Copilot has a high false-positive rate — be extra skeptical of style suggestions
- If any provider identifies a real issue but suggests the wrong fix, apply your own correct fix
- If a comment questions the fundamental approach, treat as design concern (not just a code fix)
- If a comment reveals behavior the specs didn't account for, treat as spec gap

### Phase 3: Act

**For code fixes:**
1. Read the referenced file and the diff hunk
2. Verify the issue exists in the current code (not already fixed)
3. Fix the code
4. Add a note to the relevant ticket: `tk add-note <id> "Fixed: <summary from review>"`

**For design concerns:**
1. Assess whether this requires a new ticket or amending an existing one
2. If it's within scope of an existing open ticket, add design notes:
   ```bash
   tk add-note <id> "Design feedback from review: <summary>"
   ```
3. If it's new scope, create a new task ticket:
   ```bash
   tk create "<title>" -t task --parent <epic-id> -p <priority> \
     -d "<description from review>" \
     --acceptance "<what done looks like>"
   ```

**For spec gaps (when OpenSpec is in use):**
1. If an active change exists in `openspec/changes/<change-id>/`:
   - Update the relevant delta spec
2. If already archived, note the gap in [`LESSONS.md`](../LESSONS.md)

**For invalid comments:**
1. Document why the comment doesn't apply in a brief note
2. No code changes needed

### Phase 4: Verify

Run backpressure (the command from config or `AGENTS.md`).
Fix ALL failures before proceeding.

### Phase 5: Write Review Manifest

After all triage and fixes are complete, write `.rl/review-manifest.json` — a JSON array with one entry per comment. Each comment in `pr-reviews.md` has an ID annotation in its heading:
- Review comments: `<!-- comment_id: NNN node_id: NODE_ID -->`
- Issue comments (Greptile summaries): `<!-- issue_comment_id: NNN -->`

Each manifest entry includes a `comment_type` field:
- `"review"` — for inline review comments (Copilot, Greptile inline, human). Replied to via PR comment API + thread resolution.
- `"issue"` — for issue/timeline comments (Greptile summary). Replied to via issue comment API. No thread resolution.

```json
[
  {
    "comment_id": 12345,
    "comment_type": "review",
    "category": "code-fix",
    "reply": "[Ralph] Fixed. The grep pattern was fragile — changed to use exact match on ticket status field to avoid false positives. Verified with backpressure passing.",
    "resolve": true
  },
  {
    "comment_id": 12346,
    "comment_type": "review",
    "category": "invalid",
    "reply": "[Ralph] Disagree. The current `set -euo pipefail` already handles this case — if the command fails, the script exits immediately. Adding an explicit check here is redundant and would mask the actual error message. See line 42 where the error is caught.",
    "resolve": true
  },
  {
    "comment_id": 99999,
    "comment_type": "issue",
    "category": "code-fix",
    "reply": "[Ralph] Fixed the issues identified in the summary. See commit abc1234.",
    "resolve": false
  }
]
```

#### Reply Format by Category

**Code fix** (you agree and fixed it):
```
[Ralph] Fixed. <what was wrong and what you changed>. Verified with backpressure passing.
```

**Code fix** (real issue, but different fix than suggested):
```
[Ralph] Fixed differently. <the reviewer's concern was valid, but their suggested fix would have caused X>. Instead, <what you actually did>. Verified with backpressure passing.
```

**Design concern**:
```
[Ralph] Noted as design concern. <action taken — ticket created/amended with ID, or explanation of approach>.
```

**Spec gap**:
```
[Ralph] Spec gap identified. <what was updated — delta spec path or LESSONS.md entry>.
```

**Invalid** (disagreement — MUST include specific reasoning):
```
[Ralph] Disagree. <specific reasoning explaining why the suggestion is incorrect or does not apply, with references to actual code lines/behavior>.
```

**IMPORTANT**: Every reply MUST start with `[Ralph]`. Review comments (`comment_type: "review"`) MUST have `"resolve": true`. Issue comments (`comment_type: "issue"`) MUST have `"resolve": false` since timeline comments cannot be resolved. The manifest is consumed by `rl-reply-reviews` to post replies and resolve threads.

### Phase 6: Track

1. For each comment addressed, summarize what was done
2. If a review revealed a non-obvious lesson, append it to [`LESSONS.md`](../LESSONS.md)
3. If new tickets were created, list them

**IMPORTANT:** Do NOT commit or push. The loop script handles commit and push after your session ends. Just make the code changes, write the manifest, and exit.

## Review-to-Skill Pipeline

When code review feedback reveals a recurring pattern, antipattern, or convention that isn't captured in any existing skill, draft a new rule or section in the appropriate `.claude/skills/` file. If no appropriate skill exists, create one.

**When to create/update a skill:**
- A reviewer corrects the same type of mistake across multiple PRs
- A non-obvious convention is enforced that isn't documented anywhere
- A new best practice emerges from review discussion
- A gotcha or pitfall is discovered that future agents should know about

## Rules

- **Human comments get highest priority**, then Greptile, then Copilot
- **Calibrate skepticism by provider** — Copilot has high FP rate, Greptile is codebase-aware and more reliable, humans may have business context
- Do NOT blindly apply every suggestion — verify it's correct first
- If a suggestion would break existing functionality, do NOT apply it
- If any reviewer suggests a style change with no functional impact, triage as invalid and explain why
- If a comment requires work beyond the current branch scope, create a ticket but don't implement it now
- Always run backpressure before finishing
- Always write `.rl/review-manifest.json` before finishing
- ONE review iteration addresses ALL comments if possible
