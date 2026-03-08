# rl — Ralph Loop Toolkit

This is the **rl toolkit's own development repo**. It is NOT a target project that uses the Ralph Loop — it IS the Ralph Loop toolkit.

## CRITICAL: Dogfooding vs Distribution Boundary

- `resources/` contains files that get installed into OTHER repos via `rl install`
- `ralph/`, `.ralphrc`, `CLAUDE.md`, `AGENTS.md`, `LESSONS.md`, `.tickets/`, `.claude/skills/` at the repo root are rl's OWN development loop
- **Never confuse these two contexts.** Changes to distributed resources affect all users. Changes to dogfooding files affect only rl development.

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed structure.

## Quick Reference

### Backpressure (run before every commit)
```bash
zsh -n rl create.sh install.sh skills.sh lib/common.sh
```

### Key Files
| File | Purpose |
|------|---------|
| `rl` | CLI entry point (dispatcher) |
| `create.sh` | Scaffold new Nx project (supports `--no-prompt` for programmatic use) |
| `install.sh` | Add Ralph Loop to existing repo |
| `skills.sh` | Manage skill templates |
| `lib/common.sh` | Shared utilities (detection, prompts, generation) |

### Key Directories
| Directory | Purpose |
|-----------|---------|
| `resources/core/` | Loop files copied to target repos |
| `resources/skills/workflow/` | Core skills (always installed) |
| `resources/skills/workflow-openspec/` | OpenSpec skills (optional) |
| `resources/skills/templates/` | Technology templates (user-selectable) |
| `resources/commands/` | Slash commands (OpenSpec only) |

## Rules
- Run backpressure before every commit
- Use conventional commits: `feat(scope): description`
- Append learnings to [LESSONS.md](LESSONS.md)
- Read `.claude/skills/` before starting any task
- Test changes: run `rl install` on a test repo, verify `rl skills list`
