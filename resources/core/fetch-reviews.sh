#!/usr/bin/env zsh
set -euo pipefail

# Fetch ALL PR review comments (Copilot + human reviewers) for the current branch
# Outputs: ralph/copilot-reviews.md
#
# Exit codes:
#   0 -- reviews found (unresolved comments written to output file)
#   1 -- no unresolved reviews (nothing to do)
#   2 -- operational error (no PR found, gh not authenticated, API failure)

SCRIPT_DIR="${0:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"
OUTPUT_FILE="$SCRIPT_DIR/copilot-reviews.md"

cd "$REPO_ROOT"

BRANCH=$(git branch --show-current)
echo "Fetching PR reviews for branch: $BRANCH"

PR_NUMBER=$(gh pr list --head "$BRANCH" --json number --jq '.[0].number' 2>/dev/null || echo "")

if [[ -z "$PR_NUMBER" ]]; then
  echo "ERROR: No open PR found for branch '$BRANCH'"
  exit 2
fi

echo "Found PR #$PR_NUMBER"

REPO_FULL=$(gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null)
if [[ -z "$REPO_FULL" ]]; then
  echo "ERROR: Could not determine repository. Make sure 'gh' is authenticated."
  exit 2
fi

# Use temp files to avoid shell variable mangling of JSON with control characters
# (diff_hunk fields contain tabs/newlines that break echo | jq pipelines)
TMPDIR_REVIEWS=$(mktemp -d)
trap 'rm -rf "$TMPDIR_REVIEWS"' EXIT
COMMENTS_FILE="$TMPDIR_REVIEWS/comments.json"
REVIEWS_FILE="$TMPDIR_REVIEWS/reviews.json"

# Fetch ALL line-level review comments (not just Copilot)
# Filter: root comments only (not replies), not resolved
# Output as a proper JSON array to avoid JSONL parsing issues
gh api "repos/$REPO_FULL/pulls/$PR_NUMBER/comments" \
  --paginate \
  --jq '[.[] | select(
    (.in_reply_to_id == null) or (.in_reply_to_id == 0)
  ) | {
    path: .path,
    line: (.line // .original_line // "unknown"),
    body: .body,
    diff_hunk: .diff_hunk,
    id: .id,
    node_id: .node_id,
    created_at: .created_at,
    author: .user.login,
    author_type: (if .user.login == "copilot-pull-request-reviewer" then "copilot"
                  elif .user.type == "Bot" then "bot"
                  else "human" end)
  }]' > "$COMMENTS_FILE" 2>/dev/null || echo "[]" > "$COMMENTS_FILE"

# When --paginate returns multiple pages, each page produces a separate JSON array.
# Merge them into a single flat array.
if jq -e 'type == "array" and length > 0 and (.[0] | type == "array")' "$COMMENTS_FILE" >/dev/null 2>&1; then
  jq '[.[][]]' "$COMMENTS_FILE" > "$COMMENTS_FILE.tmp" && mv "$COMMENTS_FILE.tmp" "$COMMENTS_FILE"
fi

# Fetch ALL top-level reviews (summary comments, not just Copilot)
gh api "repos/$REPO_FULL/pulls/$PR_NUMBER/reviews" \
  --paginate \
  --jq '[.[] | select(.state != "DISMISSED") | select(.body != null and .body != "") | {
    body: .body,
    state: .state,
    id: .id,
    created_at: .created_at,
    author: .user.login,
    author_type: (if .user.login == "copilot-pull-request-reviewer" then "copilot"
                  elif .user.type == "Bot" then "bot"
                  else "human" end)
  }]' > "$REVIEWS_FILE" 2>/dev/null || echo "[]" > "$REVIEWS_FILE"

# Merge paginated review arrays too
if jq -e 'type == "array" and length > 0 and (.[0] | type == "array")' "$REVIEWS_FILE" >/dev/null 2>&1; then
  jq '[.[][]]' "$REVIEWS_FILE" > "$REVIEWS_FILE.tmp" && mv "$REVIEWS_FILE.tmp" "$REVIEWS_FILE"
fi

TOTAL_COMMENTS=$(jq 'length' "$COMMENTS_FILE" 2>/dev/null || echo "0")
TOTAL_REVIEWS=$(jq 'length' "$REVIEWS_FILE" 2>/dev/null || echo "0")

if [[ "$TOTAL_COMMENTS" -eq 0 && "$TOTAL_REVIEWS" -eq 0 ]]; then
  echo "No PR review comments found."
  rm -f "$OUTPUT_FILE"
  exit 1
fi

# Format output, grouping by source (human vs copilot/bot)
{
  echo "# PR Review Comments (PR #$PR_NUMBER)"
  echo ""
  echo "Branch: \`$BRANCH\`"
  echo "Repository: \`$REPO_FULL\`"
  echo "Fetched: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  echo ""

  # Top-level review summaries
  if [[ "$TOTAL_REVIEWS" -gt 0 ]]; then
    echo "## Review Summaries"
    echo ""
    jq -r '.[] | "### \(.author) (\(.author_type)) -- \(.state) -- \(.created_at)\n<!-- review_id: \(.id) -->\n\n\(.body)\n"' "$REVIEWS_FILE" 2>/dev/null || true
  fi

  # Human line comments first (higher priority)
  HUMAN_COUNT=$(jq '[.[] | select(.author_type == "human")] | length' "$COMMENTS_FILE" 2>/dev/null || echo "0")
  if [[ "$HUMAN_COUNT" -gt 0 ]]; then
    echo "## Human Review Comments ($HUMAN_COUNT)"
    echo ""
    jq -r '[.[] | select(.author_type == "human")] | .[] | "### \(.author): `\(.path)` (line \(.line))\n<!-- comment_id: \(.id) node_id: \(.node_id) -->\n\n> \(.body | gsub("\n"; "\n> "))\n\n<details><summary>Diff hunk</summary>\n\n```diff\n\(.diff_hunk)\n```\n\n</details>\n"' "$COMMENTS_FILE" 2>/dev/null || true
  fi

  # Copilot/bot line comments
  BOT_COUNT=$(jq '[.[] | select(.author_type != "human")] | length' "$COMMENTS_FILE" 2>/dev/null || echo "0")
  if [[ "$BOT_COUNT" -gt 0 ]]; then
    echo "## Copilot/Bot Review Comments ($BOT_COUNT)"
    echo ""
    jq -r '[.[] | select(.author_type != "human")] | .[] | "### \(.author): `\(.path)` (line \(.line))\n<!-- comment_id: \(.id) node_id: \(.node_id) -->\n\n> \(.body | gsub("\n"; "\n> "))\n\n<details><summary>Diff hunk</summary>\n\n```diff\n\(.diff_hunk)\n```\n\n</details>\n"' "$COMMENTS_FILE" 2>/dev/null || true
  fi
} > "$OUTPUT_FILE"

echo "Found $TOTAL_COMMENTS line comments ($HUMAN_COUNT human, $BOT_COUNT bot) and $TOTAL_REVIEWS review summaries."
echo "Written to: $OUTPUT_FILE"
exit 0
