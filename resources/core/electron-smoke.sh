#!/usr/bin/env bash
# Electron smoke test — verifies the app boots without ABI or module errors.
# Catches native module ABI mismatches and CJS/ESM boot failures that only
# manifest at Electron runtime (not in Node.js lint/test/build).
set -euo pipefail

BOOT_WAIT="${ELECTRON_SMOKE_TIMEOUT:-5}"

# On Linux without a display, use xvfb-run if available
ELECTRON_CMD=(npx electron . --no-sandbox --disable-gpu)
if [[ "$(uname)" == "Linux" && -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
  if command -v xvfb-run &>/dev/null; then
    ELECTRON_CMD=(xvfb-run --auto-servernum "${ELECTRON_CMD[@]}")
  else
    echo "WARNING: No display and xvfb-run not found — skipping Electron smoke test"
    exit 0
  fi
fi

# Launch Electron in background
"${ELECTRON_CMD[@]}" &>/dev/null &
PID=$!

# ABI mismatches and CJS/ESM errors crash immediately — wait briefly
sleep "$BOOT_WAIT"

if kill -0 "$PID" 2>/dev/null; then
  # Process survived — app booted successfully
  kill "$PID" 2>/dev/null || true
  wait "$PID" 2>/dev/null || true
  echo "Electron smoke test passed"
  exit 0
else
  # Process died before timeout — boot failure
  wait "$PID" 2>/dev/null || true
  echo "Electron smoke test FAILED — app crashed on startup"
  exit 1
fi
