# rl Toolkit — Development Conventions

## Build & Validation

### Backpressure (run before every commit)
```bash
zsh -n bin/rl libexec/rl-create libexec/rl-install libexec/rl-skills lib/common.sh libexec/rl-migrate libexec/rl-loop resources/core/fetch-reviews.sh resources/core/run-e2e.sh && bash -n resources/core/reply-reviews.sh
```

### Testing Changes
1. Syntax check: `zsh -n <script>` for all modified shell scripts
2. Skills check: `rl skills list` shows new templates with descriptions
3. Install check: `rl install --no-prompt --no-openspec ~/tmp/test-repo` installs new core skills
4. Content review: Each skill file is 40-110 lines, well-structured, actionable

## Commit Conventions

All commits use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short description>
```

### Types
| Type | When to use |
|------|-------------|
| `feat` | New skill, template, command, or capability |
| `fix` | Bug fix in scripts or skill content |
| `refactor` | Script restructuring, no behavior change |
| `docs` | Documentation only (ARCHITECTURE.md, README.md, etc.) |
| `chore` | Tooling, config, dependencies |

### Scopes
- `skills` — changes to resources/skills/
- `core` — changes to resources/core/ (loop, prompts)
- `cli` — changes to rl, create.sh, install.sh, skills.sh
- `lib` — changes to lib/common.sh
- `docs` — documentation changes

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for:
- Dogfooding vs distribution boundary
- Skill taxonomy (layers 0-5)
- Config flow
- Detection & generation pipeline

## Key Constraints
- All scripts are zsh (not bash) — use zsh-specific features
- `install.sh` reads from `resources/`, NEVER from the repo root
- Skill templates should be 40-110 lines with `[FILL]` markers
- Every template needs a `<!-- category: ... -->` HTML comment
- Workflow skills are always installed; templates are user-selectable
