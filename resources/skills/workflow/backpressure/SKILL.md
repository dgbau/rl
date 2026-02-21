---
name: backpressure
description: "How to run and interpret backpressure checks. Use before committing code to ensure quality gates pass."
---

# Backpressure

Backpressure is the mandatory quality gate that runs before every commit. Nothing gets committed without passing.

## Command

The backpressure command is project-specific. Read it from [`.ralphrc`](../../.ralphrc):

```bash
# Source the config to get BACKPRESSURE_CMD
source .ralphrc
eval "$BACKPRESSURE_CMD"
```

Common examples of `BACKPRESSURE_CMD`:
- `npx nx affected -t lint test build` -- Nx monorepo
- `npm run lint && npm test && npm run build` -- standard npm project
- `make lint test build` -- Makefile-based project
- `cargo clippy && cargo test && cargo build` -- Rust project

If `BACKPRESSURE_CMD` is not set, check [`AGENTS.md`](../../AGENTS.md) for the project's quality gate commands.

## Interpreting Failures

### Lint failures
- Linter errors in changed files (ESLint, clippy, pylint, etc.)
- Fix: read the error, apply the fix, re-run
- Common: unused imports, missing types, formatting issues

### Test failures
- Unit test assertions failing
- Fix: check if test expectation is correct or if implementation has a bug
- If the test is wrong: fix the test
- If the implementation is wrong: fix the implementation

### Build failures
- Compilation errors or build tool failures
- Fix: read the error, fix the type mismatch or missing dependency
- Common: missing exports, incorrect import paths, type mismatches

## Self-Heal Protocol

If backpressure fails after an iteration:
1. Read the error output carefully
2. Fix all failures
3. Re-run the backpressure command (from `BACKPRESSURE_CMD` in `.ralphrc`)
4. Only commit when all checks pass
5. If still failing after one fix attempt, stop and report the issue

## Rules

- NEVER skip backpressure
- NEVER commit code that fails quality gates
- Run backpressure on affected code only (not the entire project) when the tooling supports it
- If a pre-existing failure exists in an unrelated area, note it but don't block on it
- The backpressure command may vary between projects -- always read it from `.ralphrc`
