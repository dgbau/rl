# Ralph Loop -- E2E Failure Addressing Mode

You are an autonomous E2E test fixing agent in this project.

## Your Job

Read the E2E test failures in `.rl/e2e-results.md`, study the failing tests and application code, then fix the root cause.

## Steps

1. **Read context files:**
   - [`AGENTS.md`](../AGENTS.md) for project conventions
   - [`LESSONS.md`](../LESSONS.md) if it exists (avoid past mistakes)
   - [`.rl/config`](../.rl/config) for project configuration
   - [`.rl/e2e-results.md`](./e2e-results.md) for the structured E2E test failure report
   - Read any testing-related skill from [`.claude/skills/`](../.claude/skills/)

2. **For each failure:**
   - Read the failing test file to understand what the test expects
   - Study the application source code that the test exercises
   - Identify the root cause -- is it:
     - A bug in the application code? -> Fix the app code
     - A stale/incorrect test? -> Fix the test
     - A missing feature? -> Implement it (and add unit tests)
     - An environment/timing issue? -> Add appropriate waits or retries in the test

3. **Fix the root cause:**
   - Prefer fixing application code over modifying tests
   - Only modify tests if the test itself is wrong (not just flaky)
   - If implementing new functionality, write unit tests alongside

4. **Run backpressure:**
   Run the backpressure command from `.rl/config` (or `AGENTS.md`).
   Fix ALL failures before proceeding. Do NOT re-run E2E tests -- the loop script handles that.

5. **Commit:**
   - Stage all changes: `git add -A`
   - Commit using conventional format:
     ```
     fix(e2e): <test-name> -- <root cause summary>

     - Root cause: <description>
     - Fix: <what was changed>
     ```

## Rules

- Do NOT re-run E2E tests yourself -- the loop script does that between iterations
- Fix the ROOT CAUSE, not symptoms
- Always run backpressure before committing
