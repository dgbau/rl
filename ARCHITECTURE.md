# rl Architecture

## How It Works

- `rl` is a CLI toolkit that orchestrates the **Ralph Loop** — an AI development methodology using Claude Code
- The Ralph Loop spawns fresh Claude Code instances per task, with state persisting via git
- Skills (markdown files) teach each instance project patterns; prompts guide each mode
- Core commands: `rl create`, `rl install`, `rl loop`, `rl skills`, `rl migrate`, `rl update`

## Hybrid Model: What Lives Where

### In the rl toolkit (source of truth)

```
resources/core/           → Loop runtime (NOT copied to repos — sourced at runtime)
  loop.sh                 → Main loop orchestrator
  PROMPT_*.md             → Mode-specific prompts (interview, bootstrap, build, amend, review, archive, e2e)
  fetch-reviews.sh        → PR review fetcher (GraphQL resolved-thread filtering)
  reply-reviews.sh        → PR review reply + thread resolution
  run-e2e.sh              → E2E test runner
  CLAUDE.md.template      → Template for generated CLAUDE.md
  ralphrc.template        → Template for config (legacy)
resources/skills/         → Skill source of truth (synced to repos at runtime)
  rl/                     → rl operational skills (uses <!-- sync: --> conditions)
  universal/              → Software engineering principles (always synced)
  tools/                  → User-selected technology skills (languages/, frameworks/, etc.)
resources/commands/       → Slash commands for Claude Code (OpenSpec only)
lib/common.sh             → Shared shell functions
```

### In target repos

```
.rl/                      → rl configuration directory
  config                  → Project-specific settings (replaces .ralphrc)
  skills/                 → Project-specific skill overrides (highest precedence)
  copilot-reviews.md      → Working file (gitignored)
  review-manifest.json    → Working file (gitignored)
  e2e-results.md          → Working file (gitignored)
.claude/skills/           → Effective skills (synced from rl + overrides on each rl loop run)
CLAUDE.md                 → Generated project config for Claude Code
AGENTS.md                 → Generated operational guide
LESSONS.md                → Cumulative learnings (work artifact)
IMPLEMENTATION_PLAN.md    → High-level vision from interview (work artifact)
.tickets/                 → Task queue via tk (work artifact)
openspec/                 → Specs and changes (if USE_OPENSPEC=true, work artifact)
```

## Skill Sync System

Every `rl loop` invocation syncs skills before launching Claude:

1. **Universal**: Copy `resources/skills/universal/*` → `.claude/skills/` (always)
2. **rl**: Copy `resources/skills/rl/*` with `<!-- sync: -->` condition checks (always/openspec/dogfooding)
3. **Overrides**: Copy `.rl/skills/*` over top (project overrides win)
4. **Index**: Generate `SKILLS_INDEX.md` for LLM skill selection

This ensures:
- Skills are always current with the rl toolkit version
- Project-specific customizations are preserved in `.rl/skills/`
- No manual sync needed — it happens automatically

## CLI Commands

| Command | Script | Purpose |
|---------|--------|---------|
| `rl create` | `create.sh` | Scaffold new Nx project with rl configured |
| `rl install` | `install.sh` | Add rl to any existing git repo (creates .rl/) |
| `rl loop [mode]` | `resources/core/loop.sh` | Run the Ralph Loop (interview, bootstrap, build, amend, review, archive, e2e) |
| `rl skills` | `skills.sh` | Manage skill templates (list, add, installed, sync, override, new) |
| `rl migrate` | `migrate.sh` | Migrate from legacy ralph/ model to .rl/ model |
| `rl release` | `release.sh` | Create release with auto-changelog, tag, GitHub Release |
| `rl update` | (inline) | Update rl toolkit (git pull) |
| `rl version` | (inline) | Show current version from git tags |

## Ralph Loop Modes

| Mode | Command | Purpose | Interactive? |
|------|---------|---------|--------------|
| interview | `rl loop interview` | Claude interviews user, creates proposal | Always |
| bootstrap | `rl loop bootstrap` | Create tk tickets from proposal | Either |
| build | `rl loop` | Implement one ticket, test, commit | Either |
| amend | `rl loop amend` | Diagnose spec gaps, amend artifacts, create tickets | Always |
| archive | `rl loop archive` | Merge completed OpenSpec change into specs | Either |
| review | `rl loop review` | Address PR review feedback with manifest-based replies | Either |
| e2e | `rl loop e2e` | Run E2E tests, fix failures | Either |

## Skill Taxonomy

Precedence: project override > template > stack > language > universal > workflow

| Layer | Type | Purpose | Examples |
|-------|------|---------|----------|
| 0 | Workflow | HOW to operate | ralph-workflow, ticket-management, backpressure |
| 1 | Universal | WHAT principles apply everywhere | code-quality, security, ui-ux, api-design |
| 2 | Language | Language-specific conventions | go, rust, python, jvm, c-cpp |
| 3 | Stack | Library combination patterns | stack-nextjs-payload, stack-t3 |
| 4 | Technology | Individual tech with [FILL] markers | nextjs, react, tailwind, stripe |
| 5 | Project | Per-project customizations in .rl/skills/ | Filled-in templates, custom skills |

## Config Flow

```
.rl/config (per-repo) → loop.sh sources it → syncs skills → spawns Claude → Claude reads .claude/skills/
```

Environment variable overrides: `RL_*` or `RALPH_*` vars take precedence over config file values.

Key config variables: `PROJECT_NAME`, `BASE_BRANCH`, `BACKPRESSURE_CMD`, `E2E_CMD`, `USE_OPENSPEC`, `BACKPRESSURE_TIMEOUT`, `E2E_TIMEOUT`, `CLAUDE_MODEL`, `MAX_ITERATIONS`, `REVIEW_WAIT`

## Release Model

- Semantic versioning: `feat` = minor bump, `fix` = patch, `BREAKING CHANGE` = major
- `rl release` generates CHANGELOG.md from conventional commits, tags, and creates GitHub Release
- The `stable` tag always points to the latest release
- Dogfooding safety: when rl develops itself, `--auto` is blocked by default to prevent self-modification without human review. Recovery: `git checkout stable`

## Detection & Generation Pipeline

1. `detect_project()` in `lib/common.sh` scans the repo for signals (lockfiles, config files, app directories)
2. Outputs: `PROJECT_NAME`, `PM`, `BASE_BRANCH`, `HAS_NX`, `APPS`, `LANGUAGES`, `HAS_OPENSPEC`, `USES_TAILWIND`, `USES_TS_STRICT`
3. `generate_rl_config()` creates `.rl/config` from detected context
4. `generate_claude_md()` fills `CLAUDE.md.template` with variables and conditional sections
5. `generate_agents_md()` creates `AGENTS.md` with build commands and conventions

## Backward Compatibility

Repos with the legacy `ralph/` + `.ralphrc` model still work:
- `loop.sh` checks `.rl/config` first, falls back to `.ralphrc`
- `rl migrate` converts legacy repos to the new model
- Deprecation warnings guide users to migrate
