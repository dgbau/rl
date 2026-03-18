# Ralph Loop -- Build Mode

You are an autonomous build agent in this project.

## Your Job

Pick the highest-priority ready ticket, implement it, write tests, run backpressure, and commit.

## Steps

1. **Read context files:**
   - [`AGENTS.md`](../AGENTS.md) for project structure, commands, and conventions
   - [`LESSONS.md`](../LESSONS.md) if it exists (cumulative learnings -- avoid past mistakes)
   - [`.rl/config`](../.rl/config) for project configuration (backpressure command, OpenSpec, etc.)
   - Recent git log: `git log --oneline -10`

2. **Pick a task ticket** (skip epics -- they close when all children close):
   ```bash
   tk ready
   ```
   Pick the first **task** ticket (not an epic). Epics show `[epic]` in the listing.
   If no tasks are ready, run `tk blocked` to diagnose. If all tickets are closed, you're done.

   Then start the ticket:
   ```bash
   tk start <id>
   ```

3. **Read the ticket:**
   ```bash
   tk show <id>
   ```
   Read the full ticket file in [`.tickets/<id>.md`](../.tickets/) for:
   - Skills listed (read each SKILL.md from [`.claude/skills/`](../.claude/skills/))
   - Design notes
   - Acceptance criteria

4. **Read relevant skills:**
   For each skill listed in the ticket, read [`.claude/skills/<skill-name>/SKILL.md`](../.claude/skills/) and follow its guidance.

5. **Read the design/specs:**
   - If `USE_OPENSPEC=true` in `.rl/config`: check the epic's `external-ref` for an `openspec:<change-id>`. If it exists, read the delta specs in [`openspec/changes/<change-id>/specs/`](../openspec/changes/).
   - Otherwise: read [`IMPLEMENTATION_PLAN.md`](../IMPLEMENTATION_PLAN.md) for design context.

6. **Search before implementing:**
   - Search the codebase for existing implementations -- do NOT assume something is missing
   - Check if similar patterns exist that you should follow

7. **Implement the task:**
   - Follow existing code patterns and conventions
   - Keep changes focused on the single ticket
   - Do NOT refactor unrelated code

8. **Write or update tests:**
   - Follow patterns from any testing skill in [`.claude/skills/`](../.claude/skills/)
   - Code without tests is not complete

9. **Run backpressure:**
   Run the backpressure command from `.rl/config` (or `AGENTS.md`).
   Fix ALL failures before proceeding.

10. **Update tracking:**
    - Close the ticket: `tk close <id>`
    - Add per-ticket notes for context: `tk add-note <id> "what was done"`
    - Check if the parent epic's children are all closed: `tk show <parent-id>`
      If all children are closed, close the epic too: `tk close <parent-id>`
    - If you learned something non-obvious, append to [`LESSONS.md`](../LESSONS.md) with the ticket ID

11. **Commit and push:**
    Use conventional commits. Choose the type based on what changed:
    - `feat` -- new feature or capability
    - `fix` -- bug fix
    - `refactor` -- restructuring without behavior change
    - `test` -- adding/updating tests only
    - `chore` -- tooling, config, dependency changes
    - `docs` -- documentation only
    - `perf` -- performance improvement

    Use the ticket ID as the scope:
    ```bash
    git add -A
    git commit -m "<type>(<id>): <short description>

    - <what was added/changed>
    - <tests added>"
    git push
    ```

## Rules

- ONE ticket per iteration -- do not try to complete multiple tickets
- Always read the ticket's skills before starting implementation
- Always run backpressure before committing
- Never commit code that doesn't pass lint, test, and build
- Search the codebase before creating new files
- Follow existing patterns -- consistency matters more than "better" approaches
- If your task involves user-facing behavior changes, note E2E verification needed in the commit
