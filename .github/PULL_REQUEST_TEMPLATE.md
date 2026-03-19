## Summary

<!-- What does this PR do? 1-3 bullet points. -->

## Type of change

- [ ] Bug fix
- [ ] New feature (skill, command, or capability)
- [ ] Refactor (no behavior change)
- [ ] Documentation

## Checklist

- [ ] Backpressure passes: `zsh -n bin/rl libexec/rl-create libexec/rl-install libexec/rl-skills lib/common.sh libexec/rl-migrate libexec/rl-loop resources/core/fetch-reviews.sh resources/core/run-e2e.sh && bash -n resources/core/reply-reviews.sh`
- [ ] Tested with `rl install` on a target repo (if changing install/skills/config)
- [ ] Conventional commit messages used
- [ ] No hardcoded paths or project-specific references

## Distributed vs dogfooding

<!-- If touching resources/, skills, or prompts: these affect ALL users. If touching .rl/, .tickets/, LESSONS.md: these are dogfooding-only. -->

- [ ] Changes to `resources/` have been tested on a target repo
- [ ] N/A — changes are dogfooding-only
