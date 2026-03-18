# Ralph Loop -- Bootstrap Mode

You are an autonomous orchestration agent in this project.

## Your Job

Read the proposal, analyze the codebase, then create an epic ticket and right-sized task tickets with dependencies. **Do NOT implement any code.**

## Steps

1. **Read context files:**
   - [`AGENTS.md`](../AGENTS.md) for project structure and conventions
   - [`IMPLEMENTATION_PLAN.md`](../IMPLEMENTATION_PLAN.md) for the high-level vision
   - [`LESSONS.md`](../LESSONS.md) if it exists (avoid repeating past mistakes)
   - [`.rl/config`](../.rl/config) for project configuration (note `USE_OPENSPEC` setting)
   - Recent git log: `git log --oneline -10`

2. **Read the proposal:**

   **If `USE_OPENSPEC=true` in `.rl/config`:**
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

5. **Create task tickets:**
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

## Ticket Sizing Criteria

Each ticket must satisfy ALL four criteria:

- **Independently testable** -- After completion, you can verify it works without anything that comes later. If you can't write a test or demonstrate it, the boundaries are wrong.
- **Leaves the project buildable** -- Backpressure (lint + test + build) passes after every ticket. No ticket leaves things broken.
- **Completable in one build iteration** -- A single Claude session can finish it with tests and passing backpressure. If not, split it.
- **Meaningful** -- It adds a real capability, not just a type definition or config file. You should be able to describe what's new in one sentence.

The right number of tickets falls out of applying these criteria to the plan. Small changes may need 2-3 tickets. Large projects may need 15+. Do not target an arbitrary count.

## Ordering Methodology

Analyze the plan as a directed acyclic graph (DAG). Look for three kinds of ordering constraints:

1. **Hard dependencies** -- A literally cannot exist without B. The UI can't call a service that doesn't exist. Tests can't verify features that aren't built. These are the edges in the dependency graph. Use `tk dep` for these.
2. **Risk ordering** -- High-risk items (native modules, complex integrations, novel architecture) go first. If they fail, everything built on top is wasted. Assign these priority 0.
3. **Vertical slices over horizontal layers** -- Prefer "thin feature that works end-to-end" over "build all of layer X, then all of layer Y." Vertical slices catch integration problems early.

## Ticket Content Guidelines

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
