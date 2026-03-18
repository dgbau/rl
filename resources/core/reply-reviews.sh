#!/usr/bin/env bash
set -euo pipefail

# Post replies to PR review comments and resolve threads using the review manifest.
# Reads: .rl/review-manifest.json (produced by Claude during review triage)
#
# Exit codes:
#   0 -- all replies posted and threads resolved (or no manifest to process)
#   1 -- partial failure (some replies/resolves failed, but continued)
#   2 -- operational error (no PR found, gh not authenticated, missing manifest)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Support RL_WORK env var for manifest location, fall back to SCRIPT_DIR
WORK_DIR="${RL_WORK:-$SCRIPT_DIR}"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST_FILE="$WORK_DIR/review-manifest.json"

cd "$REPO_ROOT"

if [[ ! -f "$MANIFEST_FILE" ]]; then
  echo "No review manifest found at $MANIFEST_FILE. Skipping reply+resolve."
  exit 0
fi

ENTRY_COUNT=$(jq 'length' "$MANIFEST_FILE" 2>/dev/null || echo "0")
if [[ "$ENTRY_COUNT" -eq 0 ]]; then
  echo "Review manifest is empty. Nothing to reply to."
  exit 0
fi

echo "Processing $ENTRY_COUNT review comment replies..."

BRANCH=$(git branch --show-current)
PR_NUMBER=$(gh pr list --head "$BRANCH" --json number --jq '.[0].number' 2>/dev/null || echo "")

if [[ -z "$PR_NUMBER" ]]; then
  echo "ERROR: No open PR found for branch '$BRANCH'"
  exit 2
fi

REPO_FULL=$(gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null)
if [[ -z "$REPO_FULL" ]]; then
  echo "ERROR: Could not determine repository."
  exit 2
fi

REPO_OWNER="${REPO_FULL%%/*}"
REPO_NAME="${REPO_FULL##*/}"

# Build comment_id → thread_node_id mapping via GraphQL
echo "Fetching review thread mappings via GraphQL..."
THREAD_MAP=$(gh api graphql -f query='
  query($owner: String!, $name: String!, $pr: Int!) {
    repository(owner: $owner, name: $name) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100) {
          nodes {
            id
            comments(first: 1) {
              nodes {
                databaseId
              }
            }
          }
        }
      }
    }
  }
' -f owner="$REPO_OWNER" -f name="$REPO_NAME" -F pr="$PR_NUMBER" \
  --jq '[.data.repository.pullRequest.reviewThreads.nodes[] | {
    comment_id: .comments.nodes[0].databaseId,
    thread_id: .id
  }]' 2>/dev/null || echo "[]")

FAILURES=0
REPLIES_POSTED=0
THREADS_RESOLVED=0

for i in $(seq 0 $((ENTRY_COUNT - 1))); do
  COMMENT_ID=$(jq -r ".[$i].comment_id" "$MANIFEST_FILE")
  REPLY_BODY=$(jq -r ".[$i].reply" "$MANIFEST_FILE")
  SHOULD_RESOLVE=$(jq -r ".[$i].resolve" "$MANIFEST_FILE")

  echo ""
  echo "--- Comment $COMMENT_ID ---"

  # Post reply
  echo "  Posting reply..."
  REPLY_RESULT=$(gh api "repos/$REPO_FULL/pulls/$PR_NUMBER/comments" \
    -X POST \
    -f body="$REPLY_BODY" \
    -F in_reply_to="$COMMENT_ID" \
    --jq '.id' 2>&1) || {
    echo "  WARNING: Failed to post reply for comment $COMMENT_ID: $REPLY_RESULT"
    FAILURES=$((FAILURES + 1))
    continue
  }
  echo "  Reply posted (id: $REPLY_RESULT)"
  REPLIES_POSTED=$((REPLIES_POSTED + 1))

  # Resolve thread if requested
  if [[ "$SHOULD_RESOLVE" == "true" ]]; then
    THREAD_ID=$(echo "$THREAD_MAP" | jq -r --argjson cid "$COMMENT_ID" '.[] | select(.comment_id == $cid) | .thread_id' 2>/dev/null || echo "")

    if [[ -z "$THREAD_ID" ]]; then
      echo "  WARNING: No thread mapping found for comment $COMMENT_ID. Cannot resolve."
      FAILURES=$((FAILURES + 1))
      continue
    fi

    echo "  Resolving thread $THREAD_ID..."
    RESOLVE_RESULT=$(gh api graphql -f query='
      mutation($threadId: ID!) {
        resolveReviewThread(input: { threadId: $threadId }) {
          thread { isResolved }
        }
      }
    ' -f threadId="$THREAD_ID" \
      --jq '.data.resolveReviewThread.thread.isResolved' 2>&1) || {
      echo "  WARNING: Failed to resolve thread for comment $COMMENT_ID: $RESOLVE_RESULT"
      FAILURES=$((FAILURES + 1))
      continue
    }
    echo "  Thread resolved: $RESOLVE_RESULT"
    THREADS_RESOLVED=$((THREADS_RESOLVED + 1))
  fi

  # Small delay to avoid rate limiting
  sleep 0.5
done

echo ""
echo "=== Reply+Resolve Summary ==="
echo "Replies posted: $REPLIES_POSTED / $ENTRY_COUNT"
echo "Threads resolved: $THREADS_RESOLVED / $ENTRY_COUNT"
if [[ $FAILURES -gt 0 ]]; then
  echo "Failures: $FAILURES"
  exit 1
fi
echo "All done."
exit 0
