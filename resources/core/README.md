# Ralph Loop -- Autonomous AI Development

The Ralph Loop spawns fresh [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) instances, each performing a single task, committing, and exiting. State persists via git-tracked tickets ([`tk`](https://github.com/wedow/ticket)), skills, and lessons. Integrates with [OpenSpec](https://github.com/fission-ai/openspec) for spec-driven development by default (disable with `USE_OPENSPEC=false`).

Ralph **never** merges or closes PRs. A human always performs the final merge.

---

## Quick Reference

### Modes

| Command | Mode | What it does |
|---------|------|--------------|
| `rl loop interview` | Interview | Claude interviews you, creates proposal + `IMPLEMENTATION_PLAN.md`. Always interactive. |
| `rl loop bootstrap` | Bootstrap | Reads proposal, creates `tk` epic + 3-8 task tickets. No code written. |
| `rl loop` | Build | Picks next ready task ticket, implements, tests, commits. One ticket per iteration. |
| `rl loop archive` | Archive | Merges completed OpenSpec delta specs into `openspec/specs/`. Requires `USE_OPENSPEC=true`. |
| `rl loop review` | Review | Fetches all PR reviews (human + Copilot), triages, fixes code, creates/amends tickets. |
| `rl loop e2e` | E2E | Runs E2E tests, fixes failures. |

### Flags

| Flag | Effect |
|------|--------|
| `--auto` | Headless autonomous mode. In build mode, auto-chains bootstrap -> build -> archive. |
| `--pr` | Create draft PR on first push, mark ready when all tickets closed. Implies `--push`. |
| `--push` | Push after each iteration. Default when `--auto` is set. |
| `--no-push` | Don't push. Default in interactive mode. |
| `N` (number) | Max iterations. Default: 1 (interactive), 25 (`--auto`). |
| `-h` / `--help` | Print usage summary. |

### Examples

```bash
# Interactive workflow
rl loop interview            # Claude interviews you -> proposal
rl loop bootstrap            # Create tickets from proposal
rl loop                      # Build one ticket, review
rl loop --push               # Build one ticket + push

# Autonomous workflow (after interview)
rl loop --auto --pr          # Bootstrap -> build all -> archive -> PR
rl loop --auto --pr 10       # Same, max 10 build iterations
rl loop review --auto --pr   # Address PR reviews headlessly
rl loop e2e --auto           # Fix E2E failures headlessly
```

> Always start from a feature branch (e.g., `ralph/my-feature`). The loop refuses to run on the base branch or `main`.

---

## What is the Ralph Loop?

The Ralph Loop (conceived by [Geoffrey Huntley](https://ghuntley.com/stdlib), named after Ralph Wiggum) is a pattern for autonomous AI-assisted software development.

1. A bash script (`loop.sh`) repeatedly spawns fresh Claude Code CLI instances
2. Each instance reads a mode-specific prompt, performs **one ticket**, and commits
3. The instance exits; a new one starts with clean context
4. Memory persists between iterations via git-tracked state (see [State Management](#state-management))

**Why fresh context matters:** LLMs degrade as their context window fills. Restarting each iteration keeps the agent in its "smart zone."

---

## Prerequisites

- **[Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)** installed and authenticated
- **[`tk`](https://github.com/wedow/ticket)** (ticket CLI): `brew tap wedow/tools && brew install ticket`
- **[GitHub CLI](https://cli.github.com/)** (`gh`): `brew install gh && gh auth login`
- **[`jq`](https://jqlang.github.io/jq/)**: `brew install jq`
- **[OpenSpec](https://github.com/fission-ai/openspec)**: `npm install -g @fission-ai/openspec` (enabled by default; disable with `USE_OPENSPEC=false`)

---

## .rl/config Configuration

The loop reads `.rl/config` from the project root. Environment variables override `.rl/config` values, which override defaults.

| `.rl/config` key | Env override | Default | Description |
|----------------|-------------|---------|-------------|
| `PROJECT_NAME` | -- | -- | Project identifier (ticket prefixes, PR titles) |
| `BASE_BRANCH` | `RALPH_BASE_BRANCH` | `main` | Target branch for PRs |
| `CLAUDE_MODEL` | `RALPH_MODEL` | `opus` | Claude model to use |
| `MAX_ITERATIONS` | `RALPH_MAX_ITERATIONS` | `25` | Max iterations in `--auto` mode |
| `REVIEW_WAIT` | `RALPH_REVIEW_WAIT` | `90` | Seconds between review iterations |
| `BACKPRESSURE_CMD` | -- | `npx nx affected -t lint test build` | Quality gate command |
| `E2E_CMD` | -- | *(none)* | E2E test command (used by `run-e2e.sh`) |
| `USE_OPENSPEC` | -- | `true` | Enable OpenSpec spec-driven development |
| `USES_TAILWIND` | -- | -- | Agent context hint (styling) |
| `USES_TYPESCRIPT_STRICT` | -- | -- | Agent context hint (strict TS) |

Example:

```bash
PROJECT_NAME="myapp"
BASE_BRANCH="develop"
BACKPRESSURE_CMD="npm run lint && npm test && npm run build"
E2E_CMD="npx playwright test"
USE_OPENSPEC=true
```

---

## Directory Structure

| File/Dir | Purpose | Git? |
|----------|---------|------|
| `.rl/config` | Loop configuration | Yes |
| `.tickets/` | Task tickets (`tk`) | Yes |
| `.claude/skills/` | Agent skills | Yes |
| `IMPLEMENTATION_PLAN.md` | Vision doc from interview | Yes |
| `LESSONS.md` | Cumulative learnings (append-only) | Yes |
| `AGENTS.md` | Operational guide | Yes |
| `CLAUDE.md` | Claude Code root config | Yes |
| `rl loop` (in rl toolkit) | Loop orchestrator | N/A (sourced from rl) |
| `PROMPT_*.md` (in rl toolkit) | Mode-specific prompts (7 files) | N/A (sourced from rl) |
| `.rl/config` | Project configuration | Yes |
| `.rl/copilot-reviews.md` | Fetched reviews (working file) | No |
| `.rl/review-manifest.json` | Review reply manifest (working file) | No |
| `.rl/e2e-results.md` | E2E failures (working file) | No |
| `openspec/` | Specs and changes (if `USE_OPENSPEC=true`) | Yes |

---

## The Six Modes

### 1. Interview (always interactive)

Claude interviews you about what you want built, then creates a proposal. No code is written. **Cannot run with `--auto`.**

- **With OpenSpec**: Creates an OpenSpec change (proposal, design, delta specs, tasks)
- **Without OpenSpec**: Creates `IMPLEMENTATION_PLAN.md` with goal, approach, and task breakdown

### 2. Bootstrap

Reads the proposal and creates a `tk` epic with 3-8 task tickets. Each ticket includes description, skill references, design notes, and acceptance criteria. No code is written.

### 3. Build

Picks the highest-priority ready task ticket, implements it, writes tests, runs backpressure, and commits. One ticket per iteration.

In `--auto` mode: auto-bootstraps if no tickets exist, auto-archives when all tickets close.

### 4. Archive (OpenSpec only)

Merges completed delta specs into `openspec/specs/`. Skipped when `USE_OPENSPEC=false`.

### 5. Review

Fetches ALL PR review comments (Copilot + human), triages each one, fixes code, creates/amends tickets, updates specs. Human comments get higher priority. Each comment is triaged as: **code fix**, **design concern**, **spec gap**, or **invalid**.

### 6. E2E

Runs E2E tests (via `E2E_CMD`), parses failures, fixes them. Prefers fixing app code over modifying tests.

---

## The Autonomous Pipeline

When `--auto` is used with build mode, Ralph detects state and chains modes:

```
Has proposal? --NO--> ERROR: run interview first
      |
     YES
      |
Has tickets? --NO--> Auto-bootstrap --> Build loop
      |
     YES
      |
Build loop (one ticket per iteration)
      |
All closed? --NO--> Continue (up to MAX_ITERATIONS)
      |
     YES
      |
Auto-archive (if OpenSpec) --> Mark PR ready (if --pr)
```

Full autonomous workflow:

```bash
git checkout -b ralph/my-feature
rl loop interview        # Must be interactive
rl loop --auto --pr      # Bootstrap -> build -> archive -> PR
rl loop e2e --auto       # Fix E2E failures
rl loop review --auto    # Address review feedback
# Human reviews and merges.
```

---

## State Management

The loop maintains continuity across fresh instances through git-tracked state.

| Source | Provides | Updated by |
|--------|----------|------------|
| `.tickets/` | Task queue, dependencies, progress notes | Build, bootstrap, review |
| `LESSONS.md` | Cumulative learnings | Any mode (append-only) |
| `AGENTS.md` | Commands, conventions, patterns | Human or agent |
| `.claude/skills/` | Domain-specific knowledge | Human or agent |
| `openspec/` | System docs and change proposals (if enabled) | Interview, archive |
| Git history | Recent commits | Every iteration |
| `CLAUDE.md` | Root config pointing to all of the above | Human |

### Iteration flow

1. Agent starts clean, reads `CLAUDE.md` (which points to `AGENTS.md`, `.tickets/`, `LESSONS.md`, skills)
2. Picks next ticket via `tk ready`, reads its description and referenced skills
3. Implements, tests, commits, updates ticket status
4. Appends to `LESSONS.md` if something non-obvious was learned
5. Exits. Next iteration starts fresh, reads updated state.

---

## Ticket Workflow

Tickets are managed by [`tk`](https://github.com/wedow/ticket) and stored as markdown in `.tickets/`.

**Lifecycle:** `open -> in_progress -> closed`

The build agent picks tickets via `tk ready | head -1` (highest-priority with all deps resolved).

```bash
tk create "title" -t task -p 1 --parent <epic-id>  # Create task
tk ready                                             # List unblocked
tk start <id>                                        # Mark in_progress
tk close <id>                                        # Mark closed
tk add-note <id> "what was done"                     # Add note
tk dep <blocked> <blocker>                           # Set dependency
tk ls                                                # List all
```

Each ticket has YAML frontmatter (`id`, `status`, `type`, `priority`, `parent`, `deps`, `tags`) plus a markdown body with description, skills, design, and acceptance criteria.

---

## OpenSpec Integration (Enabled by Default)

When `USE_OPENSPEC=true`, [OpenSpec](https://github.com/fission-ai/openspec) maintains living system documentation through a proposal -> implement -> archive lifecycle.

1. **Interview** creates a change: `npx openspec new change <id>`, writes proposal -> design -> specs -> tasks
2. **Bootstrap** links the epic ticket via `external-ref: openspec:<id>`
3. **Build** reads delta specs from `openspec/changes/<id>/specs/` for requirements
4. **Archive** merges delta specs into `openspec/specs/`

```bash
npx openspec new change <id>                          # Create change
npx openspec status --change <id>                     # Check completion
npx openspec list                                     # List active changes
npx openspec archive <id> -y                          # Merge into specs
```

When `USE_OPENSPEC=false`, interview creates `IMPLEMENTATION_PLAN.md` instead, and archive is skipped.

---

## Agent Skills

Skills are reusable knowledge in `.claude/skills/<name>/SKILL.md`. Each ticket references relevant skills; the agent reads them before starting work. Skills keep domain-specific guidance out of the prompt but available when needed.

Add project-specific skills for your codebase conventions, testing patterns, or architectural decisions.

---

## Testing and Backpressure

**Backpressure** (`BACKPRESSURE_CMD`) runs after every build iteration, enforced at two levels:
1. **Prompt-level**: The build prompt instructs Claude to run backpressure before committing
2. **Script-level**: `loop.sh` independently verifies after each iteration

If backpressure fails, Claude gets one self-heal attempt. If it fails again, the loop stops.

**E2E tests** are expensive and not run every iteration. Trigger via `e2e` mode or manually.

---

## PR Lifecycle

**Without `--pr`**: Loop commits locally. You push and create PRs manually.

**With `--pr`**: Loop commits, pushes, auto-creates a **draft** PR on first push. When all tickets close + backpressure passes, marks PR **ready for review**. A human reviews and merges.

---

## Workflow Recipes

### Interactive

```bash
git checkout -b ralph/my-feature
rl loop interview        # Interview -> proposal
rl loop bootstrap        # Create tickets
rl loop                  # Build one ticket
rl loop --push           # Build + push
rl loop e2e              # Fix E2E failures
rl loop review --push    # Address PR feedback
```

### Autonomous

```bash
git checkout -b ralph/my-feature
rl loop interview        # Must be interactive
rl loop --auto --pr      # Bootstrap -> build -> archive -> PR
rl loop e2e --auto
rl loop review --auto --pr
# Human reviews and merges.
```

### Resume

```bash
tk ready                         # See what's next
rl loop                  # Picks up where it left off
```

---

## Tuning the Loop

1. **Watch the first few iterations** -- spot agent mistake patterns
2. **Add guardrails to `AGENTS.md`** -- specific instructions prevent repeated errors
3. **Override skills** in `.rl/skills/` for project-specific customization
4. **Append to `LESSONS.md`** -- the agent reads this; documenting pitfalls helps future iterations
5. **Add skills** in `.claude/skills/` for domain-specific guidance
6. **Tune `.rl/config`** -- adjust `BACKPRESSURE_CMD`, `MAX_ITERATIONS`, `REVIEW_WAIT`

---

## Safety

The `--dangerously-skip-permissions` flag lets Claude Code run commands without confirmation (required for `--auto`).

**What Ralph does NOT do:**
- Never merges or closes PRs -- only creates drafts and marks ready
- Never force-pushes -- only regular `git push`
- Never runs on protected branches -- refuses base branch or `main`

**Mitigations:**
1. Feature branches only. Protected branches rejected.
2. Copilot auto-reviews every push. Human reviews before merge.
3. Backpressure catches regressions every iteration.
4. Escape hatch: `git reset --hard origin/<base-branch>`

---

## Updating

This Ralph Loop was installed by the [rl toolkit](https://github.com/wedow/rl). To update:

1. Run `rl update` to pull the latest toolkit version
2. Run `rl skills sync` to refresh skills in this repo

---

## Future Improvements

`create.sh` currently creates Nx monorepos exclusively. Non-JS/TS apps (Go, Rust, Python, JVM, C/C++) are supported as services within Nx monorepos under `apps/`, with `project.json` targets wrapping their native build tools.

**Future:** When a technology stack cannot reasonably live inside an Nx monorepo (e.g., a pure Rust embedded system, a standalone Go CLI tool, a C project with CMake), `create.sh` could be extended with alternative scaffolding modes:
- `rl create --preset=go` → `go mod init` + ralph loop
- `rl create --preset=rust` → `cargo init` + ralph loop
- `rl create --preset=python` → `uv init` + ralph loop
- `rl create --preset=cmake` → CMake scaffold + ralph loop

Each would need its own backpressure defaults, project detection, and CLAUDE.md template. The `install.sh` and skill system already support these languages — only the scaffolding is missing.
