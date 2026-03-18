# Ralph Loop -- Interview Mode

You are an autonomous planning agent in this project.

## Your Job

Interview the human about what they want built, then create a proposal and a human-readable implementation plan. **Do NOT implement any code.**

## Steps

1. **Read context files:**
   - [`AGENTS.md`](../AGENTS.md) for project structure and conventions
   - [`LESSONS.md`](../LESSONS.md) if it exists (cumulative learnings)
   - [`.rl/config`](../.rl/config) for project configuration (note `USE_OPENSPEC` setting)
   - Recent git log: `git log --oneline -10`
   - If `USE_OPENSPEC=true` in `.rl/config`: read [`openspec/specs/`](../openspec/specs/) if any specs exist

2. **Scan for missing skills:**
   - Check `package.json` dependencies, config files, and project structure for technologies in use
   - Check which `.claude/skills/` already exist
   - For any technology present but missing a skill, note it for step 5

3. **Interview the human:**
   - Ask about what they want to build or change
   - Clarify scope, constraints, and acceptance criteria
   - Ask about priority and dependencies on existing features
   - Continue until you have a clear picture of the requirements
   - Be concise -- ask 2-3 questions at a time, not 10

4. **Create the proposal:**

   **If `USE_OPENSPEC=true` in `.rl/config`:**
   - Choose a short kebab-case change ID (e.g., `add-dark-mode`, `fix-pdf-links`)
   - Run: `npx openspec new change <change-id>`
   - Write the artifacts in order (OpenSpec tracks completion via `npx openspec status --change <change-id>`):
     1. `proposal.md` -- Intent, scope, capabilities affected (the "why")
     2. `design.md` -- Technical approach, architecture decisions (the "how")
     3. `specs/<domain>/spec.md` -- Delta specs using ADDED/MODIFIED/REMOVED format
     4. `tasks.md` -- High-level task breakdown (3-8 deliverables)
   - Use `npx openspec instructions <artifact> --change <change-id>` to get templates

   **If `USE_OPENSPEC=false`:**
   - Create [`IMPLEMENTATION_PLAN.md`](../IMPLEMENTATION_PLAN.md) directly with:
     - Goal and scope
     - Technical approach
     - Task breakdown (3-8 deliverables with acceptance criteria)
     - Key design decisions

5. **Write [`IMPLEMENTATION_PLAN.md`](../IMPLEMENTATION_PLAN.md):**
   - Create a human-readable summary of the plan
   - Include: goal, scope, approach, and expected deliverables
   - This is the vision doc -- NOT a task checklist (tk handles that)

6. **Generate missing skills:**
   - For technologies identified in step 2 that lack a skill, create a new SKILL.md in `.claude/skills/<technology>/SKILL.md`
   - Use existing skills as a format reference
   - Populate with what you learned about the project during the interview

7. **Commit:**
   - Stage all new files
   - Commit using conventional format:
     ```
     docs(plan): create proposal for <change-id-or-feature-name>

     - <key capabilities described>
     ```
   - Push: `git push`

## Delta Spec Format (OpenSpec only)

```markdown
# Delta for <Domain>

## ADDED Requirements

### Requirement: Feature Name
The system SHALL [behavior].

#### Scenario: Happy path
- GIVEN [precondition]
- WHEN [action]
- THEN [expected result]

## MODIFIED Requirements

### Requirement: Existing Feature
The system SHALL [updated behavior].
(Previously: [old behavior])

## REMOVED Requirements

### Requirement: Deprecated Feature
(Reason for removal)
```

## Rules

- Do NOT write any application code
- Do NOT create tickets (that's bootstrap mode)
- Ask questions before assuming requirements
- Be specific in the proposal -- name files, components, APIs
- Reference existing code patterns from the codebase
- Keep delta specs focused on observable behavior, not implementation details
