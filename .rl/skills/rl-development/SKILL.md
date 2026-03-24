# rl Toolkit Development

<!-- category: rl -->
<!-- sync: dogfooding -->

This skill is synced automatically when `rl loop` runs inside the rl toolkit repo itself. It teaches Claude how to properly develop rl.

## Dogfooding vs Distribution Boundary

**Distribution** (affects all rl users — treat changes with care):
- `resources/core/` — loop runtime, mode prompts (sourced at runtime, never copied)
- `resources/skills/rl/` — rl operational skills (synced with `<!-- sync: -->` conditions)
- `resources/skills/universal/` — software principles (always synced)
- `resources/skills/tools/` — technology skills by category (user-selectable)
- `resources/commands/` — slash commands for Claude Code
- `lib/common.sh` — shared shell utilities

**Dogfooding** (rl's own development loop — never distributed):
- `.rl/config` — rl's own project configuration
- `CLAUDE.md`, `AGENTS.md`, `LESSONS.md` — rl's own context files
- `ARCHITECTURE.md` — rl's architecture documentation
- `.tickets/` — rl's own task tracking
- `.claude/skills/` — synced from `resources/skills/` on each `rl loop` run

**Rule:** Changes to `resources/` affect every project. Test thoroughly before committing.

## How to Test Changes

1. **Shell syntax**: `zsh -n <modified-script>` (or run full backpressure)
2. **Skills list**: `rl skills list` — verify tools appear grouped by category
3. **Install test**: Create a temp repo and run `rl install /tmp/test-repo`
4. **Sync test**: `cd /tmp/test-repo && rl skills sync` — verify skills land correctly
5. **Installed check**: `rl skills installed` — verify category grouping works
6. **Content review**: Each skill should be 40-110 lines, well-structured, actionable

## Adding Tool Skills

1. `rl skills new --global <name>` — prompts for category
2. Edit `resources/skills/tools/<category>/<name>/SKILL.md`
3. Add `<!-- tags: ... -->` for LLM discoverability
4. Fill in `[FILL]` sections, keep 40-110 lines

## Adding rl Operational Skills

1. Create `resources/skills/rl/<name>/SKILL.md`
2. Add `<!-- category: rl -->` comment
3. Add `<!-- sync: always|openspec|dogfooding -->` for conditional sync
4. The skill is automatically discovered by `skills.sh`

## Skill Taxonomy

| Category | Synced when | Source |
|----------|-------------|--------|
| rl (core) | Always | `resources/skills/rl/` |
| rl (openspec) | USE_OPENSPEC=true | `resources/skills/rl/openspec-*/` |
| rl (dogfooding) | Developing rl | `resources/skills/rl/rl-development/` |
| universal | Always | `resources/skills/universal/` |
| tools | User selects | `resources/skills/tools/<category>/` |
| custom | Always (project) | Target repo `.rl/skills/` |

## Shell Scripting Conventions

- All rl scripts (`bin/`, `libexec/`, `lib/`) are **zsh** (not bash) — use zsh features (`${(qq)var}`, `${0:A:h}`, etc.). Note: `resources/core/` may contain bash scripts for target repos (e.g., `electron-smoke.sh`).
- Source `lib/common.sh` at the top of every script
- Use color variables from common.sh: `R`, `B`, `D`, `C`, `G`, `Y`, `ERR`
- Use `print -P` for colored output, `print` for plain
- Use `set -euo pipefail` in every script
- Use `setopt local_options nullglob` before glob loops that may match nothing
- Source config files with `set +u` / `set -u` guards (configs may have unset var refs)
- Use `prompt_yn`, `prompt_text`, `prompt_select`, `prompt_multiselect` for interactive input
