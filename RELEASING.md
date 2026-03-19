# Releasing rl

This document covers how rl's versioning and release process works. This applies **only to the rl toolkit itself** — target projects that use rl have their own release processes. rl does not impose versioning on the projects it manages.

## Overview

rl uses [semantic versioning](https://semver.org/) with version bumps derived automatically from [conventional commit](https://www.conventionalcommits.org/) messages. The `rl release` command handles the entire process: scanning commits, determining the version bump, generating the changelog, tagging, and publishing a GitHub Release.

## Commit conventions

Every commit to rl must use the conventional commit format:

```
<type>(<scope>): <short description>
```

### Types and their release impact

| Type | Release impact | When to use |
|------|---------------|-------------|
| `feat` | **Minor** bump (0.1.0 → 0.2.0) | New skill, command, capability, or user-facing behavior |
| `fix` | **Patch** bump (0.1.0 → 0.1.1) | Bug fix in scripts, skills, or prompts |
| `refactor` | None | Code restructuring with no behavior change |
| `docs` | None | Documentation only |
| `chore` | None | Tooling, config, dependency updates |
| `test` | None | Adding or updating tests |
| `perf` | None | Performance improvement |

A commit with `BREAKING CHANGE` anywhere in the body triggers a **major** bump (0.x.y → 1.0.0) regardless of the type prefix.

Non-releasable types (`docs`, `chore`, `refactor`, etc.) are still included in the changelog when a release happens — they just don't trigger one on their own.

### Common scopes

`loop`, `skills`, `install`, `create`, `migrate`, `release`, `common`, `review`

### Examples

```bash
feat(skills): add Svelte technology template
fix(loop): handle missing .rl/config gracefully
refactor(install): extract backpressure detection into helper
docs(readme): expand troubleshooting section
chore: update .gitignore patterns
```

## The release command

```bash
rl release              # auto-detect version bump from commits since last tag
rl release v1.0.0       # force a specific version (skips commit scanning)
rl release --dry-run    # preview changelog and version without making changes
```

### What it does

1. **Finds the latest version tag** (`v*` tags only, ignores `stable`)
2. **Scans commits since that tag** for `feat`, `fix`, and `BREAKING CHANGE`
3. **Determines the bump type** — if no releasable commits exist, exits with a message
4. **Generates a changelog entry** grouped by type (Features / Bug Fixes / Refactoring / Documentation / Maintenance / Other)
5. **Prompts for confirmation** (unless `--dry-run`)
6. **Updates CHANGELOG.md** — prepends the new entry after the header
7. **Commits** the changelog update as `chore(release): vX.Y.Z`
8. **Creates a git tag** (`vX.Y.Z`) with an annotated message
9. **Advances the `stable` tag** to point to the new release
10. **Pushes** commits and tags to the remote
11. **Creates a GitHub Release** via `gh release create`

### When no releasable commits exist

If only `docs`, `chore`, `refactor`, etc. commits exist since the last tag, `rl release` prints:

```
No releasable commits since v0.1.0.
Only feat, fix, and BREAKING CHANGE trigger a release.
Use 'rl release vX.Y.Z' to force a release.
```

This prevents empty or meaningless version bumps. Use the force syntax if you want to release anyway.

## The `stable` tag

The `stable` tag always points to the latest release. It exists for **dogfooding safety**.

When rl develops itself using its own loop, the agent modifies the same scripts, skills, and prompts that the loop runs from. If a self-modification introduces a bug that breaks the loop, `stable` provides a known-good recovery point:

```bash
git checkout stable     # recover from a broken self-modification
```

For users of rl (not contributors), the `stable` tag is not relevant — rl runs from wherever it's cloned.

## Updating rl

```bash
rl update                                            # pull latest from main
git -C $(which rl | xargs dirname)/.. checkout v0.2.0  # pin to a specific release
```

`rl update` runs `git pull --ff-only` on the rl repo. This gives you the latest main branch, which may include unreleased changes. To pin to a tested release, check out a version tag.

## Scope: rl toolkit only

`rl release` is hardcoded to operate on the rl toolkit repository (`cd "$RL_ROOT"`). It does not affect target projects.

Target projects use rl for development (interview, build, review) but manage their own versioning and releases independently. rl makes conventional commits in target repos, which projects can use with their own release tooling if they choose — but rl does not provide or enforce this.

## Pre-release checklist

Before running `rl release`:

1. Ensure you're on `main` with a clean working tree
2. Run backpressure: `zsh -n bin/rl libexec/rl-create libexec/rl-install libexec/rl-skills lib/common.sh libexec/rl-migrate libexec/rl-loop libexec/rl-fetch-reviews libexec/rl-reply-reviews libexec/rl-run-e2e`
3. Test key commands on a scratch repo: `rl install`, `rl skills list`
4. Preview: `rl release --dry-run`
5. Release: `rl release`
