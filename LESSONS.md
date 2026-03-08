# Lessons Learned

Cumulative learnings from rl toolkit development.

---

## 2026-02-21: Programmatic CLI access is essential

When building The Primer (an Electron app that orchestrates rl), Claude Code could not
drive `rl create` because all prompts use `/dev/tty`. Added `--no-prompt` flag to
`create.sh` (matching `install.sh`'s existing pattern) so tools can drive project
creation programmatically. **All new CLI commands should support `--no-prompt` mode
from day one.**

## 2026-02-21: Skills should auto-fill on creation

`rl skills new --global <name>` creates an empty template with `[FILL]` markers.
This requires manual editing to be useful. Should use Claude to generate actual
technology-specific content. Filed as rl-8r4o.

## 2026-02-21: New skills added: electron, anthropic-sdk

Electron desktop apps and Anthropic SDK integration had no skill templates. Missing
skills cause Claude to make fundamental mistakes (CJS/ESM mismatch, native module
ABI version errors). Detection signals added to `install.sh` so `rl install`
auto-suggests them.

