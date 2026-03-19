#!/usr/bin/env zsh
# setup.sh — rl toolkit installer wizard
# Run: curl -sL <url>/setup.sh | zsh   OR   zsh setup.sh
#
# Checks for / installs all dependencies, adds rl to PATH.

set -euo pipefail

# ---------------------------------------------------------------------------
# Colors & helpers
# ---------------------------------------------------------------------------
R=$'\033[0m'
B=$'\033[1m'
D=$'\033[2m'
C=$'\033[38;5;214m'   # gold
G=$'\033[38;5;106m'   # green
Y=$'\033[38;5;220m'   # yellow
E=$'\033[38;5;196m'   # red

ok()   { print "  ${G}✔${R} $1" }
warn() { print "  ${Y}⚠${R} $1" }
fail() { print "  ${E}✘${R} $1" }
ask()  { print -n "  ${C}?${R} $1 " }

# ---------------------------------------------------------------------------
# Detect rl root
# ---------------------------------------------------------------------------
if [[ -f "${0:A:h}/bin/rl" ]]; then
  RL_DIR="${0:A:h}"
elif [[ -f "./bin/rl" ]]; then
  RL_DIR="${PWD}"
else
  print "${E}${B}Error:${R} Run this script from the rl repo directory."
  exit 1
fi

print ""
print "${C}${B}  rl — Ralph Loop Toolkit Setup${R}"
print "${D}  ─────────────────────────────${R}"
print ""

# ---------------------------------------------------------------------------
# 1. Check / add to PATH
# ---------------------------------------------------------------------------
print "${B}Checking PATH...${R}"

if (( $+commands[rl] )) && [[ "${commands[rl]:A:h}" == "$RL_DIR/bin" ]]; then
  ok "rl is already on PATH"
else
  SHELL_RC=""
  if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_RC="$HOME/.zshrc"
  elif [[ -f "$HOME/.bashrc" ]]; then
    SHELL_RC="$HOME/.bashrc"
  elif [[ -f "$HOME/.bash_profile" ]]; then
    SHELL_RC="$HOME/.bash_profile"
  fi

  if [[ -n "$SHELL_RC" ]] && grep -qF "$RL_DIR/bin" "$SHELL_RC" 2>/dev/null; then
    ok "PATH entry found in ${SHELL_RC##*/} (may need: source $SHELL_RC)"
  elif [[ -n "$SHELL_RC" ]]; then
    ask "Add rl to PATH in ${SHELL_RC##*/}? [Y/n]"
    read -r ans
    if [[ "${ans:-Y}" =~ ^[Yy] ]]; then
      print "" >> "$SHELL_RC"
      print "# rl — Ralph Loop Toolkit" >> "$SHELL_RC"
      print "export PATH=\"$RL_DIR/bin:\$PATH\"" >> "$SHELL_RC"
      ok "Added to $SHELL_RC"
      export PATH="$RL_DIR/bin:$PATH"
    else
      warn "Skipped. Add manually: export PATH=\"$RL_DIR/bin:\$PATH\""
    fi
  else
    warn "No shell rc file found. Add manually: export PATH=\"$RL_DIR/bin:\$PATH\""
  fi
fi

print ""

# ---------------------------------------------------------------------------
# 2. Check required dependencies
# ---------------------------------------------------------------------------
print "${B}Checking required dependencies...${R}"

check_or_install() {
  local cmd="$1" label="$2" install_cmd="$3" required="$4"

  if (( $+commands[$cmd] )); then
    local ver=""
    case "$cmd" in
      git)    ver="$(git --version 2>/dev/null | sed 's/git version //')" ;;
      gh)     ver="$(gh --version 2>/dev/null | head -1 | sed 's/gh version //')" ;;
      jq)     ver="$(jq --version 2>/dev/null)" ;;
      node)   ver="$(node --version 2>/dev/null)" ;;
      claude) ver="$(claude --version 2>/dev/null | head -1)" ;;
      tk)     ver="installed" ;;
    esac
    ok "$label ${D}($ver)${R}"
    return 0
  fi

  if [[ "$required" == "required" ]]; then
    fail "$label — ${B}missing${R}"
  else
    warn "$label — not installed (optional)"
  fi

  if [[ -n "$install_cmd" ]]; then
    ask "Install $label? [Y/n]"
    read -r ans
    if [[ "${ans:-Y}" =~ ^[Yy] ]]; then
      print "    ${D}Running: $install_cmd${R}"
      eval "$install_cmd" 2>&1 | sed 's/^/    /'
      if (( $+commands[$cmd] )) || command -v "$cmd" &>/dev/null; then
        ok "$label installed"
        return 0
      else
        # Might need rehash after install
        hash -r 2>/dev/null
        if command -v "$cmd" &>/dev/null; then
          ok "$label installed"
          return 0
        fi
        fail "$label install may have failed — check manually"
        return 1
      fi
    else
      [[ "$required" == "required" ]] && fail "Skipped (required)" || warn "Skipped"
      return 1
    fi
  fi
  return 1
}

# Check for Homebrew first (needed for most installs on macOS)
HAS_BREW=false
if (( $+commands[brew] )); then
  HAS_BREW=true
fi

# Git — almost always present
check_or_install git "git" "" required

# Node.js — needed for claude-code and openspec
if ! (( $+commands[node] )); then
  print ""
  warn "Node.js is required for Claude Code"
  if $HAS_BREW; then
    check_or_install node "Node.js" "brew install node" required
  else
    fail "Node.js — install from https://nodejs.org"
  fi
else
  ok "Node.js ${D}($(node --version 2>/dev/null))${R}"
fi

# Claude Code
check_or_install claude "Claude Code" "npm install -g @anthropic-ai/claude-code" required

# GitHub CLI
if $HAS_BREW; then
  check_or_install gh "GitHub CLI (gh)" "brew install gh" required
else
  check_or_install gh "GitHub CLI (gh)" "" required
fi

# jq
if $HAS_BREW; then
  check_or_install jq "jq" "brew install jq" required
else
  check_or_install jq "jq" "" required
fi

# tk (ticket)
if $HAS_BREW; then
  check_or_install tk "tk (ticket CLI)" "brew tap wedow/tools && brew install ticket" required
else
  check_or_install tk "tk (ticket CLI)" "" required
fi

print ""

# ---------------------------------------------------------------------------
# 3. OpenSpec (enabled by default)
# ---------------------------------------------------------------------------
print "${B}Checking OpenSpec...${R}"

if ! check_or_install openspec "OpenSpec" "npm install -g @fission-ai/openspec" required; then
  print ""
  print "  ${Y}Note:${R} OpenSpec is enabled by default in new projects."
  print "  Without it, rl install will set USE_OPENSPEC=false in .rl/config."
  print "  Install later with: npm install -g @fission-ai/openspec"
fi

print ""

# ---------------------------------------------------------------------------
# 4. Check gh auth
# ---------------------------------------------------------------------------
print "${B}Checking authentication...${R}"

if (( $+commands[gh] )); then
  if gh auth status &>/dev/null; then
    ok "GitHub CLI authenticated"
  else
    warn "GitHub CLI not authenticated"
    ask "Run 'gh auth login' now? [Y/n]"
    read -r ans
    if [[ "${ans:-Y}" =~ ^[Yy] ]]; then
      gh auth login
    else
      warn "Skipped — run 'gh auth login' before using rl"
    fi
  fi
fi

if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
  ok "ANTHROPIC_API_KEY is set"
else
  warn "ANTHROPIC_API_KEY not set — Claude Code will prompt on first run"
fi

print ""

# ---------------------------------------------------------------------------
# 5. Summary
# ---------------------------------------------------------------------------
print "${C}${B}  Setup complete!${R}"
print ""
print "  ${B}Next steps:${R}"
print "    ${D}# Start a new terminal or run:${R}"
print "    source ~/.zshrc"
print ""
print "    ${D}# Existing repo — add rl to a project:${R}"
print "    cd your-project && rl install"
print ""
print "    ${D}# New project — scaffold from scratch:${R}"
print "    rl create my-app"
print ""
print "    ${D}# Migrate from legacy ralph/ layout:${R}"
print "    cd old-project && rl migrate"
print ""
print "    ${D}# Start the development loop:${R}"
print "    cd your-project && rl loop"
print ""
