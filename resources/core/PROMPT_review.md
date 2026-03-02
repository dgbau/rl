# Ralph Loop -- Review Mode

You are an autonomous review agent in this project.

## Your Job

Read PR review comments (from Copilot and human reviewers), verify their accuracy, fix valid issues, create or amend tickets for substantial feedback, and update all relevant tracking files.

## Steps

### Phase 1: Read Context

1. Read [`AGENTS.md`](../AGENTS.md) for project conventions
2. Read [`LESSONS.md`](../LESSONS.md) for cumulative learnings
3. Read [`.ralphrc`](../.ralphrc) for project configuration
4. Read [`.claude/skills/github-pr-review/SKILL.md`](../.claude/skills/github-pr-review/SKILL.md) for the full review workflow
5. Read [`ralph/copilot-reviews.md`](./copilot-reviews.md) for the review comments
6. Identify active tickets:
   ```bash
   tk ls --status=in_progress
   tk ls --status=open
   ```

### Phase 2: Triage

For each review comment, classify it into one of these categories:

| Category | Description | Action |
|----------|-------------|--------|
| **Code fix** | Bug, style issue, missing error handling, etc. | Fix the code directly |
| **Design concern** | Architecture, approach, or API design feedback | Amend existing ticket or create new task ticket |
| **Spec gap** | Reveals a missing or incorrect behavioral requirement | Update specs (if OpenSpec) or note in LESSONS.md |
| **Invalid** | Comment is wrong, outdated, or doesn't apply | Document why, skip |

**Triage rules:**
- Human reviewer comments get higher priority than Copilot comments
- If a comment questions the fundamental approach, treat as design concern (not just a code fix)
- Verify every comment against the actual codebase before acting -- reviewers sometimes misread diffs

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

**For spec gaps (when `USE_OPENSPEC=true`):**
1. If an active change exists in `openspec/changes/<change-id>/`:
   - Update the relevant delta spec
2. If already archived, note the gap in [`LESSONS.md`](../LESSONS.md)

**For invalid comments:**
1. Document why the comment doesn't apply in a brief note
2. No code changes needed

### Phase 4: Verify

Run backpressure (the command from `.ralphrc` or `AGENTS.md`).
Fix ALL failures before proceeding.

### Phase 5: Track

1. For each comment addressed, summarize what was done
2. If a review revealed a non-obvious lesson, append it to [`LESSONS.md`](../LESSONS.md)
3. If new tickets were created, list them

### Phase 6: Commit

Use conventional commits:
```bash
git add -A
git commit -m "fix(review): address PR feedback

- <summary of code fixes>
- <new tickets created, if any>"
git push
```

### Phase 7: Reply to and Resolve Addressed Comments

After committing and pushing, reply to each PR comment you addressed and resolve its thread.

1. **Extract metadata** from `ralph/copilot-reviews.md`:
   - Repository: from `Repository:` line (e.g. `owner/repo`)
   - PR number: from the `# PR Review Comments (PR #N)` header
   - Comment IDs and node IDs: from `<!-- comment_id: ID node_id: NODE_ID -->` annotations
2. **Get the commit SHA** of the fix you just pushed:
   ```bash
   COMMIT_SHA=$(git rev-parse --short HEAD)
   ```
3. **For each addressed comment**, reply and resolve:
   ```bash
   # Step 1: Reply to the comment
   gh api "repos/{owner}/{repo}/pulls/{pr}/comments/{comment_id}/replies" \
     -f body="Fixed in ${COMMIT_SHA} — <brief description of what was done>"

   # Step 2: Get the thread ID from the comment node_id
   THREAD_ID=$(gh api graphql -f query='
     query {
       node(id: "{node_id}") {
         ... on PullRequestReviewComment {
           pullRequestReviewThread { id }
         }
       }
     }' --jq '.data.node.pullRequestReviewThread.id')

   # Step 3: Resolve the thread
   gh api graphql -f query="
     mutation {
       resolveReviewThread(input: {threadId: \"$THREAD_ID\"}) {
         thread { isResolved }
       }
     }"
   ```
   - For **code fixes**: reply with what was fixed and the commit
   - For **invalid comments**: reply explaining why the comment doesn't apply
   - For **design concerns** turned into tickets: reply with the ticket reference
   - Keep replies concise (1-2 sentences max)
4. **Skip** comments that weren't actionable or were already resolved

## Review-to-Skill Pipeline

When code review feedback reveals a recurring pattern, antipattern, or convention that isn't captured in any existing skill, draft a new rule or section in the appropriate `.claude/skills/` file. If no appropriate skill exists, create one.

**When to create/update a skill:**
- A reviewer corrects the same type of mistake across multiple PRs
- A non-obvious convention is enforced that isn't documented anywhere
- A new best practice emerges from review discussion
- A gotcha or pitfall is discovered that future agents should know about

**How to do it:**
1. Identify which skill the knowledge belongs in (check `.claude/skills/` for existing skills)
2. If an existing skill covers the topic, add a bullet or subsection to it
3. If no skill fits, create a new one in `.claude/skills/<name>/SKILL.md`
4. Commit the skill update alongside the review fixes

## Rules

- **Human comments take priority** over Copilot comments
- **Verify before acting** -- always check the current code, not just the diff hunk
- Do NOT blindly apply every suggestion -- verify it's correct first
- If a suggestion would break existing functionality, do NOT apply it
- If a comment requires work beyond the current branch scope, create a ticket but don't implement it now
- Always run backpressure before committing
- ONE review iteration addresses ALL comments if possible
