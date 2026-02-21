# rl Toolkit Development

<!-- This skill is for rl's OWN development — it lives in ~/src/rl/.claude/skills/
     and is NEVER distributed to target repos. The distributed skills live in
     ~/src/rl/resources/skills/ -->

## Dogfooding vs Distribution Boundary

### Distribution (installed into OTHER repos)
- `resources/core/` → copied to target's `ralph/` directory
- `resources/skills/workflow/` → always installed to target's `.claude/skills/`
- `resources/skills/workflow-openspec/` → installed when OpenSpec enabled
- `resources/skills/templates/` → user-selectable technology templates
- `resources/commands/` → slash commands for Claude Code
- `resources/SKILLS_INDEX.md` → skill catalog with tool recommendations
- `lib/common.sh` → shared shell utilities

### Dogfooding (rl's OWN development — never distributed)
- `ralph/` → rl's own ralph loop instance
- `.ralphrc` → rl's own config (`IS_RL_TOOLKIT=true`)
- `CLAUDE.md`, `AGENTS.md`, `LESSONS.md` → rl's own context files
- `ARCHITECTURE.md` → rl's architecture documentation
- `.claude/skills/` → rl's own skills (this file!)
- `.tickets/` → rl's own task tracking

**Rule:** `install.sh` reads from `resources/`, NEVER from the repo root.

## How to Test Changes

1. **Shell syntax**: `zsh -n <modified-script>`
2. **Skills list**: `rl skills list` — verify new templates appear with descriptions
3. **Install test**: Create a temp repo and run `rl install --no-prompt --no-openspec /tmp/test-repo`
4. **Installed check**: `rl skills installed` — verify category grouping works
5. **Content review**: Each skill is 40-110 lines, well-structured, actionable

## Adding New Skill Templates

1. Create directory: `resources/skills/templates/<name>/`
2. Create `SKILL.md` following `_TEMPLATE.md` structure
3. Include `<!-- category: template -->` (or language/stack) comment
4. Use `[FILL]` markers for project-specific sections
5. Keep between 40-110 lines
6. Template is automatically available via `rl skills list` / `rl skills add <name>`

## Adding New Core Skills (Workflow)

1. Create directory: `resources/skills/workflow/<name>/`
2. Create `SKILL.md` with `<!-- category: workflow -->` or `<!-- category: universal -->`
3. The skill is automatically installed by `install.sh` (it copies all `workflow/*/`)
4. No changes needed to `install.sh`

## Template Format

Follow `_TEMPLATE.md` structure:
- Title with `# Name`
- Category comment: `<!-- category: ... -->`
- Overview section
- Technology-specific sections with `[FILL]` markers
- Key Constraints section
- Where to Look section
- Common Pitfalls section
- 40-110 lines total

## Skill Taxonomy

| Layer | Category | Installed By | Location |
|-------|----------|-------------|----------|
| 0 | workflow | Always | `resources/skills/workflow/` |
| 1 | universal | Always | `resources/skills/workflow/` |
| 2 | language | User selects | `resources/skills/templates/` |
| 3 | stack | User selects | `resources/skills/templates/` |
| 4 | template | User selects | `resources/skills/templates/` |
| 5 | custom | User creates | Target repo `.claude/skills/` |

## Shell Scripting Conventions

- All scripts are **zsh** (not bash) — use zsh features (`${(qq)var}`, `${0:A:h}`, etc.)
- Source `lib/common.sh` at the top of every script
- Use color variables from common.sh: `R`, `B`, `D`, `C`, `G`, `Y`, `ERR`
- Use `print -P` for colored output, `print` for plain
- Use `set -euo pipefail` in every script
- Use `prompt_yn`, `prompt_text`, `prompt_select`, `prompt_multiselect` for interactive input
