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

# Fetch ALL line-level review comments (not just Copilot)
# Filter: root comments only (not replies), not resolved
ALL_COMMENTS=$(gh api "repos/$REPO_FULL/pulls/$PR_NUMBER/comments" \
  --paginate \
  --jq '.[] | select(
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
  }' 2>/dev/null || echo "")

# Fetch ALL top-level reviews (summary comments, not just Copilot)
ALL_REVIEWS=$(gh api "repos/$REPO_FULL/pulls/$PR_NUMBER/reviews" \
  --paginate \
  --jq '.[] | select(.state != "DISMISSED") | select(.body != null and .body != "") | {
    body: .body,
    state: .state,
    id: .id,
    created_at: .created_at,
    author: .user.login,
    author_type: (if .user.login == "copilot-pull-request-reviewer" then "copilot"
                  elif .user.type == "Bot" then "bot"
                  else "human" end)
  }' 2>/dev/null || echo "")

if [[ -z "$ALL_COMMENTS" && -z "$ALL_REVIEWS" ]]; then
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
  if [[ -n "$ALL_REVIEWS" ]]; then
    echo "## Review Summaries"
    echo ""
    echo "$ALL_REVIEWS" | jq -r '"### \(.author) (\(.author_type)) -- \(.state) -- \(.created_at)\n<!-- review_id: \(.id) -->\n\n\(.body)\n"' 2>/dev/null || true
  fi

  # Human line comments first (higher priority)
  HUMAN_COMMENTS=$(echo "$ALL_COMMENTS" | jq -s '[.[] | select(.author_type == "human")]' 2>/dev/null || echo "[]")
  HUMAN_COUNT=$(echo "$HUMAN_COMMENTS" | jq 'length' 2>/dev/null || echo "0")
  if [[ "$HUMAN_COUNT" -gt 0 ]]; then
    echo "## Human Review Comments ($HUMAN_COUNT)"
    echo ""
    echo "$HUMAN_COMMENTS" | jq -r '.[] | "### \(.author): `\(.path)` (line \(.line))\n<!-- comment_id: \(.id) node_id: \(.node_id) -->\n\n> \(.body | gsub("\n"; "\n> "))\n\n<details><summary>Diff hunk</summary>\n\n```diff\n\(.diff_hunk)\n```\n\n</details>\n"' 2>/dev/null || true
  fi

  # Copilot/bot line comments
  BOT_COMMENTS=$(echo "$ALL_COMMENTS" | jq -s '[.[] | select(.author_type != "human")]' 2>/dev/null || echo "[]")
  BOT_COUNT=$(echo "$BOT_COMMENTS" | jq 'length' 2>/dev/null || echo "0")
  if [[ "$BOT_COUNT" -gt 0 ]]; then
    echo "## Copilot/Bot Review Comments ($BOT_COUNT)"
    echo ""
    echo "$BOT_COMMENTS" | jq -r '.[] | "### \(.author): `\(.path)` (line \(.line))\n<!-- comment_id: \(.id) node_id: \(.node_id) -->\n\n> \(.body | gsub("\n"; "\n> "))\n\n<details><summary>Diff hunk</summary>\n\n```diff\n\(.diff_hunk)\n```\n\n</details>\n"' 2>/dev/null || true
  fi
} > "$OUTPUT_FILE"

TOTAL_COMMENTS=$(echo "$ALL_COMMENTS" | jq -s 'length' 2>/dev/null || echo "0")
TOTAL_REVIEWS=$(echo "$ALL_REVIEWS" | jq -s 'length' 2>/dev/null || echo "0")

echo "Found $TOTAL_COMMENTS line comments ($HUMAN_COUNT human, $BOT_COUNT bot) and $TOTAL_REVIEWS review summaries."
echo "Written to: $OUTPUT_FILE"
exit 0
