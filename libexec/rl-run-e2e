#!/usr/bin/env zsh
# Note: -e is intentionally omitted. This script captures exit codes explicitly.
set -uo pipefail

# Run E2E tests and capture results for the Ralph Loop
# Usage:
#   rl loop e2e                 # Run all E2E tests
#   rl loop e2e <filter>        # Run filtered tests
#
# Exit codes (inverted for loop logic):
#   0 = tests FAILED (loop should continue fixing)
#   1 = all tests PASSED (loop should stop)
#
# Configuration:
#   Set E2E_CMD in .rl/config to customize the test command.
#   The command should produce JSON output or exit non-zero on failure.

SCRIPT_DIR="${0:A:h}"
WORK_DIR="${RL_WORK:-$SCRIPT_DIR}"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "${SCRIPT_DIR:h}")"
OUTPUT_FILE="$WORK_DIR/e2e-results.md"
RAW_OUTPUT="$WORK_DIR/.e2e-raw-output.txt"

cd "$REPO_ROOT"

# Load config (.rl/config > .ralphrc legacy fallback)
if [[ -f "$REPO_ROOT/.rl/config" ]]; then
  source "$REPO_ROOT/.rl/config"
elif [[ -f "$REPO_ROOT/.ralphrc" ]]; then
  source "$REPO_ROOT/.ralphrc"
fi

E2E_COMMAND="${E2E_CMD:-}"

if [[ -z "$E2E_COMMAND" ]]; then
  echo "ERROR: No E2E_CMD configured in .rl/config"
  echo "Set E2E_CMD to your E2E test command, e.g.:"
  echo "  E2E_CMD=\"npx cypress run --reporter json\""
  echo "  E2E_CMD=\"npx playwright test --reporter=json\""
  {
    echo "# E2E Test Results"
    echo ""
    echo "**ERROR**: No E2E_CMD configured in .rl/config"
    echo ""
    echo "Set \`E2E_CMD\` in \`.rl/config\` to your E2E test command."
  } > "$OUTPUT_FILE"
  exit 0  # Signal loop to continue (there's an issue to fix)
fi

# Append filter argument if provided
if [[ $# -ge 1 && -n "$1" ]]; then
  # Validate: only allow alphanumeric, hyphens, underscores, dots, slashes
  if [[ ! "$1" =~ ^[A-Za-z0-9_./-]+$ ]]; then
    echo "ERROR: Invalid test filter '$1'."
    exit 2
  fi
  E2E_COMMAND="$E2E_COMMAND $1"
  echo "Running E2E tests filtered to: $1"
else
  echo "Running all E2E tests..."
fi

# Run E2E tests
echo "Starting E2E: $E2E_COMMAND"
E2E_EXIT_CODE=0
eval "$E2E_COMMAND" > "$RAW_OUTPUT" 2>&1 || E2E_EXIT_CODE=$?

if [[ ! -s "$RAW_OUTPUT" ]]; then
  echo "ERROR: No E2E output captured."
  {
    echo "# E2E Test Results"
    echo ""
    echo "**ERROR**: E2E command produced no output."
    echo "Command: \`$E2E_COMMAND\`"
    echo "Exit code: $E2E_EXIT_CODE"
    echo ""
    echo "Check that E2E_CMD in .rl/config is correct and services are running."
  } > "$OUTPUT_FILE"
  rm -f "$RAW_OUTPUT"
  exit 0
fi

# If exit code is 0, all tests passed
if [[ "$E2E_EXIT_CODE" -eq 0 ]]; then
  {
    echo "# E2E Test Results"
    echo ""
    echo "## ALL TESTS PASSED"
    echo ""
    echo "Command: \`$E2E_COMMAND\`"
    echo "Run at: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  } > "$OUTPUT_FILE"
  rm -f "$RAW_OUTPUT"
  echo "All E2E tests passed!"
  exit 1  # Signal loop to STOP (all green)
fi

# Tests failed -- capture output for Claude to read
{
  echo "# E2E Test Results"
  echo ""
  echo "**E2E tests FAILED** (exit code: $E2E_EXIT_CODE)"
  echo ""
  echo "Command: \`$E2E_COMMAND\`"
  echo "Run at: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  echo ""
  echo "## Test Output"
  echo ""
  echo '```'
  # Include last 100 lines of output (enough context without overwhelming)
  tail -100 "$RAW_OUTPUT"
  echo '```'
} > "$OUTPUT_FILE"

rm -f "$RAW_OUTPUT"

echo "E2E failures written to: $OUTPUT_FILE"
exit 0  # Signal loop to CONTINUE (failures need fixing)
