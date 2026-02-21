---
name: ralph-workflow
description: Core Ralph Loop workflow orchestration. Use when running autonomous development iterations, selecting modes, or making decisions about the build/interview/bootstrap/archive lifecycle.
---

# Ralph Workflow

The Ralph Loop is an autonomous development orchestrator that spawns fresh [Claude Code](https://docs.anthropic.com/en/docs/claude-code) instances per iteration. Context is clean each time; continuity comes from git history, tickets ([`tk`](https://github.com/wedow/ticket)), skills, and [`LESSONS.md`](../../LESSONS.md).

## Configuration

All project-specific settings live in [`.ralphrc`](../../.ralphrc). Read it at the start of every iteration.

| Key | Description | Default |
|-----|-------------|---------|
| `PROJECT_NAME` | Human-readable project name | -- |
| `BASE_BRANCH` | Target branch for PRs | `main` |
| `BACKPRESSURE_CMD` | Quality gate command to run before committing | `npx nx affected -t lint test build` |
| `E2E_CMD` | End-to-end test command | *(none)* |
| `USE_OPENSPEC` | Whether OpenSpec spec-driven workflow is enabled | `false` |
| `CLAUDE_MODEL` | Claude model for spawned instances | `opus` |
| `MAX_ITERATIONS` | Default max iterations in `--auto` mode | `25` |
| `REVIEW_WAIT` | Seconds to wait between review polling iterations | `90` |

## Modes

| Mode | Command | Purpose |
|------|---------|---------|
| interview | `./ralph/loop.sh interview` | Interview human, create proposal + [`IMPLEMENTATION_PLAN.md`](../../IMPLEMENTATION_PLAN.md) |
| bootstrap | `./ralph/loop.sh bootstrap` | Decompose proposal into [`tk`](https://github.com/wedow/ticket) epic + 3-8 task tickets |
| build | `./ralph/loop.sh` | Pick next ready ticket, implement, test, close |
| archive | `./ralph/loop.sh archive` | Merge delta specs into main specs (OpenSpec only, when `USE_OPENSPEC=true`) |
| review | `./ralph/loop.sh review` | Address PR review comments (human + Copilot) |
| e2e | `./ralph/loop.sh e2e` | Fix E2E test failures (requires `E2E_CMD` in `.ralphrc`) |

## Build Iteration Lifecycle

```
tk ready | head -1        # pick highest-priority unblocked task
tk start <id>             # mark in_progress
# ... implement + write tests ...
# run BACKPRESSURE_CMD from .ralphrc
tk close <id>             # mark closed
tk add-note <id> "lesson" # per-ticket learning
# append to LESSONS.md    # cross-cutting learning
git commit -m "feat(<id>): <description>"  # conventional commit
git push
```

## State Management

State persists across iterations via git-tracked files:

| Artifact | Purpose |
|----------|---------|
| [`.tickets/`](../../.tickets/) | Task queue managed by [`tk`](https://github.com/wedow/ticket) |
| [`LESSONS.md`](../../LESSONS.md) | Cumulative learnings from prior iterations |
| [`AGENTS.md`](../../AGENTS.md) | Project-specific operational guide and commands |
| [`.claude/skills/`](../../.claude/skills/) | Reusable agent knowledge |
| [`IMPLEMENTATION_PLAN.md`](../../IMPLEMENTATION_PLAN.md) | High-level vision from interview mode |
| [`openspec/`](../../openspec/) | Specs and active change proposals (if `USE_OPENSPEC=true`) |
| [`.ralphrc`](../../.ralphrc) | Configuration (never modified by the loop) |

## Decision Tree

```
Has a proposal been created (IMPLEMENTATION_PLAN.md or OpenSpec change)?
+-- NO  --> run interview mode first
+-- YES --> Are there tickets?
            +-- NO  --> run bootstrap mode
            +-- YES --> Is `tk ready` empty?
                        +-- NO  --> run build mode (pick next ready ticket)
                        +-- YES --> Are all tickets closed?
                                    +-- NO  --> run `tk blocked` to diagnose
                                    +-- YES --> Is USE_OPENSPEC=true?
                                                +-- YES --> run archive mode
                                                +-- NO  --> done; create PR
```

## Rules

- ONE task per iteration in build mode
- Always run backpressure (`BACKPRESSURE_CMD` from `.ralphrc`) before committing
- Never commit code that doesn't pass the quality gates
- Search the codebase before creating new files
- Follow existing patterns over "better" approaches
- Read relevant skills from `.claude/skills/` before starting a task
- Append non-obvious learnings to `LESSONS.md`
