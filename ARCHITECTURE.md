# rl Architecture

## How It Works

- `rl` is a CLI toolkit that installs the Ralph Loop methodology into git repos
- The Ralph Loop spawns fresh Claude Code instances per task, with state persisting via git
- Skills (markdown files) teach each instance project patterns; prompts guide each mode
- Three commands: `rl create` (scaffold new Nx project), `rl install` (add to existing repo), `rl skills` (manage templates)

## IMPORTANT: Dogfooding vs Distribution Boundary

rl uses its own ralph loop for self-development. These two concerns are strictly separated:

### Distribution (what gets installed into OTHER repos)

```
resources/core/           → Copied to repo's ralph/ directory (the loop itself)
  loop.sh                 → Main loop orchestrator
  PROMPT_*.md             → Mode-specific prompts (interview, bootstrap, build, review, archive, e2e)
  fetch-reviews.sh        → PR review fetcher
  run-e2e.sh              → E2E test runner
  README.md               → Ralph Loop documentation
  CLAUDE.md.template      → Template for generated CLAUDE.md
  ralphrc.template        → Template for .ralphrc
resources/skills/         → Copied to repo's .claude/skills/ (agent knowledge)
  workflow/               → Always installed (core operational skills)
    ralph-workflow/       → Loop orchestration rules
    backpressure/         → Quality gate (lint/test/build)
    ticket-management/    → tk CLI usage
    self-update/          → rl update procedure
    github-pr-review/     → PR review handling
    code-quality/         → Universal code best practices
    security/             → OWASP Top 10 as rules
    ui-ux/                → Accessibility, design tokens, responsive
    api-design/           → REST/GraphQL conventions
    testing-principles/   → Test pyramid, AAA, mocking discipline
    observability/        → Logging, metrics, tracing
    data-integration/     → External API consumption patterns
  workflow-openspec/      → Installed when USE_OPENSPEC=true
  templates/              → User-selected technology templates with [FILL] markers
resources/commands/       → Slash commands for Claude Code (OpenSpec only)
resources/SKILLS_INDEX.md → Skill catalog with tool recommendations
lib/common.sh             → Shared shell functions (detection, prompts, generation)
```

### Dogfooding (rl's OWN development — NEVER distributed)

```
ralph/                → rl's own ralph loop instance (NOT resources/core/)
.ralphrc              → rl's own config (NOT resources/core/ralphrc.template)
CLAUDE.md             → rl's own root doc (NOT resources/core/CLAUDE.md.template)
AGENTS.md             → rl's own conventions
LESSONS.md            → rl's own learnings
.tickets/             → rl's own task tracking
.claude/skills/       → rl's own skills (includes rl-development skill)
ARCHITECTURE.md       → This file — rl's own architecture doc
```

**Rule: `install.sh` reads from `resources/`, NEVER from the repo root.**
**Rule: Dogfooding files are for rl's own development and never copied to target repos.**

## CLI Commands

| Command | Script | Purpose |
|---------|--------|---------|
| `rl create` | `create.sh` | Scaffold new Nx project with Ralph Loop pre-installed |
| `rl install` | `install.sh` | Add Ralph Loop to any existing git repo |
| `rl skills` | `skills.sh` | Manage skill templates (list/add/installed/new/add-openspec) |

## Skill Taxonomy

Precedence: project > stack > language > universal > workflow

| Layer | Type | Purpose | Examples |
|-------|------|---------|----------|
| 0 | Workflow | HOW to operate | ralph-workflow, ticket-management, backpressure |
| 1 | Universal | WHAT principles apply everywhere | code-quality, security, ui-ux, api-design |
| 2 | Language | Language-specific conventions | go, rust, python, jvm, c-cpp |
| 3 | Stack | Library combination patterns | stack-nextjs-payload, stack-t3, stack-gotth |
| 4 | Technology | Individual tech with [FILL] markers | nextjs, react, tailwind, stripe, canvas |
| 5 | Project | Per-project customizations | Filled-in templates, custom skills |

## Config Flow

```
.ralphrc (per-repo) → loop.sh sources it → spawns Claude with env → Claude reads skills
```

Key `.ralphrc` variables: `PROJECT_NAME`, `BASE_BRANCH`, `BACKPRESSURE_CMD`, `E2E_CMD`, `USE_OPENSPEC`, `USES_TAILWIND`, `USES_TYPESCRIPT_STRICT`

## Detection & Generation Pipeline

1. `detect_project()` in `lib/common.sh` scans the repo for signals (lockfiles, config files, app directories)
2. Outputs: `PROJECT_NAME`, `PM`, `BASE_BRANCH`, `HAS_NX`, `APPS`, `LANGUAGES`, `HAS_OPENSPEC`, `USES_TAILWIND`, `USES_TS_STRICT`
3. `generate_ralphrc()` creates `.ralphrc` from detected context
4. `generate_claude_md()` fills `CLAUDE.md.template` with variables and conditional sections
5. `generate_agents_md()` creates `AGENTS.md` with build commands and conventions

## Future Improvements

`create.sh` currently creates Nx monorepos exclusively. Non-JS/TS apps (Go, Rust, Python, JVM, C/C++) are supported as services within Nx monorepos under `apps/`, with `project.json` targets wrapping their native build tools.

**Future:** When a technology stack cannot reasonably live inside an Nx monorepo (e.g., a pure Rust embedded system, a standalone Go CLI tool, a C project with CMake), `create.sh` could be extended with alternative scaffolding modes:
- `rl create --preset=go` → `go mod init` + ralph loop
- `rl create --preset=rust` → `cargo init` + ralph loop
- `rl create --preset=python` → `uv init` + ralph loop
- `rl create --preset=cmake` → CMake scaffold + ralph loop

Each would need its own backpressure defaults, project detection, and CLAUDE.md template. The `install.sh` and skill system already support these languages — only the scaffolding is missing.
