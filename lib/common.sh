#!/usr/bin/env zsh
# lib/common.sh — Shared utilities for the rl toolkit
# Sourced by create.sh, install.sh, skills.sh (all zsh)

set -euo pipefail

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------
R=$'\033[0m'
B=$'\033[1m'
D=$'\033[2m'
C=$'\033[38;5;214m'   # gold accent
G=$'\033[38;5;106m'   # green
Y=$'\033[38;5;220m'   # yellow
ERR=$'\033[38;5;196m' # red

# ---------------------------------------------------------------------------
# Resolve rl toolkit root (zsh path modifier: :A=realpath, :h=dirname)
# ---------------------------------------------------------------------------
RL_ROOT="${0:A:h:h}"

# ---------------------------------------------------------------------------
# Resolve RL_HOME for runtime use (where rl resources live)
# Priority: $RL_HOME env > resolved symlink of `rl` command > RL_ROOT
# ---------------------------------------------------------------------------
resolve_rl_home() {
  if [[ -n "${RL_HOME:-}" ]]; then
    print "$RL_HOME"
    return
  fi
  # Try to resolve from the `rl` command in PATH
  if (( $+commands[rl] )); then
    local resolved="${commands[rl]:A:h}"
    if [[ -d "$resolved/resources/core" ]]; then
      print "$resolved"
      return
    fi
  fi
  # Fallback to RL_ROOT (when sourced from rl scripts)
  print "$RL_ROOT"
}

# ---------------------------------------------------------------------------
# Prerequisite checks
# ---------------------------------------------------------------------------

check_prereqs() {
  local -a missing=()

  (( $+commands[tk] ))     || missing+=("tk (brew tap wedow/tools && brew install ticket)")
  (( $+commands[claude] )) || missing+=("claude (npm install -g @anthropic-ai/claude-code)")
  (( $+commands[gh] ))     || missing+=("gh (brew install gh && gh auth login)")
  (( $+commands[jq] ))     || missing+=("jq (brew install jq)")
  (( $+commands[git] ))    || missing+=("git")

  if (( ${#missing} )); then
    print -P "${ERR}${B}Missing prerequisites:${R}"
    for dep in "${missing[@]}"; do
      print "  - $dep"
    done
    return 1
  fi
}

# ---------------------------------------------------------------------------
# Project detection
# ---------------------------------------------------------------------------

detect_pm() {
  local dir="${1:-.}"
  if [[ -f "$dir/pnpm-lock.yaml" ]]; then
    print pnpm
  elif [[ -f "$dir/yarn.lock" ]]; then
    print yarn
  elif [[ -f "$dir/bun.lockb" || -f "$dir/bun.lock" ]]; then
    print bun
  else
    print npm
  fi
}

pm_add() {
  local pm="$1"; shift
  case "$pm" in
    pnpm) pnpm add "$@" ;;
    yarn) yarn add "$@" ;;
    bun)  bun add "$@" ;;
    *)    npm install "$@" ;;
  esac
}

detect_base_branch() {
  local dir="${1:-.}"
  (
    cd "$dir"
    local remote_head=${$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null):t}
    if [[ -n "$remote_head" ]]; then
      print "$remote_head"
      return
    fi
    if git show-ref --verify --quiet refs/heads/main 2>/dev/null; then
      print main
    elif git show-ref --verify --quiet refs/heads/master 2>/dev/null; then
      print master
    else
      print main
    fi
  )
}

detect_project() {
  # Prints eval-able variable assignments: PROJECT_NAME, PM, BASE_BRANCH, etc.
  # Usage: eval "$(detect_project /path/to/repo)"
  local dir="${1:-.}"

  local project_name=""
  if [[ -f "$dir/package.json" ]]; then
    project_name=$(jq -r '.name // empty' "$dir/package.json" 2>/dev/null || true)
  fi
  [[ -z "$project_name" ]] && project_name="${dir:A:t}"

  local pm=$(detect_pm "$dir")
  local base_branch=$(detect_base_branch "$dir")
  local has_nx=false
  [[ -f "$dir/nx.json" ]] && has_nx=true

  local apps=""
  if [[ -d "$dir/apps" ]]; then
    local -a app_list=("${(@f)$(ls -1 "$dir/apps" 2>/dev/null)}")
    apps="${(j: :)app_list}"
  fi

  local has_openspec=false
  if [[ -d "$dir/openspec" ]]; then
    has_openspec=true
  fi

  local uses_tailwind=false
  if jq -e '.devDependencies["tailwindcss"] // .dependencies["tailwindcss"]' "$dir/package.json" &>/dev/null; then
    uses_tailwind=true
  fi

  local uses_ts_strict=false
  local tsconfig="$dir/tsconfig.base.json"
  [[ ! -f "$tsconfig" ]] && tsconfig="$dir/tsconfig.json"
  if [[ -f "$tsconfig" ]] && jq -e '.compilerOptions.strict == true' "$tsconfig" &>/dev/null; then
    uses_ts_strict=true
  fi

  # Multi-language detection
  local -a langs=()

  # TypeScript / JavaScript
  if [[ -f "$dir/package.json" ]] || [[ -f "$dir/tsconfig.json" ]] || [[ -f "$dir/tsconfig.base.json" ]]; then
    langs+=(typescript)
  fi

  # Go
  if [[ -f "$dir/go.mod" ]]; then
    langs+=(go)
  elif [[ -d "$dir/apps" ]]; then
    for app_dir in "$dir/apps"/*/(N); do
      [[ -f "$app_dir/go.mod" ]] && { langs+=(go); break }
    done
  fi

  # Rust
  if [[ -f "$dir/Cargo.toml" ]]; then
    langs+=(rust)
  elif [[ -d "$dir/apps" ]]; then
    for app_dir in "$dir/apps"/*/(N); do
      [[ -f "$app_dir/Cargo.toml" ]] && { langs+=(rust); break }
    done
  fi

  # Python
  if [[ -f "$dir/pyproject.toml" ]] || [[ -f "$dir/setup.py" ]]; then
    langs+=(python)
  elif [[ -d "$dir/apps" ]]; then
    for app_dir in "$dir/apps"/*/(N); do
      if [[ -f "$app_dir/pyproject.toml" ]] || [[ -f "$app_dir/setup.py" ]]; then
        langs+=(python); break
      fi
    done
  fi

  # JVM (Java / Kotlin / Scala)
  if [[ -f "$dir/build.gradle" ]] || [[ -f "$dir/build.gradle.kts" ]] || \
     [[ -f "$dir/pom.xml" ]] || [[ -f "$dir/build.sbt" ]]; then
    langs+=(jvm)
  elif [[ -d "$dir/apps" ]]; then
    for app_dir in "$dir/apps"/*/(N); do
      if [[ -f "$app_dir/build.gradle" ]] || [[ -f "$app_dir/build.gradle.kts" ]] || \
         [[ -f "$app_dir/pom.xml" ]] || [[ -f "$app_dir/build.sbt" ]]; then
        langs+=(jvm); break
      fi
    done
  fi

  # C/C++
  if [[ -f "$dir/CMakeLists.txt" ]] || [[ -f "$dir/meson.build" ]]; then
    langs+=(c-cpp)
  elif [[ -d "$dir/apps" ]]; then
    for app_dir in "$dir/apps"/*/(N); do
      if [[ -f "$app_dir/CMakeLists.txt" ]] || [[ -f "$app_dir/meson.build" ]]; then
        langs+=(c-cpp); break
      fi
    done
  fi

  local languages="${(j: :)langs}"

  print "PROJECT_NAME=${(qq)project_name}"
  print "PM=${(qq)pm}"
  print "BASE_BRANCH=${(qq)base_branch}"
  print "HAS_NX=${(qq)has_nx}"
  print "APPS=${(qq)apps}"
  print "LANGUAGES=${(qq)languages}"
  print "HAS_OPENSPEC=${(qq)has_openspec}"
  print "USES_TAILWIND=${(qq)uses_tailwind}"
  print "USES_TS_STRICT=${(qq)uses_ts_strict}"
}

# ---------------------------------------------------------------------------
# Interactive prompts (zsh read -q / vared style)
# ---------------------------------------------------------------------------

prompt_yn() {
  local question="$1" default="${2:-y}"
  local hint="[Y/n]"
  [[ "$default" == "n" ]] && hint="[y/N]"

  local answer
  print -nP "${Y}${question} ${D}${hint}${Y}: ${R}" > /dev/tty
  read -r answer < /dev/tty
  answer="${answer:-$default}"
  [[ "$answer" =~ ^[yY] ]]
}

prompt_text() {
  local question="$1" default="${2:-}"
  local hint=""
  [[ -n "$default" ]] && hint=" [$default]"

  local answer
  print -nP "${Y}${question}${D}${hint}${Y}: ${R}" > /dev/tty
  read -r answer < /dev/tty
  print "${answer:-$default}"
}

prompt_select() {
  local question="$1"; shift
  local -a options=("$@")

  print -P "${C}${B}${question}${R}" > /dev/tty
  local i
  for (( i = 1; i <= ${#options}; i++ )); do
    print -P "  ${Y}${i})${R} ${options[$i]}" > /dev/tty
  done

  local choice
  print -nP "${Y}Choice [1]: ${R}" > /dev/tty
  read -r choice < /dev/tty
  choice="${choice:-1}"

  if (( choice >= 1 && choice <= ${#options} )); then
    print "${options[$choice]}"
  else
    print "${options[1]}"
  fi
}

prompt_multiselect() {
  local question="$1"; shift
  local -a options=("$@")

  print -P "${C}${B}${question}${R}" > /dev/tty
  print -P "${D}  Enter numbers separated by spaces, or 'none' to skip${R}" > /dev/tty
  local i
  for (( i = 1; i <= ${#options}; i++ )); do
    print -P "  ${Y}${i})${R} ${options[$i]}" > /dev/tty
  done

  local choices_str
  print -nP "${Y}Choices: ${R}" > /dev/tty
  read -r choices_str < /dev/tty

  [[ "$choices_str" == "none" || -z "$choices_str" ]] && return

  for choice in ${=choices_str}; do
    if (( choice >= 1 && choice <= ${#options} )); then
      print "${options[$choice]}"
    fi
  done
}

# ---------------------------------------------------------------------------
# Nx preset detection
# ---------------------------------------------------------------------------

query_presets() {
  local help_output
  local -a presets=()

  print -P "${D}Querying available Nx presets...${R}" > /dev/tty

  local timeout_cmd=""
  (( $+commands[timeout] ))  && timeout_cmd="timeout 15"
  (( $+commands[gtimeout] )) && [[ -z "$timeout_cmd" ]] && timeout_cmd="gtimeout 15"

  if [[ -n "$timeout_cmd" ]]; then
    help_output=$($=timeout_cmd npx create-nx-workspace@latest --help </dev/null 2>/dev/null) || true
  else
    help_output=$(npx create-nx-workspace@latest --help </dev/null 2>/dev/null) || true
  fi

  if [[ -n "$help_output" ]]; then
    local preset_line=${${(f)help_output}[(r)*--preset*]}
    if [[ -n "$preset_line" ]]; then
      local values
      values=$(print "$preset_line" | grep -oE '\([^)]+\)|\[[^]]+\]' | tr -d '()[]"' | tr ',' '\n' | sed 's/^ *//;s/ *$//' | grep -v '^$' | grep -v '^string$')
      while IFS= read -r v; do
        [[ -n "$v" ]] && presets+=("$v")
      done <<< "$values"
    fi
  fi

  # Fallback
  (( ${#presets} == 0 )) && presets=(apps ts next react angular vue node nest express nuxt)

  print -l "${presets[@]}"
}

# ---------------------------------------------------------------------------
# Config and file generation
# ---------------------------------------------------------------------------

generate_rl_config() {
  local project_name="$1"
  local base_branch="$2"
  local use_openspec="$3"
  local uses_tailwind="${4:-false}"
  local uses_ts_strict="${5:-true}"
  local backpressure_cmd="${6:-}"
  local e2e_cmd="${7:-}"
  local claude_model="${8:-opus}"
  local max_iterations="${9:-25}"
  local review_wait="${10:-90}"

  [[ -z "$backpressure_cmd" ]] && backpressure_cmd="npx nx affected -t lint test build"

  cat <<EOF
# .rl/config — Ralph Loop configuration
# Generated by rl toolkit ($(date -u '+%Y-%m-%d'))

PROJECT_NAME="$project_name"
BASE_BRANCH="$base_branch"
BACKPRESSURE_CMD="$backpressure_cmd"
E2E_CMD="$e2e_cmd"
CLAUDE_MODEL="$claude_model"
MAX_ITERATIONS=$max_iterations
REVIEW_WAIT=$review_wait
USE_OPENSPEC=$use_openspec

# Timeout settings (seconds)
BACKPRESSURE_TIMEOUT=600
E2E_TIMEOUT=300

# Essential foundations (for agent context)
USES_TAILWIND=$uses_tailwind
USES_TYPESCRIPT_STRICT=$uses_ts_strict
EOF
}

generate_claude_md() {
  local project_name="$1"
  local backpressure_cmd="$2"
  local apps="$3"
  local use_openspec="$4"
  local has_nx="$5"

  local template_file="$RL_ROOT/resources/core/CLAUDE.md.template"
  [[ ! -f "$template_file" ]] && { print -u2 "ERROR: CLAUDE.md template not found at $template_file"; return 1 }

  local content
  content=$(<"$template_file")

  # Variable substitution (zsh global replacement)
  content="${content//\$PROJECT_NAME/$project_name}"
  content="${content//\$BACKPRESSURE_CMD/$backpressure_cmd}"
  content="${content//\$APPS/$apps}"

  # Conditional OpenSpec section
  if [[ "$use_openspec" != "true" ]]; then
    content=$(print "$content" | sed '/<!-- IF_OPENSPEC -->/,/<!-- END_OPENSPEC -->/d')
  else
    content=$(print "$content" | sed '/<!-- IF_OPENSPEC -->/d; /<!-- END_OPENSPEC -->/d')
  fi

  # Conditional Nx section
  if [[ "$has_nx" != "true" ]]; then
    content=$(print "$content" | sed '/<!-- IF_NX -->/,/<!-- END_NX -->/d')
  else
    content=$(print "$content" | sed '/<!-- IF_NX -->/d; /<!-- END_NX -->/d')
  fi

  print "$content"
}

generate_agents_md() {
  local project_name="$1"
  local base_branch="$2"
  local backpressure_cmd="$3"
  local apps="$4"
  local pm="$5"
  local has_nx="$6"
  local use_openspec="$7"

  cat <<EOF
# Project Overview

This is the **${project_name}** project.

## Build & Validation

### Backpressure (run before every commit)

\`\`\`bash
$backpressure_cmd
\`\`\`
EOF

  if [[ "$has_nx" == "true" ]]; then
    cat <<EOF

### Nx Commands

\`\`\`bash
# Run affected targets
npx nx affected -t lint test build
EOF
    for app in ${=apps}; do
      cat <<EOF

# $app
npx nx build $app
npx nx test $app
npx nx lint $app
EOF
    done
    print '```'
  fi

  cat <<EOF

## Commit Conventions

All commits use [Conventional Commits](https://www.conventionalcommits.org/):

\`\`\`
<type>(<scope>): <short description>
\`\`\`

### Types

| Type | When to use |
|------|-------------|
| \`feat\` | New feature or capability |
| \`fix\` | Bug fix |
| \`refactor\` | Code restructuring, no behavior change |
| \`docs\` | Documentation only |
| \`test\` | Adding or updating tests only |
| \`chore\` | Tooling, config, dependencies, tickets |
| \`perf\` | Performance improvement |

### Scope

- **Build mode**: Use the ticket ID as scope: \`feat(xx-a1b2): implement feature\`
- **Interview**: \`docs(plan): create proposal for <change-id>\`
- **Bootstrap**: \`chore(tickets): bootstrap <change-id>\`
- **Review**: \`fix(review): address PR feedback\`
- **Archive**: \`docs(specs): archive <change-id>\`
- **E2E**: \`fix(e2e): <test-name>\`

## Ralph Loop Integration

This repository uses the **Ralph Loop** (\`rl\`) for AI-assisted development with [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

### State Management

| File/Dir | Purpose |
|----------|---------|
| [\`.rl/config\`](.rl/config) | Ralph Loop configuration |
| [\`.tickets/\`](.tickets/) | Task tracking via [\`tk\`](https://github.com/wedow/ticket) |
EOF

  if [[ "$use_openspec" == "true" ]]; then
    cat <<EOF
| [\`openspec/specs/\`](openspec/specs/) | Living system documentation |
| [\`openspec/changes/\`](openspec/changes/) | Active proposals with delta specs |
EOF
  fi

  cat <<EOF
| [\`IMPLEMENTATION_PLAN.md\`](IMPLEMENTATION_PLAN.md) | High-level vision from interview |
| [\`LESSONS.md\`](LESSONS.md) | Cumulative learnings |
| [\`.claude/skills/\`](.claude/skills/) | Agent skills |

### Running the Loop

\`\`\`bash
rl loop interview            # Claude interviews you
rl loop bootstrap            # Create tickets from proposal
rl loop                      # Build one ticket
rl loop --auto --pr          # Autonomous: bootstrap -> build all -> archive -> PR
rl loop amend                # Amend specs/design to fix gaps
rl loop review               # Address PR review feedback
rl loop e2e                  # Fix E2E test failures
\`\`\`

### Ticket Workflow

\`\`\`bash
tk ready                     # Show tickets ready for work
tk ls                        # List all tickets
tk start <id>                # Mark in_progress
tk close <id>                # Mark closed
tk add-note <id> "text"      # Add a note
\`\`\`
EOF
}

# ---------------------------------------------------------------------------
# Validate slug format
# ---------------------------------------------------------------------------

validate_slug() {
  local name="$1"
  if [[ ! "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    print -P "${ERR}${B}Error:${R} Name must be a slug (lowercase, hyphens only). Example: my-app"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# Safe file/directory copy (skip if exists)
# ---------------------------------------------------------------------------

copy_safe() {
  local src="$1" dst="$2"
  if [[ -e "$dst" ]]; then
    print -P "  ${D}skip (exists):${R} ${dst:t}"
  else
    mkdir -p "${dst:h}"
    cp "$src" "$dst"
  fi
}

copy_dir_safe() {
  local src="$1" dst="$2"
  if [[ -d "$dst" ]]; then
    print -P "  ${D}skip (exists):${R} ${dst:t}/"
  else
    mkdir -p "${dst:h}"
    cp -r "$src" "$dst"
  fi
}
