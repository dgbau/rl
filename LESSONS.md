# Lessons Learned

Cumulative learnings from rl toolkit development.

---

## 2026-02-21: Skills should auto-fill on creation

`rl skills new --global <name>` creates an empty template with `[FILL]` markers.
This requires manual editing to be useful. Should use Claude to generate actual
technology-specific content. Filed as rl-8r4o.

## 2026-03-23: PR review comments are valuable lesson material (rl-4pl7)

Greptile and Copilot review comments often surface non-obvious project conventions,
recurring patterns, and codebase-specific knowledge. When a review finding is accepted
and fixed, that fix represents learned knowledge that could feed back into skills or
LESSONS.md. Future enhancement: auto-extract patterns from accepted review findings
and surface them as candidate skill updates or lesson entries.


