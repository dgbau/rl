# rl — Ralph Loop Toolkit

**rl** orchestrates autonomous AI development using [Claude Code](https://docs.anthropic.com/en/docs/claude-code). It spawns fresh Claude instances per task, tracks state via git, and manages skills as a single source of truth across all your projects.

Ralph **never** merges or closes PRs. A human always performs the final merge.

---

## Quickstart

### New TypeScript project

```bash
rl create --type typescript --name my-app
cd ~/src/my-app
git checkout -b ralph/my-feature
rl loop interview
rl loop --auto --pr
```

### New Python project

```bash
rl create --type python --name my-tool
cd ~/src/my-tool
git checkout -b ralph/my-feature
rl loop interview
rl loop --auto --pr
```

### New Nx monorepo

```bash
rl create --type nx --name my-workspace --preset next
cd ~/src/my-workspace
git checkout -b ralph/my-feature
rl loop interview
rl loop --auto --pr
```

### Add rl to an existing repo

```bash
cd /path/to/your/repo
rl install
git checkout -b ralph/my-feature
rl loop interview
```

### Migrate from legacy ralph/ installation

```bash
cd /path/to/repo-with-ralph
rl migrate
# Review .rl/config, move custom skills to .rl/skills/
rl loop interview
```

---

## Install

### Prerequisites

| Tool | Install | Purpose |
|------|---------|---------|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | `npm install -g @anthropic-ai/claude-code` | AI agent |
| [tk](https://github.com/wedow/ticket) | `brew tap wedow/tools && brew install ticket` | Ticket management |
| [gh](https://cli.github.com/) | `brew install gh && gh auth login` | GitHub integration |
| [jq](https://jqlang.github.io/jq/) | `brew install jq` | JSON processing |
| [OpenSpec](https://github.com/fission-ai/openspec) (optional) | `npm install -g @fission-ai/openspec` | Spec-driven development |

### Install rl

```bash
git clone <rl-repo-url> ~/src/rl
# Add to PATH (pick one):
ln -s ~/src/rl/rl /usr/local/bin/rl
# or add to .zshrc:
export PATH="$HOME/src/rl:$PATH"
```

### Update rl

```bash
rl update
```

---

## Commands

| Command | Purpose |
|---------|---------|
| `rl create` | Scaffold a new project (typescript, nx, python, go, rust, bare) |
| `rl install [dir]` | Add rl to an existing git repo |
| `rl loop [mode]` | Run the Ralph Loop |
| `rl skills` | Manage skill templates |
| `rl migrate [dir]` | Migrate from legacy ralph/ model |
| `rl update` | Update rl toolkit |

### Loop modes

| Command | Mode | What it does |
|---------|------|--------------|
| `rl loop interview` | Interview | Claude interviews you, creates proposal. Always interactive. |
| `rl loop bootstrap` | Bootstrap | Creates tk tickets from proposal. No code written. |
| `rl loop` | Build | Implements one ticket, tests, commits. |
| `rl loop amend` | Amend | Diagnoses spec gaps, amends artifacts, creates tickets. Always interactive. |
| `rl loop archive` | Archive | Merges OpenSpec delta specs into main specs. |
| `rl loop review` | Review | Triages PR feedback, fixes code, posts replies. |
| `rl loop e2e` | E2E | Runs E2E tests, fixes failures. |

### Loop flags

| Flag | Effect |
|------|--------|
| `--auto` | Headless. In build mode, auto-chains bootstrap -> build -> archive. |
| `--pr` | Create draft PR, update summary when done. Implies `--push`. |
| `--push` | Push after each iteration. Default in `--auto`. |
| `--no-push` | Don't push. Default in interactive mode. |
| `N` | Max iterations (number). Default: 1 interactive, 25 auto. |

### Skills commands

| Command | Purpose |
|---------|---------|
| `rl skills list` | Show available templates |
| `rl skills add <name>` | Add a template to `.rl/skills/` (project override) |
| `rl skills installed` | Show skills in current repo |
| `rl skills sync` | Sync skills from rl source to `.claude/skills/` |
| `rl skills override <name>` | Copy a workflow skill to `.rl/skills/` for customization |
| `rl skills new <name>` | Create a new skill in current repo |
| `rl skills add-openspec` | Add OpenSpec skills and slash commands |

---

## How it works

### The loop pattern

1. `loop.sh` spawns a fresh Claude Code instance with a mode-specific prompt
2. Claude reads state (tickets, skills, lessons, git history), does one task, commits
3. The instance exits — context is clean
4. `loop.sh` runs backpressure (lint/test/build), pushes if configured
5. Repeat until all tickets are closed or max iterations reached

**Why fresh context?** LLMs degrade as context fills. Restarting each iteration keeps the agent in its "smart zone."

### What lives where

**In the rl toolkit** (source of truth, never copied to repos):
- Loop orchestrator, mode prompts, helper scripts
- Workflow skills (synced to repos on each `rl loop` run)
- Technology templates

**In your repo:**

| Path | Purpose | Tracked? |
|------|---------|----------|
| `.rl/config` | Project configuration | Yes |
| `.rl/skills/` | Project-specific skill overrides | Yes |
| `.claude/skills/` | Effective skills (synced from rl + overrides) | Yes |
| `CLAUDE.md` | Claude Code project config | Yes |
| `AGENTS.md` | Operational guide | Yes |
| `LESSONS.md` | Cumulative learnings | Yes |
| `.tickets/` | Task queue (tk) | Yes |
| `IMPLEMENTATION_PLAN.md` | Vision from interview | Yes |
| `openspec/` | Specs (if USE_OPENSPEC=true) | Yes |
| `.rl/copilot-reviews.md` | Working file | No (.gitignore) |
| `.rl/review-manifest.json` | Working file | No (.gitignore) |
| `.rl/e2e-results.md` | Working file | No (.gitignore) |

### Skill system

Skills are markdown files in `.claude/skills/` that teach Claude project-specific patterns. They're synced automatically on every `rl loop` run:

1. **Workflow skills** from rl source (always synced)
2. **OpenSpec skills** from rl source (if USE_OPENSPEC=true)
3. **Project overrides** from `.rl/skills/` (highest precedence)

To customize a workflow skill for your project:

```bash
rl skills override backpressure   # Copies to .rl/skills/backpressure/
# Edit .rl/skills/backpressure/SKILL.md
```

To add a technology template:

```bash
rl skills list                    # See available templates
rl skills add tailwind            # Copies to .rl/skills/tailwind/
# Fill in the [FILL] sections
```

---

## Configuration

`.rl/config` is a shell-sourceable file. Environment variables override config values.

| Key | Env override | Default | Purpose |
|-----|-------------|---------|---------|
| `PROJECT_NAME` | — | dir name | Project identifier |
| `BASE_BRANCH` | `RALPH_BASE_BRANCH` | `main` | PR target branch |
| `BACKPRESSURE_CMD` | — | auto-detected | Quality gate (lint/test/build) |
| `E2E_CMD` | — | *(none)* | E2E test command |
| `CLAUDE_MODEL` | `RALPH_MODEL` | `opus` | Claude model |
| `MAX_ITERATIONS` | `RALPH_MAX_ITERATIONS` | `25` | Max auto iterations |
| `REVIEW_WAIT` | `RALPH_REVIEW_WAIT` | `90` | Seconds between review cycles |
| `USE_OPENSPEC` | — | `false` | Enable spec-driven development |
| `BACKPRESSURE_TIMEOUT` | `RALPH_BACKPRESSURE_TIMEOUT` | `600` | Backpressure timeout (seconds) |
| `E2E_TIMEOUT` | `RALPH_E2E_TIMEOUT` | `300` | E2E timeout (seconds) |

`rl install` auto-detects backpressure for your stack:

| Stack | Detected command |
|-------|-----------------|
| Nx monorepo | `npx nx affected -t lint test build` |
| Node.js (package.json) | `npm run lint && npm run test && npm run build` |
| Go | `go vet ./... && go test ./...` |
| Rust | `cargo clippy -- -D warnings && cargo test` |
| Python (pytest + ruff) | `ruff check . && pytest` |
| Python (pytest + mypy) | `mypy . && pytest` |
| JVM (Gradle) | `./gradlew check` |
| JVM (Maven) | `mvn verify` |

---

## Workflows

### Interactive development

```bash
git checkout -b ralph/my-feature
rl loop interview              # Claude interviews you -> proposal
rl loop bootstrap              # Create tickets from proposal
rl loop                        # Build one ticket (review between iterations)
rl loop --push                 # Build + push
rl loop review --push          # Address PR feedback
rl loop e2e                    # Fix E2E failures
```

### Fully autonomous

```bash
git checkout -b ralph/my-feature
rl loop interview              # Must be interactive
rl loop --auto --pr            # Bootstrap -> build all -> PR
rl loop e2e --auto             # Fix E2E failures headlessly
rl loop review --auto --pr     # Address review feedback headlessly
# Human reviews and merges.
```

### Resume after interruption

```bash
tk ready                       # See what's next
rl loop                        # Picks up where it left off
```

### Fix spec gaps mid-project

```bash
rl loop amend                  # Diagnose gap, amend specs, create tickets
rl loop                        # Build the new tickets
```

---

## Ticket system

Tickets are managed by [`tk`](https://github.com/wedow/ticket) and stored as markdown in `.tickets/`.

```bash
tk ready                                    # Unblocked tasks, priority order
tk ls                                       # All tickets
tk start <id>                               # Mark in_progress
tk close <id>                               # Mark closed
tk add-note <id> "what was done"            # Add note
tk create "title" -t task --parent <epic>   # Create task
tk dep <blocked> <blocker>                  # Set dependency
```

Lifecycle: `open` -> `in_progress` -> `closed`

The build agent picks the highest-priority unblocked ticket via `tk ready`.

---

## OpenSpec integration (optional)

When `USE_OPENSPEC=true`, [OpenSpec](https://github.com/fission-ai/openspec) maintains living system documentation:

1. **Interview** creates a change with proposal, design, and delta specs
2. **Bootstrap** links the epic ticket via `external-ref: openspec:<id>`
3. **Build** reads delta specs for requirements
4. **Archive** merges delta specs into `openspec/specs/`

When disabled, interview creates `IMPLEMENTATION_PLAN.md` instead and archive is skipped.

---

## Safety

`--auto` mode uses `--dangerously-skip-permissions` for Claude Code.

**What Ralph does NOT do:**
- Never merges or closes PRs — only creates drafts
- Never force-pushes
- Never runs on protected branches (refuses base branch or `main`)

**Mitigations:**
1. Feature branches only
2. Copilot auto-reviews every push
3. Backpressure catches regressions every iteration
4. Escape hatch: `git reset --hard origin/<base-branch>`

---

## Project types for `rl create`

| Type | What it scaffolds |
|------|-------------------|
| `typescript` | package.json + tsconfig + vitest + eslint |
| `nx` | Nx monorepo with chosen preset |
| `python` | pyproject.toml (via `uv init` or manual) + pytest + ruff + mypy |
| `go` | go.mod + cmd/ + internal/ layout |
| `rust` | cargo init |
| `bare` | Empty git repo with rl configured |

All types get `.rl/config`, `CLAUDE.md`, `AGENTS.md`, `LESSONS.md`, and `.claude/skills/`.

---

## License

MIT. See [LICENSE](LICENSE) and [THIRD_PARTY_LICENSES](THIRD_PARTY_LICENSES).
