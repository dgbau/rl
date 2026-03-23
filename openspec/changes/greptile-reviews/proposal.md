# Proposal: Greptile Review Provider Support

## Intent

Add Greptile as a configurable PR review provider alongside the existing Copilot support. Greptile is a GitHub App that provides codebase-aware AI code reviews with higher accuracy than Copilot (near-zero false positive rate observed in practice). Both providers can be enabled simultaneously but most users will choose one.

## Problem

The review system is hardcoded for GitHub Copilot:
- `rl-fetch-reviews` only fetches pull request review comments (`/pulls/{pr}/comments`) and review summaries (`/pulls/{pr}/reviews`) — it misses issue comments (`/issues/{pr}/comments`) where Greptile posts its summary and findings
- Re-triggering is hardcoded to `gh pr edit --add-reviewer @copilot` (which has never actually worked)
- The output file is named `copilot-reviews.md`, baking in a single-provider assumption
- `PROMPT_review.md` tells Claude to be "especially skeptical of Copilot" with no awareness of other providers
- No config settings exist to select review providers

## Scope

### In scope
- Two new boolean config settings: `USE_COPILOT_REVIEWS`, `USE_GREPTILE_REVIEWS`
- Fetch Greptile reviews from the issue comments endpoint (`/issues/{pr}/comments`)
- Rename working file from `copilot-reviews.md` to `pr-reviews.md` (update all references)
- Greptile re-trigger: post `@greptileai` comment after pushing fixes
- Reply to Greptile issue comments (different API than review comment replies)
- Update `PROMPT_review.md` for provider-aware triage (critical verification for all, calibrated trust)
- Exit condition: stop re-triggering when no new reviews appear after a cycle
- Include Greptile summary (confidence score, analysis) as context for the review agent
- Mention lessons pipeline potential (reviews as learning material)

### Out of scope
- Greptile configuration (`.greptile/` folder, rules, etc.) — that's per-repo setup done by the user
- Greptile installation/authentication — it's a GitHub App, managed at app.greptile.com
- MCP integration or API key management
- Changes to how human reviewer comments are handled

## Capabilities Affected

| Capability | Change |
|------------|--------|
| `rl-fetch-reviews` | Add issue comments endpoint, provider filtering, author detection for Greptile |
| `rl-reply-reviews` | Add issue comment reply support (distinct from review comment replies) |
| `rl-loop` review mode | Provider-aware re-triggering, clean-exit on no-new-reviews |
| `.rl/config` / `ralphrc.template` | Two new boolean settings |
| `PROMPT_review.md` | Provider-aware triage instructions |
| `github-pr-review` skill | Update for Greptile awareness |
| All references to `copilot-reviews.md` | Rename to `pr-reviews.md` |
