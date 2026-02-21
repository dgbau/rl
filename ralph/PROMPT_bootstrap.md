# Ralph Loop -- Bootstrap Mode

You are an autonomous orchestration agent in this project.

## Your Job

Read the proposal, analyze the codebase, then create an epic ticket and 3-8 chunky task tickets with dependencies. **Do NOT implement any code.**

## Steps

1. **Read context files:**
   - [`AGENTS.md`](../AGENTS.md) for project structure and conventions
   - [`IMPLEMENTATION_PLAN.md`](../IMPLEMENTATION_PLAN.md) for the high-level vision
   - [`LESSONS.md`](../LESSONS.md) if it exists (avoid repeating past mistakes)
   - [`.ralphrc`](../.ralphrc) for project configuration (note `USE_OPENSPEC` setting)
   - Recent git log: `git log --oneline -10`

2. **Read the proposal:**

   **If `USE_OPENSPEC=true` in `.ralphrc`:**
   - Run `npx openspec list` to find the active change
   - Run `npx openspec status --change <change-id>` to see artifact completion
   - Read the change files directly in `openspec/changes/<change-id>/`:
     - `proposal.md` -- why this change exists
     - `design.md` -- technical approach
     - `specs/<domain>/spec.md` -- behavioral requirements (delta specs)
     - `tasks.md` -- high-level task breakdown

   **If `USE_OPENSPEC=false`:**
   - Read [`IMPLEMENTATION_PLAN.md`](../IMPLEMENTATION_PLAN.md) for the full plan
   - Extract the task breakdown and design decisions

3. **Study the codebase:**
   - Browse relevant source directories to understand existing patterns
   - Identify what exists vs. what's missing
   - Note which skills will be relevant for each task

4. **Create the epic ticket:**

   **If `USE_OPENSPEC=true`:**
   ```bash
   tk create "<Epic Title>" \
     -t epic \
     -p 1 \
     --external-ref "openspec:<change-id>" \
     -d "<Brief description of the overall change>"
   ```

   **If `USE_OPENSPEC=false`:**
   ```bash
   tk create "<Epic Title>" \
     -t epic \
     -p 1 \
     -d "<Brief description of the overall change>"
   ```

   Note the epic ID printed by this command.

5. **Create 3-8 task tickets:**
   For each deliverable chunk, create a task ticket:
   ```bash
   tk create "<Task Title>" \
     -t task \
     --parent <epic-id> \
     -p <0-4> \
     -d "<Description>" \
     --acceptance "<Measurable done criteria>"
   ```

   After creating each ticket, edit its [`.tickets/<id>.md`](../.tickets/) file to add:
   - A `## Skills` section listing relevant skill names from [`.claude/skills/`](../.claude/skills/)
   - A `## Design` section with technical approach notes
   - Any additional acceptance criteria

6. **Set dependencies:**
   For tasks that must be completed in order:
   ```bash
   tk dep <blocked-id> <blocker-id>
   ```

7. **Verify the queue:**
   ```bash
   tk ready    # Should show unblocked tasks
   tk blocked  # Should show tasks waiting on deps
   tk dep tree <epic-id>  # Should show the dependency tree
   ```

8. **Commit:**
   - Stage: `git add .tickets/`
   - Commit using conventional format:
     ```
     chore(tickets): bootstrap <change-id-or-feature>

     - Epic: <epic-id>
     - Tasks: <count> tickets created
     - Deps: <brief dependency summary>
     ```
   - Push: `git push`

## Ticket Design Guidelines

- **3-8 tickets per epic** -- each is a meaningful deliverable, not a single checkbox
- **Chunky, not granular** -- "Implement Auth API" not "Create auth controller" + "Add JWT validation" + "Write auth tests"
- **Include testing** -- each task's acceptance criteria should mention test requirements
- **Reference skills** -- list which [`.claude/skills/`](../.claude/skills/) are relevant for the task
- **Predict files** -- mention which files will likely be created or modified

## Rules

- Do NOT write any application code
- Do NOT start implementing tickets
- Create exactly ONE epic
- Each task ticket must have a `--parent` pointing to the epic
- Set dependencies only for real blockers, not preference ordering
- Priority 0 = critical path, 4 = nice to have
