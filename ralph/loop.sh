#!/usr/bin/env zsh
set -euo pipefail

# Ralph Loop -- AI development orchestrator (tk + Claude Code)
#
# INTERACTIVE (dialogue between human and agent):
#   ./ralph/loop.sh interview        # Claude interviews you, creates proposal
#   ./ralph/loop.sh bootstrap        # Claude creates tk tickets from the proposal
#   ./ralph/loop.sh                  # Build one ticket (you review between iterations)
#   ./ralph/loop.sh archive          # Merge completed OpenSpec change into specs
#   ./ralph/loop.sh review           # Address PR review feedback
#   ./ralph/loop.sh e2e              # Fix E2E test failures
#
# AUTONOMOUS (silent, detached, end-to-end):
#   ./ralph/loop.sh --auto --pr      # Detects state, chains modes, builds to PR
#   ./ralph/loop.sh --auto --pr 20   # Same, max 20 build iterations
#   ./ralph/loop.sh review --auto    # Autonomous review cycle
#   ./ralph/loop.sh e2e --auto       # Autonomous E2E fix cycle
#
# FLAGS:
#   --auto          Run headless (no human interaction)
#   --pr            Create draft PR, mark ready when done (implies --push)
#   --push          Push to remote after each iteration (default in --auto)
#   --no-push       Don't push (default in interactive mode)
#
# SAFETY: Ralph NEVER merges or closes PRs. Humans merge.

SCRIPT_DIR="${0:A:h}"
REPO_ROOT="${SCRIPT_DIR:h}"

# Load project configuration from .ralphrc
if [[ -f "$REPO_ROOT/.ralphrc" ]]; then
  source "$REPO_ROOT/.ralphrc"
fi

# Configuration (override via environment, then .ralphrc, then defaults)
BASE_BRANCH="${RALPH_BASE_BRANCH:-${BASE_BRANCH:-main}}"
CLAUDE_MODEL="${RALPH_MODEL:-${CLAUDE_MODEL:-opus}}"
REVIEW_WAIT_SECONDS="${RALPH_REVIEW_WAIT:-${REVIEW_WAIT:-90}}"
DEFAULT_MAX_ITERATIONS="${RALPH_MAX_ITERATIONS:-${MAX_ITERATIONS:-25}}"
BACKPRESSURE="${BACKPRESSURE_CMD:-npx nx affected -t lint test build}"
USE_OPENSPEC="${USE_OPENSPEC:-false}"

# Defaults
MODE="build"
MAX_ITERATIONS=0
AUTO_MODE=false
PR_MODE=false
PUSH_MODE=""

# Parse arguments (order-independent)
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    interview|bootstrap|archive|plan|review|e2e|build)
      MODE="$1"
      shift
      ;;
    --auto)
      AUTO_MODE=true
      shift
      ;;
    --pr)
      PR_MODE=true
      shift
      ;;
    --push)
      PUSH_MODE=true
      shift
      ;;
    --no-push)
      PUSH_MODE=false
      shift
      ;;
    [0-9]*)
      MAX_ITERATIONS="$1"
      shift
      ;;
    -h|--help)
      head -26 "$0" | tail -24
      exit 0
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done

# Derive push behavior
if [[ -z "$PUSH_MODE" ]]; then
  if [[ "$AUTO_MODE" == "true" ]]; then
    PUSH_MODE=true
  else
    PUSH_MODE=false
  fi
fi

if [[ "$PR_MODE" == "true" ]]; then
  PUSH_MODE=true
fi

# Handle legacy "plan" mode
if [[ "$MODE" == "plan" ]]; then
  echo "NOTE: 'plan' mode is now 'interview'. Redirecting..."
  MODE="interview"
fi

# Default iterations
if [[ $MAX_ITERATIONS -eq 0 ]]; then
  case "$MODE" in
    interview|bootstrap|archive)
      MAX_ITERATIONS=1
      ;;
    *)
      if [[ "$AUTO_MODE" == "true" ]]; then
        MAX_ITERATIONS="$DEFAULT_MAX_ITERATIONS"
      else
        MAX_ITERATIONS=1
      fi
      ;;
  esac
fi

# Map mode to prompt file
typeset -A PROMPT_FILES=(
  [interview]="$SCRIPT_DIR/PROMPT_interview.md"
  [bootstrap]="$SCRIPT_DIR/PROMPT_bootstrap.md"
  [build]="$SCRIPT_DIR/PROMPT_build.md"
  [archive]="$SCRIPT_DIR/PROMPT_archive.md"
  [review]="$SCRIPT_DIR/PROMPT_review.md"
  [e2e]="$SCRIPT_DIR/PROMPT_e2e.md"
)

PROMPT_FILE="${PROMPT_FILES[$MODE]}"

# Verify we're in a git repo and on a feature branch
cd "$REPO_ROOT"
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" == "$BASE_BRANCH" || "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
  echo "ERROR: You are on '$CURRENT_BRANCH'. Create a feature branch first:"
  echo "  git checkout -b ralph/my-feature"
  exit 1
fi

# Verify prompt file exists (skip for auto pipeline -- we check per-stage)
if [[ "$AUTO_MODE" != "true" || "$MODE" != "build" ]] && [[ ! -f "$PROMPT_FILE" ]]; then
  echo "ERROR: Prompt file not found: $PROMPT_FILE"
  exit 1
fi

# Display banner
echo "============================================"
echo "  Ralph Loop -- $MODE mode"
if [[ "$AUTO_MODE" == "true" ]]; then
  echo "  Execution: AUTONOMOUS (headless)"
else
  echo "  Execution: INTERACTIVE (dialogue)"
fi
echo "  Max iterations: $MAX_ITERATIONS"
echo "  Push: $PUSH_MODE | PR: $PR_MODE"
echo "  Branch: $CURRENT_BRANCH -> $BASE_BRANCH"
echo "  Model: $CLAUDE_MODEL"
echo "============================================"

# ============================================
# Helper functions
# ============================================

run_backpressure() {
  echo ""
  echo "Running backpressure: $BACKPRESSURE ..."
  if eval "$BACKPRESSURE" 2>&1; then
    echo "Backpressure PASSED."
    return 0
  else
    echo "Backpressure FAILED."
    return 1
  fi
}

run_claude() {
  local prompt_source="$1"

  if [[ "$AUTO_MODE" == "true" ]]; then
    cat "$prompt_source" | claude -p --dangerously-skip-permissions --model "$CLAUDE_MODEL" --verbose
  else
    echo ""
    echo "Starting interactive Claude Code session..."
    echo "  Prompt: $prompt_source"
    echo "  You can watch, guide, or interrupt Claude as it works."
    echo "  When Claude finishes, exit the session (type /exit or Ctrl+C)."
    echo ""
    claude --model "$CLAUDE_MODEL" --verbose "$(cat "$prompt_source")" || true
  fi
}

run_claude_selfheal() {
  local message="$1"
  echo "$message" | claude -p --dangerously-skip-permissions --model "$CLAUDE_MODEL" --verbose
}

maybe_push() {
  if [[ "$PUSH_MODE" == "true" ]]; then
    echo "Pushing changes..."
    git push origin "$CURRENT_BRANCH" 2>&1 || true
  else
    echo "(Skipping push -- use --push or --auto to push automatically)"
  fi
}

get_pr_number() {
  gh pr list --head "$CURRENT_BRANCH" --json number --jq '.[0].number' 2>/dev/null || echo ""
}

create_draft_pr() {
  local title="Ralph: ${CURRENT_BRANCH#ralph/}"
  local body="Automated draft PR created by Ralph Loop. Tasks tracked via \`tk ls\`."

  echo "Creating draft PR: $title"
  gh pr create --draft \
    --base "$BASE_BRANCH" \
    --title "$title" \
    --body "$body" 2>&1 || echo "WARNING: Failed to create draft PR"
}

# Check if all tk task tickets are complete
all_tasks_complete() {
  local open_count
  open_count=$(tk ls --status=open 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$open_count" -gt 0 ]]; then
    return 1
  fi
  local ip_count
  ip_count=$(tk ls --status=in_progress 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$ip_count" -gt 0 ]]; then
    return 1
  fi
  return 0
}

# Check if tickets exist at all
has_tickets() {
  local count
  count=$(tk ls 2>/dev/null | wc -l | tr -d ' ')
  [[ "$count" -gt 0 ]]
}

# Check if an OpenSpec change proposal exists
has_openspec_change() {
  if [[ "$USE_OPENSPEC" != "true" ]]; then
    return 1
  fi
  local changes
  changes=$(OPENSPEC_TELEMETRY=0 npx openspec list 2>/dev/null | grep -v "^$" | grep -v "No active" || true)
  [[ -n "$changes" ]]
}

# Check if an IMPLEMENTATION_PLAN.md exists (non-OpenSpec alternative)
has_implementation_plan() {
  [[ -f "$REPO_ROOT/IMPLEMENTATION_PLAN.md" ]]
}

# Find the active OpenSpec change ID from the epic ticket's external-ref
get_active_change_id() {
  for ticket_file in .tickets/*.md; do
    [[ -f "$ticket_file" ]] || continue
    local ext_ref
    ext_ref=$(sed -n '/^---$/,/^---$/p' "$ticket_file" | grep "^external-ref:" | sed 's/^external-ref: *//' || true)
    if [[ "$ext_ref" == openspec:* ]]; then
      echo "${ext_ref#openspec:}"
      return
    fi
  done
  echo ""
}

# Mark PR as ready for review -- Ralph NEVER merges or closes PRs
mark_pr_ready() {
  local pr_number="$1"
  echo "All tasks complete! Marking PR #$pr_number as ready for review..."
  echo "(Ralph does NOT merge PRs. A human must review and merge.)"

  gh pr ready "$pr_number" 2>&1 || true

  local completed_items
  completed_items=$(tk closed --limit=20 2>/dev/null || echo "See tk closed for details")

  gh pr edit "$pr_number" \
    --body "$(cat <<EOF
## Summary

Completed by Ralph Loop autonomous development.

### Completed Tickets
\`\`\`
$completed_items
\`\`\`

## Validation
- All unit tests passing
- Lint clean
- Build successful
- Review feedback addressed

## Requires Human Review
- [ ] Code review
- [ ] E2E test verification (\`./ralph/loop.sh e2e\`)
- [ ] Human merges when satisfied
EOF
)" 2>&1 || true
}

maybe_manage_pr() {
  if [[ "$PR_MODE" != "true" ]]; then
    return
  fi

  local pr_number
  pr_number=$(get_pr_number)

  if [[ -z "$pr_number" ]]; then
    create_draft_pr
    pr_number=$(get_pr_number)
    echo "Draft PR #$pr_number created."
  fi

  if all_tasks_complete; then
    echo "All tk tickets are complete!"
    mark_pr_ready "$pr_number"
  fi
}

prompt_continue() {
  if [[ "$AUTO_MODE" == "true" ]]; then
    return 0
  fi

  echo ""
  echo "============================================"
  echo "  Iteration complete. Review the changes."
  echo "============================================"
  echo ""
  echo "  [enter]  Continue to next iteration"
  echo "  s        Skip to push (no more iterations)"
  echo "  q        Quit (no push)"
  echo ""
  printf "Continue? [enter/s/q] " > /dev/tty
  read -r choice < /dev/tty
  case "$choice" in
    s|S)
      echo "Skipping to push..."
      maybe_push
      maybe_manage_pr
      return 1
      ;;
    q|Q)
      echo "Quitting. Changes are committed locally."
      return 1
      ;;
    *)
      return 0
      ;;
  esac
}

# ============================================
# Mode: interview (always interactive)
# ============================================
run_interview_mode() {
  if [[ "$AUTO_MODE" == "true" ]]; then
    echo "ERROR: Interview mode requires human dialogue. Run without --auto:"
    echo "  ./ralph/loop.sh interview"
    exit 1
  fi

  echo ""
  echo "--- Interview mode ---"
  echo "Claude will interview you about what you want built,"
  if [[ "$USE_OPENSPEC" == "true" ]]; then
    echo "then create an OpenSpec proposal and IMPLEMENTATION_PLAN.md."
  else
    echo "then create an IMPLEMENTATION_PLAN.md and prepare for ticket creation."
  fi
  echo ""

  run_claude "$PROMPT_FILE"
  maybe_push

  echo ""
  echo "============================================"
  echo "  Interview complete."
  echo "  Next: ./ralph/loop.sh bootstrap"
  echo "============================================"
}

# ============================================
# Mode: bootstrap
# ============================================
run_bootstrap_mode() {
  echo ""
  echo "--- Bootstrap mode ---"
  echo "Claude will read the proposal and create tk tickets."
  echo ""

  if [[ "$USE_OPENSPEC" == "true" ]]; then
    if ! has_openspec_change; then
      echo "ERROR: No OpenSpec change found. Run interview first:"
      echo "  ./ralph/loop.sh interview"
      exit 1
    fi
  else
    if ! has_implementation_plan; then
      echo "ERROR: No IMPLEMENTATION_PLAN.md found. Run interview first:"
      echo "  ./ralph/loop.sh interview"
      exit 1
    fi
  fi

  run_claude "$PROMPT_FILE"
  maybe_push

  echo ""
  echo "Ticket queue:"
  tk ready 2>/dev/null || echo "(no tickets ready)"
  echo ""
  echo "============================================"
  echo "  Bootstrap complete."
  echo "  Next: ./ralph/loop.sh    (or ./ralph/loop.sh --auto --pr)"
  echo "============================================"
}

# ============================================
# Mode: archive
# ============================================
run_archive_mode() {
  if [[ "$USE_OPENSPEC" != "true" ]]; then
    echo "Archive mode requires OpenSpec. Skipping."
    return
  fi

  echo ""
  echo "--- Archive mode ---"

  local change_id
  change_id=$(get_active_change_id)
  if [[ -n "$change_id" ]]; then
    echo "Archiving OpenSpec change: $change_id"
  else
    echo "Archiving OpenSpec change..."
  fi
  echo ""

  run_claude "$PROMPT_FILE"
  maybe_push
  maybe_manage_pr

  echo ""
  echo "============================================"
  echo "  Archive complete. Specs updated."
  echo "============================================"
}

# ============================================
# Mode: review
# ============================================
run_review_mode() {
  local iteration=0
  while true; do
    iteration=$((iteration + 1))
    echo ""
    echo "--- Review iteration $iteration / $MAX_ITERATIONS ---"

    echo "Fetching PR reviews..."
    local fetch_exit=0
    "$SCRIPT_DIR/fetch-reviews.sh" || fetch_exit=$?
    if [[ $fetch_exit -eq 1 ]]; then
      echo "No unresolved PR reviews found. Done!"
      break
    elif [[ $fetch_exit -ge 2 ]]; then
      echo "ERROR: Failed to fetch reviews (exit code $fetch_exit)."
      exit 1
    fi

    run_claude "$PROMPT_FILE"

    if ! run_backpressure; then
      echo "WARNING: Backpressure failed. Attempting self-heal..."
      run_claude_selfheal "The last backpressure run ($BACKPRESSURE) FAILED. Fix all failures."
      if ! run_backpressure; then
        echo "ERROR: Backpressure still failing. Stopping."
        exit 1
      fi
    fi

    maybe_push
    maybe_manage_pr

    if [[ $iteration -ge $MAX_ITERATIONS ]]; then
      echo "Reached max iterations ($MAX_ITERATIONS). Stopping."
      break
    fi

    if ! prompt_continue; then break; fi

    if [[ "$AUTO_MODE" == "true" && "$PUSH_MODE" == "true" ]]; then
      echo "Waiting ${REVIEW_WAIT_SECONDS}s for re-review..."
      sleep "$REVIEW_WAIT_SECONDS"
    fi
  done
}

# ============================================
# Mode: e2e
# ============================================
run_e2e_mode() {
  local iteration=0
  local -a e2e_args=()
  if [[ -n "${1:-}" ]]; then
    e2e_args=("$1")
  fi

  while true; do
    iteration=$((iteration + 1))
    echo ""
    echo "--- E2E iteration $iteration / $MAX_ITERATIONS ---"

    echo "Running E2E tests..."
    if "$SCRIPT_DIR/run-e2e.sh" "${e2e_args[@]+"${e2e_args[@]}"}"; then
      echo "E2E failures detected. Addressing with Claude Code..."
      run_claude "$PROMPT_FILE"
      maybe_push
    else
      echo "All E2E tests passing! Done."
      break
    fi

    if [[ $iteration -ge $MAX_ITERATIONS ]]; then
      echo "Reached max iterations ($MAX_ITERATIONS). Stopping."
      break
    fi

    if ! prompt_continue; then break; fi
  done
}

# ============================================
# Mode: build
# ============================================
run_build_mode() {
  local iteration=0

  while true; do
    iteration=$((iteration + 1))
    echo ""
    echo "--- Build iteration $iteration / $MAX_ITERATIONS ---"

    # Show ticket queue (tasks only, not epics)
    echo "Ticket queue:"
    tk ready 2>/dev/null | grep -v '\[.*epic' || echo "(no ready tickets)"
    echo ""

    run_claude "$PROMPT_FILE"

    if ! run_backpressure; then
      echo ""
      echo "WARNING: Backpressure failed. Attempting self-heal..."

      run_claude_selfheal "The last backpressure run ($BACKPRESSURE) FAILED. Read the errors, fix all lint/test/build failures, then run backpressure again. Do NOT commit until all checks pass."

      if ! run_backpressure; then
        echo "ERROR: Backpressure still failing. Stopping."
        echo "Fix manually and resume: ./ralph/loop.sh"
        exit 1
      fi
    fi

    maybe_push
    maybe_manage_pr

    if all_tasks_complete; then
      echo ""
      echo "All tk tickets are complete!"
      if [[ "$USE_OPENSPEC" == "true" ]] && [[ -f "$SCRIPT_DIR/PROMPT_archive.md" ]]; then
        echo "Running archive..."
        run_claude "$SCRIPT_DIR/PROMPT_archive.md"
        maybe_push
      fi
      maybe_manage_pr
      break
    fi

    if [[ $iteration -ge $MAX_ITERATIONS ]]; then
      echo "Reached max iterations ($MAX_ITERATIONS). Stopping."
      break
    fi

    if ! prompt_continue; then break; fi
  done

  echo ""
  echo "============================================"
  echo "  Ralph Loop finished (build mode)"
  echo "  Iterations: $iteration"
  echo "============================================"
}

# ============================================
# Autonomous pipeline
# ============================================
run_auto_pipeline() {
  echo ""
  echo "--- Autonomous pipeline: detecting state ---"

  local has_change=false
  local has_plan=false
  local has_tix=false

  if has_openspec_change; then
    has_change=true
    echo "  OpenSpec change: found"
  else
    echo "  OpenSpec change: none"
  fi

  if has_implementation_plan; then
    has_plan=true
    echo "  Implementation plan: found"
  else
    echo "  Implementation plan: none"
  fi

  if has_tickets; then
    has_tix=true
    echo "  Tickets: found ($(tk ls 2>/dev/null | wc -l | tr -d ' '))"
  else
    echo "  Tickets: none"
  fi

  echo ""

  # Decision tree
  if [[ "$has_change" == "false" && "$has_plan" == "false" && "$has_tix" == "false" ]]; then
    echo "ERROR: No proposal, plan, or tickets found."
    echo "Run interview mode first (requires human dialogue):"
    echo "  ./ralph/loop.sh interview"
    exit 1
  fi

  # Bootstrap if needed
  if [[ "$has_tix" == "false" ]]; then
    echo "--- Auto-bootstrapping: creating tickets from proposal ---"
    run_claude "$SCRIPT_DIR/PROMPT_bootstrap.md"
    maybe_push
    echo ""
    echo "Bootstrap complete. Tickets created:"
    tk ready 2>/dev/null || echo "(none)"
    echo ""
  fi

  # Build loop
  run_build_mode
}

# ============================================
# Main dispatch
# ============================================
case "$MODE" in
  interview)
    run_interview_mode
    ;;
  bootstrap)
    run_bootstrap_mode
    ;;
  archive)
    run_archive_mode
    ;;
  review)
    run_review_mode
    ;;
  e2e)
    run_e2e_mode "${POSITIONAL_ARGS[@]+"${POSITIONAL_ARGS[@]}"}"
    ;;
  build)
    if [[ "$AUTO_MODE" == "true" ]]; then
      run_auto_pipeline
    else
      run_build_mode
    fi
    ;;
  *)
    echo "Unknown mode: $MODE"
    exit 1
    ;;
esac
