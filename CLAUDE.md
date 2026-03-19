# rl — Ralph Loop Toolkit

This is the **rl toolkit's own development repo**. It is NOT a target project that uses the Ralph Loop — it IS the Ralph Loop toolkit.

## CRITICAL: Dogfooding vs Distribution Boundary

- `resources/` contains files that are sourced at runtime by target repos
- `.rl/config`, `CLAUDE.md`, `AGENTS.md`, `LESSONS.md`, `.tickets/`, `.claude/skills/` at the repo root are rl's OWN development loop
- **Never confuse these two contexts.** Changes to distributed resources affect all users. Changes to dogfooding files affect only rl development.

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed structure.

## Quick Reference

### Backpressure (run before every commit)
```bash
zsh -n bin/rl libexec/rl-create libexec/rl-install libexec/rl-skills lib/common.sh libexec/rl-migrate libexec/rl-loop resources/core/fetch-reviews.sh resources/core/run-e2e.sh && bash -n resources/core/reply-reviews.sh
```

### Key Files
| File | Purpose |
|------|---------|
| `bin/rl` | CLI entry point (dispatcher) |
| `libexec/rl-create` | Scaffold new Nx project |
| `libexec/rl-install` | Add Ralph Loop to existing repo (creates .rl/) |
| `libexec/rl-skills` | Manage skill templates (list, add, sync, override) |
| `libexec/rl-migrate` | Migrate repos from legacy ralph/ to .rl/ model |
| `libexec/rl-loop` | Ralph Loop orchestrator (interview, build, review, etc.) |
| `lib/common.sh` | Shared utilities (detection, prompts, generation) |

### Key Directories
| Directory | Purpose |
|-----------|---------|
| `bin/` | User-facing entry point (on PATH) |
| `libexec/` | Internal subcommands (called by dispatcher) |
| `resources/core/` | Prompts, review scripts (sourced at runtime) |
| `resources/skills/rl/` | rl operational skills (synced to repos, with sync conditions) |
| `resources/skills/universal/` | Software engineering principles (always synced) |
| `resources/skills/tools/` | Technology skills by category (user-selectable) |
| `resources/commands/` | Slash commands (OpenSpec only) |

## Rules
- Run backpressure before every commit
- Use conventional commits: `feat(scope): description`
- Append learnings to [LESSONS.md](LESSONS.md)
- Read `.claude/skills/` before starting any task
- Test changes: run `rl install` on a test repo, verify `rl skills list`
