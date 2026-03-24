# rl — Ralph Loop Toolkit

**rl** turns [Claude Code](https://docs.anthropic.com/en/docs/claude-code) into an autonomous software engineer that builds your project while you do something else.

It manages the full development cycle — interviewing you about what to build, breaking work into tickets, implementing them one at a time with quality gates, creating pull requests, and responding to review feedback — across any stack.

## Why?

AI coding assistants are powerful but stateless. You paste context, get code, paste more context, lose track of what's done, and end up project-managing the AI instead of building. The longer the session runs, the worse the output gets as context fills up.

The **Ralph Loop** — [originated by Geoffrey Huntley](https://ghuntley.com/loop/) — solves this with a simple insight: **fresh context per task, hard quality gates, git as memory.** Each iteration starts a clean Claude session, picks one ticket, implements it, runs lint/test/build, and commits. State lives in git history, tickets, specs, and skills — not in a degrading context window.

**rl** is a toolkit that implements and extends this pattern:

- **Any stack** — TypeScript, Python, Go, Rust, JVM, C/C++, Nx monorepos
- **Hybrid ticketing** — [`tk`](https://github.com/wedow/ticket) stores tickets as markdown files in your repo (git-native, no external service), with dependency tracking and priority ordering
- **Spec-driven development by default** — [`OpenSpec`](https://github.com/fission-ai/openspec) maintains living system documentation that evolves with your code. Specs become the source of truth for what the system does, not just what was planned. Enabled by default; disable with `--no-openspec` or `USE_OPENSPEC=false`
- **Skills as shared knowledge** — reusable agent instructions synced from a single source of truth, with per-project overrides
- **Human-in-the-loop safety** — Ralph creates draft PRs but **never merges or closes them.** A human always performs the final merge

### Why tk + OpenSpec?

**tk** and **OpenSpec** solve different problems. You always need tk. OpenSpec is optional but valuable for larger projects.

**tk** is the task engine. It breaks work into ordered, dependency-tracked tickets stored as markdown files inside your repo. The agent picks the next unblocked task with `tk ready`, marks it in progress, implements it, closes it. No API, no auth, no external state — the agent reads and writes tickets with plain file operations. Without tk, the agent has no queue and no ordering.

**OpenSpec** is the knowledge layer. It maintains living specs that describe what the system *actually does* — not what was planned months ago. When a feature is built, delta specs capture what changed and why. Main specs are updated to reflect the system as-built. Without OpenSpec, the agent works from a one-shot `IMPLEMENTATION_PLAN.md` that goes stale as the project evolves.

**Together**, they complement each other: OpenSpec provides the *what and why* (structured specs, design rationale, acceptance criteria), tk provides the *when and in what order* (priority, dependencies, lifecycle). The bootstrapper reads the spec to understand scope, then creates tk tickets with the right ordering. The build agent reads the relevant spec for context, then implements the ticket.

---

## Setup

```bash
git clone https://github.com/dgbau/rl.git
cd rl
./setup.sh    # Adds to PATH, checks/installs all dependencies
```

Or manually: see [Manual Install](#manual-install) below.

---

## Quickstart

### New TypeScript project

```bash
rl create --type typescript --name my-app
cd my-app
git checkout -b ralph/my-feature
rl loop interview
rl loop --auto --pr
```

### New Python project

```bash
rl create --type python --name my-tool
cd my-tool
git checkout -b ralph/my-feature
rl loop interview
rl loop --auto --pr
```

### New Nx monorepo

```bash
rl create --type nx --name my-workspace --preset next
cd my-workspace
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

## Manual Install

If you prefer not to use `setup.sh`:

### Prerequisites

| Tool | Install | Purpose |
|------|---------|---------|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | `npm install -g @anthropic-ai/claude-code` | AI agent |
| [tk](https://github.com/wedow/ticket) | `brew tap wedow/tools && brew install ticket` | Git-native ticket management |
| [gh](https://cli.github.com/) | `brew install gh && gh auth login` | GitHub integration |
| [jq](https://jqlang.github.io/jq/) | `brew install jq` | JSON processing |
| [OpenSpec](https://github.com/fission-ai/openspec) | `npm install -g @fission-ai/openspec` | Spec-driven development (enabled by default) |

### Clone and run setup

```bash
git clone https://github.com/dgbau/rl.git
cd rl
./setup.sh    # Adds to PATH, checks dependencies
```

`setup.sh` detects where you cloned it and adds the correct path to your shell rc file. No manual PATH editing needed.

### Update rl

```bash
rl update    # git pull --ff-only under the hood
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
| `rl loop` | Build | Implements one ticket per iteration. Chains in `--auto`. |
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

1. `rl loop` spawns a fresh Claude Code instance with a mode-specific prompt
2. Claude reads state (tickets, skills, lessons, git history), does one task, commits
3. The instance exits — context is clean
4. `rl loop` runs backpressure (lint/test/build), pushes if configured
5. In interactive mode, you review and decide whether to continue. In `--auto` mode, repeats until all tickets are closed or max iterations reached.

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
| `.claude/skills/` | Effective skills (synced from rl + overrides) | Project-specific only* |
| `CLAUDE.md` | Claude Code project config | Yes |
| `AGENTS.md` | Operational guide | Yes |
| `LESSONS.md` | Cumulative learnings | Yes |
| `.tickets/` | Task queue (tk) | Yes |
| `IMPLEMENTATION_PLAN.md` | Vision from interview (always created) | Yes |
| `openspec/` | Living specs and delta changes (if USE_OPENSPEC=true) | Yes |
| `.rl/pr-reviews.md` | Working file | No (.gitignore) |
| `.rl/review-manifest.json` | Working file | No (.gitignore) |
| `.rl/e2e-results.md` | Working file | No (.gitignore) |

### Skill system

Skills are markdown files that teach Claude how to work in your project.

#### How skills flow

```
rl source (on your machine)          Your project repo
───────────────────────               ──────────────────
resources/skills/universal/*  ──┐
resources/skills/rl/*         ──┼──▶  .claude/skills/*    ◀── Claude reads these
                                │
                     .rl/skills/*  ──┘  (copied last, wins)
```

**Every `rl loop` run**, the sync rebuilds `.claude/skills/`:

1. **Detect modifications** — before overwriting, checks if any skill in `.claude/skills/` was changed since last sync (by the agent or by you). If so, auto-promotes the modified version to `.rl/skills/` so it persists.
2. **Copy from rl source** — universal + rl skills from wherever rl is installed
3. **Apply overrides** — copies `.rl/skills/` on top (same filename = overwrite)
4. **Generate index** — creates `SKILLS_INDEX.md` for the LLM

**This means:**
- If the agent improves a skill during a build, the improvement is **automatically saved** to `.rl/skills/` on the next sync
- `.rl/skills/` is yours, committed to git, never touched by sync — project-specific customizations live here
- When you `rl update` (pulling new rl source), the next loop run picks up improved skills — but your overrides still win
- Skills the loop creates with new names (e.g. `.claude/skills/my-auth-patterns/`) survive sync because rl source doesn't have a file with that name to overwrite

#### Overriding a skill

An "override" means: put a file with the same name in `.rl/skills/` so it gets copied last and wins.

```bash
# Start from the current rl source version as a base:
rl skills override openspec-apply-change
# Creates .rl/skills/openspec-apply-change/SKILL.md
# Edit it with your project-specific patterns

# Or add a technology skill from the catalog:
rl skills add tailwind
# Creates .rl/skills/tailwind/SKILL.md — fill in the [FILL] sections
```

#### Merge conflicts in `.claude/skills/`

If a branch modified a skill in `.claude/skills/` that sync overwrites:
1. The useful changes belong in `.rl/skills/`, not `.claude/skills/`
2. Copy the improved version to `.rl/skills/<skill-name>/SKILL.md`
3. Accept the rl source version in `.claude/skills/` (it's overwritten on next sync anyway)

#### How skills connect to tickets

The bootstrapper writes relevant skill names into each ticket's `## Skills` section. The build agent reads `SKILLS_INDEX.md` to understand what's available, then reads only the skills listed in the ticket.

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
| `USE_COPILOT_REVIEWS` | `RALPH_USE_COPILOT_REVIEWS` | `true` | Enable Copilot PR reviews |
| `USE_GREPTILE_REVIEWS` | `RALPH_USE_GREPTILE_REVIEWS` | `false` | Enable Greptile PR reviews (opt-in) |
| `USE_OPENSPEC` | — | `true` | Enable spec-driven development |
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

## OpenSpec integration (enabled by default)

When `USE_OPENSPEC=true` (the default), [OpenSpec](https://github.com/fission-ai/openspec) maintains living system documentation:

1. **Interview** creates a change with proposal, design, and delta specs
2. **Bootstrap** links the epic ticket via `external-ref: openspec:<id>`
3. **Build** reads delta specs for requirements
4. **Archive** merges delta specs into `openspec/specs/`

Interview always creates `IMPLEMENTATION_PLAN.md` as a human-readable summary. When OpenSpec is disabled, this becomes the primary planning artifact and archive mode is skipped.

---

## Safety

`--auto` mode uses `--dangerously-skip-permissions` for Claude Code.

**What Ralph does NOT do:**
- Never merges or closes PRs — only creates drafts
- Never force-pushes
- Never runs on protected branches (refuses base branch or `main`)

**Mitigations:**
1. Feature branches only
2. Automated PR reviews (Copilot, Greptile) on every push
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

## Releases and versioning

rl uses [semantic versioning](https://semver.org/) with version bumps auto-detected from [conventional commits](https://www.conventionalcommits.org/). Only `feat`, `fix`, and `BREAKING CHANGE` commits trigger a release — `docs`, `chore`, `refactor`, etc. are included in the changelog but don't bump the version.

```bash
rl release              # auto-detect version bump from commits
rl release --dry-run    # preview without making changes
rl version              # show current version
rl update               # pull latest from main
```

See [RELEASING.md](RELEASING.md) for the full release process, version bump rules, the `stable` tag, and pre-release checklist.

---

## Dogfooding

rl develops itself using its own loop. This creates a unique challenge: the agent modifies the same scripts, skills, and prompts that the loop runs from.

**Safety measures:**
- **`--auto` blocked by default** — When the loop detects it's operating on the rl toolkit, `--auto` mode requires explicit confirmation. This prevents the loop from silently breaking itself without a human checkpoint between iterations.
- **Backpressure catches syntax errors** — `zsh -n` on all scripts before every commit.
- **Feature branches only** — All changes happen on branches. The human reviews and merges.
- **`stable` tag** — If a self-modification breaks the loop, you can recover by checking out the `stable` tag.

**What backpressure does NOT catch:** Logic bugs, corrupted skill instructions, or config changes that are valid shell but semantically wrong. This is why `--auto` is gated — a human needs to review each iteration's changes before the next one runs.

---

## Acknowledgments

The Ralph Loop pattern was originated by [Geoffrey Huntley](https://ghuntley.com/specs), who demonstrated that AI agents produce dramatically better results when given fresh context per task, hard quality gates, and spec-driven requirements. This toolkit implements and extends his approach with hybrid ticketing, skill management, and multi-stack support.

Thanks to [Hepp](https://github.com/hepp) for sharing the Ralph Loop concept with me.

## License

MIT. See [LICENSE](LICENSE) and [THIRD_PARTY_LICENSES](THIRD_PARTY_LICENSES).

---

*\* `rl skills sync` generates a `.gitignore` inside `.claude/skills/` that excludes synced workflow skills (managed by rl) while keeping project-specific skills committed. This ensures synced skills always come from the rl source of truth, while your project-specific knowledge stays in version control.*
