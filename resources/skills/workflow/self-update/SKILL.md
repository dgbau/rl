---
name: self-update
description: "Guides updating ralph loop files from ~/src/rl/resources/. Use when the rl toolkit has been updated and the project needs to pull in new loop files, prompts, or skills."
---

# Self-Update

Updates ralph loop files in this project from the central `~/src/rl/resources/` toolkit.

## When to Update

- After the `rl` toolkit has been updated with new features or fixes
- When you notice a mismatch between the project's ralph files and the toolkit
- When a new skill or prompt has been added to `~/src/rl/resources/`

## What Gets Updated

| Source | Destination | Notes |
|--------|-------------|-------|
| `~/src/rl/resources/core/loop.sh` | `ralph/loop.sh` | Orchestrator script |
| `~/src/rl/resources/core/PROMPT_*.md` | `ralph/PROMPT_*.md` | Mode-specific prompts |
| `~/src/rl/resources/core/fetch-reviews.sh` | `ralph/fetch-reviews.sh` | PR review fetcher |
| `~/src/rl/resources/core/run-e2e.sh` | `ralph/run-e2e.sh` | E2E test runner |
| `~/src/rl/resources/core/README.md` | `ralph/README.md` | Ralph documentation |
| `~/src/rl/resources/skills/workflow/*` | `.claude/skills/*` | Workflow skills |

## What Does NOT Get Updated (Preserve These)

- **`.ralphrc`** -- project-specific configuration; never overwrite
- **`CLAUDE.md`** -- may have project-specific customizations
- **`AGENTS.md`** -- project-specific operational guide and commands
- **`LESSONS.md`** -- project-specific cumulative learnings
- **PROMPT customizations** -- if a project has modified `ralph/PROMPT_*.md` files with local additions, those changes will be lost on update; review diffs carefully
- **Non-workflow skills** in `.claude/skills/` -- project-specific or template-generated skills are not touched

## Update Procedure

### 1. Compare ralph/ files vs ~/src/rl/resources/core/

Review what has changed before copying anything:

```bash
diff ralph/loop.sh ~/src/rl/resources/core/loop.sh
diff ralph/PROMPT_build.md ~/src/rl/resources/core/PROMPT_build.md
diff ralph/PROMPT_bootstrap.md ~/src/rl/resources/core/PROMPT_bootstrap.md
diff ralph/PROMPT_interview.md ~/src/rl/resources/core/PROMPT_interview.md
diff ralph/PROMPT_review.md ~/src/rl/resources/core/PROMPT_review.md
diff ralph/PROMPT_archive.md ~/src/rl/resources/core/PROMPT_archive.md
diff ralph/PROMPT_e2e.md ~/src/rl/resources/core/PROMPT_e2e.md
diff ralph/fetch-reviews.sh ~/src/rl/resources/core/fetch-reviews.sh
diff ralph/run-e2e.sh ~/src/rl/resources/core/run-e2e.sh
diff ralph/README.md ~/src/rl/resources/core/README.md
```

Pay attention to any local PROMPT customizations that should be preserved or re-applied after the update.

### 2. Copy updated core files (preserving .ralphrc)

```bash
cp ~/src/rl/resources/core/loop.sh ralph/loop.sh
cp ~/src/rl/resources/core/PROMPT_*.md ralph/
cp ~/src/rl/resources/core/fetch-reviews.sh ralph/
cp ~/src/rl/resources/core/run-e2e.sh ralph/
cp ~/src/rl/resources/core/README.md ralph/
chmod +x ralph/loop.sh ralph/fetch-reviews.sh ralph/run-e2e.sh
```

### 3. Update workflow skills

```bash
cp -r ~/src/rl/resources/skills/workflow/* .claude/skills/
```

### 4. If OpenSpec is enabled, update OpenSpec skills

Check `.ralphrc` for `USE_OPENSPEC=true`, then:

```bash
cp -r ~/src/rl/resources/skills/workflow-openspec/* .claude/skills/
cp -r ~/src/rl/resources/commands/opsx/* .claude/commands/opsx/
```

### 5. Check for new .ralphrc keys

Compare the project's `.ralphrc` against the template to see if new configuration keys have been added:

```bash
diff .ralphrc ~/src/rl/resources/core/ralphrc.template
```

If new keys exist in the template, add them to `.ralphrc` with appropriate project-specific values.

### 6. Review all changes

```bash
git diff ralph/ .claude/skills/
```

Verify:
- No project-specific customizations were lost
- New PROMPT files are compatible with the project's workflow
- Skills are up to date

### 7. Commit

```bash
git add ralph/ .claude/skills/
git commit -m "chore: update ralph loop files from rl toolkit"
```
