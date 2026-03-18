# Contributing to rl

## Development setup

rl dogfoods itself — it uses its own loop for development.

```bash
git clone https://github.com/anthropic/rl.git <your-path>/rl
cd <your-path>/rl
./setup.sh
```

## Repo structure

There's a critical boundary between **toolkit source** (what gets distributed) and **dogfooding** (rl developing itself):

| Path | Role |
|------|------|
| `resources/core/` | Loop runtime — sourced at runtime by target repos |
| `resources/skills/` | Skill source of truth — synced to repos on each `rl loop` |
| `resources/commands/` | Slash commands (OpenSpec only) |
| `lib/common.sh` | Shared shell utilities |
| `rl`, `create.sh`, `install.sh`, `skills.sh`, `migrate.sh` | CLI entry points |
| `.rl/config`, `.tickets/`, `LESSONS.md` | Dogfooding artifacts (rl's own loop) |

**Changes to `resources/` affect every project that uses rl.** Changes to dogfooding files affect only rl development.

## Before you commit

Run backpressure (syntax check on all shell scripts):

```bash
zsh -n rl create.sh install.sh skills.sh lib/common.sh migrate.sh resources/core/loop.sh resources/core/fetch-reviews.sh resources/core/run-e2e.sh && bash -n resources/core/reply-reviews.sh
```

## Commit style

[Conventional commits](https://www.conventionalcommits.org/):

```
feat(skills): add new technology template for Svelte
fix(loop): handle missing .rl/config gracefully
docs(readme): expand troubleshooting section
refactor(install): extract backpressure detection
```

Common scopes: `loop`, `skills`, `install`, `create`, `migrate`, `common`, `readme`.

## Adding a tool skill

1. `rl skills new --global my-skill` (prompts for category: languages, frameworks, platforms, etc.)
2. Edit the generated SKILL.md under `resources/skills/tools/<category>/my-skill/`
3. Fill in all `[FILL]` sections and add `<!-- tags: ... -->` for LLM discoverability
4. Keep it 40-110 lines — skills should be focused, not encyclopedic

## Adding an rl operational skill

These are synced to every rl-managed project. They teach Claude how to operate the loop:

1. Create `resources/skills/rl/my-skill/SKILL.md`
2. Add `<!-- category: rl -->` comment
3. Optionally add `<!-- sync: openspec -->` or `<!-- sync: dogfooding -->` for conditional sync
4. Test by running `rl skills sync` in a target repo

## Reporting issues

File an issue with:
- What you ran (`rl loop`, `rl install`, etc.)
- Your stack (language, framework, monorepo?)
- The error output
- Your OS and shell version (`zsh --version`)
