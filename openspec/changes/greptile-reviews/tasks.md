# Tasks: Greptile Review Provider Support

## Task 1: Config settings + template

Add `USE_COPILOT_REVIEWS` and `USE_GREPTILE_REVIEWS` booleans to:
- `resources/core/ralphrc.template` (distributed to new installs)
- `.rl/config` (dogfooding)
- `libexec/rl-loop` config loading section (with defaults: copilot=true, greptile=false)

Pass provider settings to `rl-fetch-reviews` and `rl-reply-reviews` via environment variables.

## Task 2: Rename `copilot-reviews.md` → `pr-reviews.md`

Update all references across the codebase:
- `libexec/rl-fetch-reviews` (OUTPUT_FILE)
- `resources/core/PROMPT_review.md`
- `resources/skills/rl/github-pr-review/SKILL.md`
- `.rl/skills/github-pr-review/SKILL.md`
- `.gitignore`
- `libexec/rl-migrate` (if applicable)
- `libexec/rl-install` (if applicable)
- `README.md`, `ARCHITECTURE.md`, `resources/core/README.md`

## Task 3: Fetch issue comments in `rl-fetch-reviews`

When `USE_GREPTILE_REVIEWS=true`:
- Hit `GET /repos/{o}/{r}/issues/{pr}/comments` endpoint
- Filter to Greptile author only (`greptile[bot]` or login containing `greptile`)
- Separate Greptile summary (first/main comment) from any follow-up comments
- Write Greptile-specific sections in `pr-reviews.md` with `issue_comment_id` annotations
- Respect provider toggles: skip Copilot sections when `USE_COPILOT_REVIEWS=false`, skip Greptile when `USE_GREPTILE_REVIEWS=false`
- Write fetched comment IDs to `.rl/last-review-ids.txt` for exit detection

## Task 4: Reply to issue comments in `rl-reply-reviews`

- Read `comment_type` field from manifest entries
- For `"review"` type: existing behavior (reply + resolve thread)
- For `"issue"` type: `POST /repos/{o}/{r}/issues/{pr}/comments` with reply body
- Issue comments cannot be resolved — just reply

## Task 5: Provider-aware re-triggering + exit in `rl-loop`

- Replace hardcoded `gh pr edit --add-reviewer @copilot` with provider-conditional logic
- When `USE_GREPTILE_REVIEWS=true`: post `@greptileai` issue comment to re-trigger
- When `USE_COPILOT_REVIEWS=true`: keep existing re-request (for compat)
- Add no-new-reviews exit: compare current review IDs against `.rl/last-review-ids.txt` — if identical, exit loop with "reviewer satisfied" message
- Clean up `.rl/last-review-ids.txt` at start of review mode

## Task 6: Update `PROMPT_review.md` + review skill

- Rename `copilot-reviews.md` reference to `pr-reviews.md`
- Replace "be especially skeptical of Copilot" with provider-calibrated verification:
  - All sources: independently verify against current code
  - Copilot: high false-positive rate, verify carefully
  - Greptile: codebase-aware, higher accuracy, still verify
  - Human: highest priority
- Add guidance for reading Greptile summary (confidence score, mermaid diagrams, file breakdown)
- Update manifest format docs to include `comment_type` field
- Update `github-pr-review` skill in `resources/skills/rl/`

## Task 7: Documentation + LESSONS.md note

- Update `ARCHITECTURE.md` review system description
- Update `README.md` if it references review providers
- Add LESSONS.md entry noting that review content is valuable lesson material (future enhancement)
