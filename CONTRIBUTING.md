# Contributing to rl

## Development setup

rl dogfoods itself — it uses its own loop for development.

```bash
git clone git@github.com:dgbau/rl.git
cd rl
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
| `bin/rl` | CLI entry point (dispatcher) |
| `libexec/rl-*` | Subcommands (create, install, skills, migrate, loop, release) |
| `.rl/config`, `.tickets/`, `LESSONS.md` | Dogfooding artifacts (rl's own loop) |

**Changes to `resources/` affect every project that uses rl.** Changes to dogfooding files affect only rl development.

## Before you commit

Run backpressure (syntax check on all shell scripts):

```bash
zsh -n bin/rl libexec/rl-create libexec/rl-install libexec/rl-skills lib/common.sh libexec/rl-migrate libexec/rl-loop libexec/rl-fetch-reviews libexec/rl-reply-reviews libexec/rl-run-e2e
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

## Creating a release

After merging changes to main:

```bash
rl release --dry-run    # preview changelog and version bump
rl release              # create release (prompts for confirmation)
```

This auto-detects the version bump from conventional commits (`feat` = minor, `fix` = patch, `BREAKING CHANGE` = major), generates CHANGELOG.md, creates a git tag, advances the `stable` tag, and creates a GitHub Release.

## Dogfooding safely

When working on rl itself, be aware:
- **Don't use `--auto`** unless you've confirmed the prompt. The loop blocks it by default.
- Changes to `resources/core/`, `lib/common.sh`, or `libexec/rl-*` affect the running loop on the next iteration.
- Always run full backpressure before committing.
- If the loop breaks, recover with: `git checkout stable`

## Reporting issues

File an issue with:
- What you ran (`rl loop`, `rl install`, etc.)
- Your stack (language, framework, monorepo?)
- The error output
- Your OS and shell version (`zsh --version`)
