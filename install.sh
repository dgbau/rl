#!/usr/bin/env zsh
set -euo pipefail

# install.sh — Add the Ralph Loop to an existing repository
#
# Usage:
#   rl install                # Interactive install in current directory
#   rl install /path/to/repo  # Install in specific repo
#
# Can also be called internally from create.sh with flags:
#   install.sh --use-openspec --skills nextjs,tailwind --no-prompt

source "${0:A:h}/lib/common.sh"

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
TARGET_DIR=""
USE_OPENSPEC=""
SELECTED_SKILLS=()
NO_PROMPT=false

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --use-openspec)
      USE_OPENSPEC=true
      shift
      ;;
    --no-openspec)
      USE_OPENSPEC=false
      shift
      ;;
    --skills)
      SELECTED_SKILLS=("${(@s:,:)2}")
      shift 2
      ;;
    --no-prompt)
      NO_PROMPT=true
      shift
      ;;
    -h|--help)
      print "Usage: rl install [directory] [options]"
      print ""
      print "Options:"
      print "  --use-openspec    Enable OpenSpec integration"
      print "  --no-openspec     Disable OpenSpec integration"
      print "  --skills LIST     Comma-separated skill templates to install"
      print "  --no-prompt       Skip interactive prompts (use defaults/flags)"
      exit 0
      ;;
    *)
      if [[ -z "$TARGET_DIR" ]]; then
        TARGET_DIR="$1"
      fi
      shift
      ;;
  esac
done

TARGET_DIR="${TARGET_DIR:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# ---------------------------------------------------------------------------
# Pre-flight
# ---------------------------------------------------------------------------
print -P "${C}${B}Ralph Loop Installer${R}"
print ""

# Check prerequisites
if ! check_prereqs; then
  exit 1
fi

# Must be a git repo
if ! git -C "$TARGET_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
  print -P "${ERR}${B}Error:${R} $TARGET_DIR is not a git repository."
  print "Initialize with: git init"
  exit 1
fi

# Check if already installed (new or legacy model)
if [[ -f "$TARGET_DIR/.rl/config" ]]; then
  print -P "${Y}Warning:${R} rl is already configured at $TARGET_DIR/.rl/config"
  if [[ "$NO_PROMPT" != "true" ]]; then
    if ! prompt_yn "Overwrite existing configuration?"; then
      print "Aborted."
      exit 0
    fi
  fi
elif [[ -f "$TARGET_DIR/ralph/loop.sh" ]]; then
  print -P "${Y}Warning:${R} Legacy ralph/ installation found at $TARGET_DIR/ralph/"
  print -P "${D}This install will use the new .rl/ model. Run 'rl migrate' to clean up ralph/.${R}"
fi

# ---------------------------------------------------------------------------
# Detect project context
# ---------------------------------------------------------------------------
print -P "${D}Detecting project context...${R}"
eval "$(detect_project "$TARGET_DIR")"

print -P "  ${D}Project:${R}      $PROJECT_NAME"
print -P "  ${D}Base branch:${R}  $BASE_BRANCH"
print -P "  ${D}Package mgr:${R}  $PM"
print -P "  ${D}Has Nx:${R}       $HAS_NX"
print -P "  ${D}Has OpenSpec:${R} $HAS_OPENSPEC"
[[ -n "$LANGUAGES" ]] && print -P "  ${D}Languages:${R}    $LANGUAGES"
[[ -n "$APPS" ]] && print -P "  ${D}Apps:${R}         $APPS"
print ""

# ---------------------------------------------------------------------------
# Interactive configuration (if not passed via flags)
# ---------------------------------------------------------------------------
if [[ "$NO_PROMPT" != "true" ]]; then
  # OpenSpec
  if [[ -z "$USE_OPENSPEC" ]]; then
    if [[ "$HAS_OPENSPEC" == "true" ]]; then
      print -P "${D}OpenSpec is already installed as a dependency.${R}"
      USE_OPENSPEC=true
    else
      if prompt_yn "Use OpenSpec for spec-driven development?" "y"; then
        USE_OPENSPEC=true
      else
        USE_OPENSPEC=false
      fi
    fi
  fi

  # Skill templates
  if [[ ${#SELECTED_SKILLS[@]} -eq 0 ]]; then
    local -a available_templates=()
    for template_dir in "$RL_ROOT/resources/skills/templates"/*/; do
      local tname=$(basename "$template_dir")
      [[ "$tname" == "_TEMPLATE" ]] && continue
      [[ -f "$template_dir/SKILL.md" ]] && available_templates+=("$tname")
    done

    # Auto-suggest templates based on detected context
    local -a suggested=()
    if [[ -f "$TARGET_DIR/package.json" ]]; then
      local deps_json
      deps_json=$(jq -r '(.dependencies // {}) + (.devDependencies // {}) | keys[]' "$TARGET_DIR/package.json" 2>/dev/null || true)

      [[ "$deps_json" == *"next"* ]]              && suggested+=(nextjs)
      [[ "$deps_json" == *"tailwindcss"* ]]        && suggested+=(tailwind)
      [[ "$deps_json" == *"react"* ]]              && suggested+=(react)
      [[ "$deps_json" == *"stripe"* ]]             && suggested+=(stripe)
      [[ "$deps_json" == *"@shopify/"* ]]          && suggested+=(shopify)
      [[ "$deps_json" == *"wagmi"* || "$deps_json" == *"viem"* ]] && suggested+=(blockchain)
      [[ "$deps_json" == *"d3"* || "$deps_json" == *"recharts"* || "$deps_json" == *"echarts"* ]] && suggested+=(data-visualization)
      [[ "$deps_json" == *"@payloadcms/"* ]]       && suggested+=(cms)
      [[ "$deps_json" == *"socket.io"* || "$deps_json" == *"ably"* ]] && suggested+=(realtime)
      [[ "$deps_json" == *"electron"* ]]           && suggested+=(electron)
      [[ "$deps_json" == *"@anthropic-ai/sdk"* ]]  && suggested+=(anthropic-sdk)
      # Stack detection
      if [[ "$deps_json" == *"next"* && "$deps_json" == *"@payloadcms/"* ]]; then
        suggested+=(stack-nextjs-payload)
      fi
      if [[ "$deps_json" == *"next"* && "$deps_json" == *"@trpc/"* && "$deps_json" == *"prisma"* ]]; then
        suggested+=(stack-t3)
      fi
    fi

    # Python AI/ML detection (from pyproject.toml in root or apps/)
    if [[ -f "$TARGET_DIR/pyproject.toml" ]]; then
      local pyproject_content
      pyproject_content=$(<"$TARGET_DIR/pyproject.toml")
      if [[ "$pyproject_content" == *"torch"* || "$pyproject_content" == *"tensorflow"* || \
            "$pyproject_content" == *"scikit-learn"* || "$pyproject_content" == *"sklearn"* ]]; then
        suggested+=(python-ai-ml)
      fi
    fi

    # Language-based suggestions
    for lang in ${=LANGUAGES}; do
      case "$lang" in
        go)     suggested+=(go) ;;
        rust)   suggested+=(rust) ;;
        python) suggested+=(python) ;;
        jvm)    suggested+=(jvm) ;;
        c-cpp)  suggested+=(c-cpp) ;;
      esac
    done

    # Show suggestions if any
    if (( ${#suggested} )); then
      # Deduplicate and filter to available templates
      local -a valid_suggestions=()
      for s in "${suggested[@]}"; do
        if (( ${available_templates[(Ie)$s]} )) && ! (( ${valid_suggestions[(Ie)$s]} )); then
          valid_suggestions+=("$s")
        fi
      done
      if (( ${#valid_suggestions} )); then
        print ""
        print -P "${D}Suggested templates based on detected dependencies:${R}"
        print -P "  ${G}${(j:, :)valid_suggestions}${R}"
      fi
    fi

    if (( ${#available_templates} )); then
      print ""
      while IFS= read -r line; do
        [[ -n "$line" ]] && SELECTED_SKILLS+=("$line")
      done < <(prompt_multiselect "Which skill templates would you like to install?" "${available_templates[@]}")
    fi
  fi
fi

USE_OPENSPEC="${USE_OPENSPEC:-false}"

# ---------------------------------------------------------------------------
# Verify OpenSpec is available (global tool, not a repo dependency)
# ---------------------------------------------------------------------------
if [[ "$USE_OPENSPEC" == "true" ]]; then
  if (( $+commands[openspec] )) || (( $+commands[npx] )) && npx openspec --version &>/dev/null; then
    # Initialize OpenSpec in the repo if not already done
    if [[ ! -d "$TARGET_DIR/openspec" ]]; then
      print ""
      print -P "${D}Initializing OpenSpec...${R}"
      (cd "$TARGET_DIR" && openspec init 2>/dev/null || npx openspec init 2>/dev/null || true)
    fi
  else
    print ""
    print -P "${Y}Warning:${R} OpenSpec CLI not found."
    print -P "${D}Install globally: npm install -g @fission-ai/openspec${R}"
    print -P "${D}Continuing with USE_OPENSPEC=true in config — install OpenSpec before running rl loop.${R}"
  fi
fi

# ---------------------------------------------------------------------------
# Determine backpressure command
# ---------------------------------------------------------------------------
BACKPRESSURE_CMD=""
if [[ "$HAS_NX" == "true" ]]; then
  BACKPRESSURE_CMD="npx nx affected -t lint test build"
elif [[ -f "$TARGET_DIR/package.json" ]]; then
  # Check for common Node.js scripts
  local has_lint has_test has_build
  has_lint=$(jq -r '.scripts.lint // empty' "$TARGET_DIR/package.json" 2>/dev/null || true)
  has_test=$(jq -r '.scripts.test // empty' "$TARGET_DIR/package.json" 2>/dev/null || true)
  has_build=$(jq -r '.scripts.build // empty' "$TARGET_DIR/package.json" 2>/dev/null || true)

  local -a parts=()
  [[ -n "$has_lint" ]] && parts+=("${PM} run lint")
  [[ -n "$has_test" ]] && parts+=("${PM} run test")
  [[ -n "$has_build" ]] && parts+=("${PM} run build")

  if (( ${#parts} )); then
    BACKPRESSURE_CMD="${(j: && :)parts}"
  fi
fi

# Non-JS language detection: build backpressure from detected languages
if [[ -z "$BACKPRESSURE_CMD" ]]; then
  local -a bp_parts=()

  for lang in ${=LANGUAGES}; do
    case "$lang" in
      go)
        bp_parts+=("go vet ./...")
        bp_parts+=("go test ./...")
        ;;
      rust)
        bp_parts+=("cargo clippy -- -D warnings")
        bp_parts+=("cargo test")
        ;;
      python)
        if [[ -f "$TARGET_DIR/pyproject.toml" ]]; then
          # Detect test framework
          local pyproject_content=$(<"$TARGET_DIR/pyproject.toml")
          if [[ "$pyproject_content" == *"pytest"* ]]; then
            bp_parts+=("pytest")
          else
            bp_parts+=("python -m unittest discover")
          fi
          # Detect linter
          if [[ "$pyproject_content" == *"ruff"* ]]; then
            bp_parts+=("ruff check .")
          elif [[ "$pyproject_content" == *"flake8"* ]]; then
            bp_parts+=("flake8 .")
          fi
          # Detect type checker
          if [[ "$pyproject_content" == *"mypy"* ]]; then
            bp_parts+=("mypy .")
          fi
        else
          bp_parts+=("python -m unittest discover")
        fi
        ;;
      jvm)
        if [[ -f "$TARGET_DIR/build.gradle" || -f "$TARGET_DIR/build.gradle.kts" ]]; then
          bp_parts+=("./gradlew check")
        elif [[ -f "$TARGET_DIR/pom.xml" ]]; then
          bp_parts+=("mvn verify")
        elif [[ -f "$TARGET_DIR/build.sbt" ]]; then
          bp_parts+=("sbt test")
        fi
        ;;
      c-cpp)
        if [[ -f "$TARGET_DIR/CMakeLists.txt" ]]; then
          bp_parts+=("cmake --build build && ctest --test-dir build")
        elif [[ -f "$TARGET_DIR/meson.build" ]]; then
          bp_parts+=("meson test -C builddir")
        fi
        ;;
    esac
  done

  if (( ${#bp_parts} )); then
    BACKPRESSURE_CMD="${(j: && :)bp_parts}"
  fi
fi

BACKPRESSURE_CMD="${BACKPRESSURE_CMD:-echo 'No backpressure command configured -- set BACKPRESSURE_CMD in .rl/config'}"

# ---------------------------------------------------------------------------
# Generate .rl/config
# ---------------------------------------------------------------------------
print ""
print -P "${D}Creating .rl/ directory and config...${R}"
mkdir -p "$TARGET_DIR/.rl/skills"
generate_rl_config \
  "$PROJECT_NAME" \
  "$BASE_BRANCH" \
  "$USE_OPENSPEC" \
  "$USES_TAILWIND" \
  "$USES_TS_STRICT" \
  "$BACKPRESSURE_CMD" \
  "" \
  "opus" \
  "25" \
  "90" \
  > "$TARGET_DIR/.rl/config"

# ---------------------------------------------------------------------------
# Generate CLAUDE.md
# ---------------------------------------------------------------------------
print -P "${D}Generating CLAUDE.md...${R}"
if [[ ! -f "$TARGET_DIR/CLAUDE.md" ]]; then
  generate_claude_md \
    "$PROJECT_NAME" \
    "$BACKPRESSURE_CMD" \
    "$APPS" \
    "$USE_OPENSPEC" \
    "$HAS_NX" \
    > "$TARGET_DIR/CLAUDE.md"
else
  print -P "  ${D}CLAUDE.md already exists, skipping${R}"
fi

# ---------------------------------------------------------------------------
# Install workflow skills
# ---------------------------------------------------------------------------
print -P "${D}Installing workflow skills...${R}"
mkdir -p "$TARGET_DIR/.claude/skills"

# Always install core workflow skills
for skill_dir in "$RL_ROOT/resources/skills/workflow"/*/; do
  local skill_name=$(basename "$skill_dir")
  mkdir -p "$TARGET_DIR/.claude/skills/$skill_name"
  cp "$skill_dir/SKILL.md" "$TARGET_DIR/.claude/skills/$skill_name/"
done

# Install OpenSpec skills + commands if opted in
if [[ "$USE_OPENSPEC" == "true" ]]; then
  print -P "${D}Installing OpenSpec skills and commands...${R}"
  for skill_dir in "$RL_ROOT/resources/skills/workflow-openspec"/*/; do
    local skill_name=$(basename "$skill_dir")
    mkdir -p "$TARGET_DIR/.claude/skills/$skill_name"
    cp "$skill_dir/SKILL.md" "$TARGET_DIR/.claude/skills/$skill_name/"
  done

  mkdir -p "$TARGET_DIR/.claude/commands/opsx"
  for cmd_file in "$RL_ROOT/resources/commands/opsx"/*.md; do
    [[ -f "$cmd_file" ]] && cp "$cmd_file" "$TARGET_DIR/.claude/commands/opsx/"
  done
fi

# ---------------------------------------------------------------------------
# Install selected skill templates
# ---------------------------------------------------------------------------
if [[ ${#SELECTED_SKILLS[@]} -gt 0 ]]; then
  print -P "${D}Installing skill templates...${R}"
  for skill in "${SELECTED_SKILLS[@]}"; do
    local template_dir="$RL_ROOT/resources/skills/templates/$skill"
    if [[ -f "$template_dir/SKILL.md" ]]; then
      mkdir -p "$TARGET_DIR/.claude/skills/$skill"
      cp "$template_dir/SKILL.md" "$TARGET_DIR/.claude/skills/$skill/"
      print -P "  ${G}+${R} $skill"
    else
      print -P "  ${Y}?${R} $skill (template not found, skipping)"
    fi
  done
fi

# ---------------------------------------------------------------------------
# Create scaffolding files
# ---------------------------------------------------------------------------
print -P "${D}Creating scaffolding files...${R}"

# AGENTS.md
if [[ ! -f "$TARGET_DIR/AGENTS.md" ]]; then
  generate_agents_md \
    "$PROJECT_NAME" \
    "$BASE_BRANCH" \
    "$BACKPRESSURE_CMD" \
    "$APPS" \
    "$PM" \
    "$HAS_NX" \
    "$USE_OPENSPEC" \
    > "$TARGET_DIR/AGENTS.md"
else
  print -P "  ${D}AGENTS.md already exists, skipping${R}"
fi

# LESSONS.md
if [[ ! -f "$TARGET_DIR/LESSONS.md" ]]; then
  cat > "$TARGET_DIR/LESSONS.md" << 'EOF'
# Lessons Learned

Cumulative learnings from development iterations. Each entry references a ticket ID.

---

EOF
fi

# .gitignore additions
if [[ -f "$TARGET_DIR/.gitignore" ]]; then
  if ! grep -q ".rl/copilot-reviews.md" "$TARGET_DIR/.gitignore" 2>/dev/null; then
    print "" >> "$TARGET_DIR/.gitignore"
    print "# Ralph Loop working files" >> "$TARGET_DIR/.gitignore"
    print ".rl/copilot-reviews.md" >> "$TARGET_DIR/.gitignore"
    print ".rl/review-manifest.json" >> "$TARGET_DIR/.gitignore"
    print ".rl/e2e-results.md" >> "$TARGET_DIR/.gitignore"
    print ".rl/.e2e-*" >> "$TARGET_DIR/.gitignore"
  fi
else
  cat > "$TARGET_DIR/.gitignore" << 'EOF'
# Ralph Loop working files
.rl/copilot-reviews.md
.rl/review-manifest.json
.rl/e2e-results.md
.rl/.e2e-*
EOF
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
print ""
print -P "${G}${B}Ralph Loop installed!${R}"
print ""
print -P "  ${D}Configuration:${R} .rl/config"
print -P "  ${D}Skills:${R}        .claude/skills/ ($(ls -d "$TARGET_DIR/.claude/skills"/*/ 2>/dev/null | wc -l | tr -d ' ') installed)"
print -P "  ${D}OpenSpec:${R}      $USE_OPENSPEC"
print ""
print -P "Get started:"
print -P "  ${C}git checkout -b ralph/my-feature${R}"
print -P "  ${C}rl loop interview${R}"
print ""
