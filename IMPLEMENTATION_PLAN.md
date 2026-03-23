# Implementation Plan: Greptile Review Provider Support

## Goal

Add Greptile as an opt-in PR review provider alongside Copilot. The review loop should fetch, triage, fix, reply to, and re-trigger reviews from either or both providers.

## Scope

Two new config booleans (`USE_COPILOT_REVIEWS`, `USE_GREPTILE_REVIEWS`) control which providers are active. The fetch system gains the GitHub issue comments endpoint (where Greptile posts its summary and findings). The reply system learns to reply to issue comments. The loop gains provider-aware re-triggering and a "no new reviews" exit condition.

## Approach

**Config**: Two independent booleans, defaulting to `copilot=true, greptile=false` for backward compatibility.

**Fetch**: Greptile posts a summary as an issue comment (`/issues/{pr}/comments`) and may post inline findings as review comments (`/pulls/{pr}/comments`). The fetch script adds the issue comments endpoint, filters to Greptile author, and writes distinct sections in the renamed `pr-reviews.md` output file.

**Reply**: New `comment_type` field in the manifest distinguishes review comments (reply + resolve thread) from issue comments (reply only, no thread resolution).

**Loop**: Replace broken `gh pr edit --add-reviewer @copilot` with provider-conditional re-triggering. Greptile is re-triggered by posting `@greptileai` as an issue comment. Add exit condition: if no new comment IDs appear after a re-trigger cycle, the reviewer is satisfied.

**Prompt**: Provider-calibrated verification — always verify independently, but with calibrated trust levels (Copilot: high false-positive rate; Greptile: codebase-aware, higher accuracy; Human: highest priority).

## Deliverables

1. Config settings in `ralphrc.template` and `.rl/config`
2. Rename `copilot-reviews.md` → `pr-reviews.md` across all references
3. Issue comments fetch in `rl-fetch-reviews` (Greptile summary + findings)
4. Issue comment replies in `rl-reply-reviews`
5. Provider-aware re-triggering + no-new-reviews exit in `rl-loop`
6. Updated `PROMPT_review.md` and `github-pr-review` skill
7. Documentation updates

## Key Decisions

- Two booleans > single string — cleaner, no parsing
- Issue comments fetched only for Greptile — no random bot noise
- Comment ID tracking for loop exit — reliable "reviewer satisfied" signal
- Greptile summary visible to agent as context (confidence score, mermaid diagrams) but not individually triaged
- Reviews are valuable lesson material — noted for future enhancement, not in scope here
