#!/usr/bin/env zsh
# skills.sh — Manage skill templates for the Ralph Loop
# Usage:
#   rl skills list              # Show available templates
#   rl skills add <name>        # Add a template to current repo
#   rl skills installed         # Show skills in current repo
#   rl skills new <name>        # Create new skill in current repo
#   rl skills new --global <n>  # Create new reusable template
#   rl skills add-openspec      # Install OpenSpec skills + commands + npm package

set -euo pipefail
source "${0:A:h}/lib/common.sh"

# ---------------------------------------------------------------------------
# Resolve current repo
# ---------------------------------------------------------------------------
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")

# ---------------------------------------------------------------------------
# Subcommands
# ---------------------------------------------------------------------------

cmd_list() {
  print -P "${C}${B}Available skill templates:${R}\n"

  for tdir in "$RL_ROOT"/resources/skills/templates/*/; do
    [[ -f "$tdir/SKILL.md" ]] || continue
    local name="${${tdir%/}:t}"
    [[ "$name" == "_TEMPLATE" ]] && continue

    # Extract description from YAML frontmatter or first content line
    local desc=$(sed -n '/^description:/{s/^description: *"*//;s/"*$//;p;q;}' "$tdir/SKILL.md" 2>/dev/null)
    if [[ -z "$desc" ]]; then
      desc=$(sed -n '/^[^#< -]/{s/\[FILL[^]]*\]//g; s/^ *//; /^$/d; p; q;}' "$tdir/SKILL.md" 2>/dev/null)
    fi
    [[ -z "$desc" ]] && desc="(no description)"

    # Check if installed in current repo
    local installed=""
    if [[ -n "$REPO_ROOT" && -d "$REPO_ROOT/.claude/skills/$name" ]]; then
      installed=" ${G}(installed)${R}"
    fi

    print -P "  ${Y}$name${R}${installed}"
    print -P "    ${D}$desc${R}"
  done

  print ""
  print -P "${D}Use 'rl skills add <name>' to install a template.${R}"
}

cmd_add() {
  local name="${1:-}"
  if [[ -z "$name" ]]; then
    print -P "${ERR}${B}Error:${R} Skill name required. Usage: rl skills add <name>"
    print -P "Run 'rl skills list' to see available templates."
    exit 1
  fi

  if [[ -z "$REPO_ROOT" ]]; then
    print -P "${ERR}${B}Error:${R} Not inside a git repository."
    exit 1
  fi

  local src="$RL_ROOT/resources/skills/templates/$name"
  if [[ ! -d "$src" ]]; then
    print -P "${ERR}${B}Error:${R} Template not found: $name"
    print -P "Run 'rl skills list' to see available templates."
    exit 1
  fi

  # Install to .rl/skills/ (project override) so it persists across skill syncs
  local dst="$REPO_ROOT/.rl/skills/$name"
  mkdir -p "$dst"
  cp "$src/SKILL.md" "$dst/"
  print -P "${G}${B}Installed skill template:${R} $name -> .rl/skills/$name/"
  print -P "${D}This skill will override the source version during rl loop runs.${R}"
}

cmd_sync() {
  if [[ -z "$REPO_ROOT" ]]; then
    print -P "${ERR}${B}Error:${R} Not inside a git repository."
    exit 1
  fi

  setopt local_options nullglob

  print -P "${C}${B}Syncing skills from rl source...${R}"

  local skills_src="$RL_ROOT/resources/skills"
  mkdir -p "$REPO_ROOT/.claude/skills"

  local count=0

  # Workflow skills (always)
  for skill_dir in "$skills_src/workflow"/*/; do
    [[ -d "$skill_dir" ]] || continue
    local skill_name="${skill_dir:t}"
    mkdir -p "$REPO_ROOT/.claude/skills/$skill_name"
    cp "$skill_dir/SKILL.md" "$REPO_ROOT/.claude/skills/$skill_name/"
    count=$((count + 1))
  done

  # OpenSpec skills (if configured)
  local use_openspec=false
  if [[ -f "$REPO_ROOT/.rl/config" ]]; then
    ( set +u; source "$REPO_ROOT/.rl/config"; print "${USE_OPENSPEC:-false}" ) | read use_openspec
  elif [[ -f "$REPO_ROOT/.ralphrc" ]]; then
    ( set +u; source "$REPO_ROOT/.ralphrc"; print "${USE_OPENSPEC:-false}" ) | read use_openspec
  fi

  if [[ "$use_openspec" == "true" && -d "$skills_src/workflow-openspec" ]]; then
    for skill_dir in "$skills_src/workflow-openspec"/*/; do
      [[ -d "$skill_dir" ]] || continue
      local skill_name="${skill_dir:t}"
      mkdir -p "$REPO_ROOT/.claude/skills/$skill_name"
      cp "$skill_dir/SKILL.md" "$REPO_ROOT/.claude/skills/$skill_name/"
      count=$((count + 1))
    done
  fi

  # Apply project overrides last (highest precedence)
  local override_count=0
  if [[ -d "$REPO_ROOT/.rl/skills" ]]; then
    for skill_dir in "$REPO_ROOT/.rl/skills"/*/; do
      [[ -d "$skill_dir" ]] || continue
      local skill_name="${skill_dir:t}"
      mkdir -p "$REPO_ROOT/.claude/skills/$skill_name"
      cp "$skill_dir/SKILL.md" "$REPO_ROOT/.claude/skills/$skill_name/"
      override_count=$((override_count + 1))
    done
  fi

  print -P "${G}${B}Synced:${R} $count skills from source, $override_count project overrides applied."
}

cmd_override() {
  local name="${1:-}"
  if [[ -z "$name" ]]; then
    print -P "${ERR}${B}Error:${R} Skill name required. Usage: rl skills override <name>"
    exit 1
  fi

  if [[ -z "$REPO_ROOT" ]]; then
    print -P "${ERR}${B}Error:${R} Not inside a git repository."
    exit 1
  fi

  # Find the skill in the source
  local src=""
  if [[ -d "$RL_ROOT/resources/skills/workflow/$name" ]]; then
    src="$RL_ROOT/resources/skills/workflow/$name"
  elif [[ -d "$RL_ROOT/resources/skills/workflow-openspec/$name" ]]; then
    src="$RL_ROOT/resources/skills/workflow-openspec/$name"
  else
    print -P "${ERR}${B}Error:${R} Skill not found in rl source: $name"
    exit 1
  fi

  local dst="$REPO_ROOT/.rl/skills/$name"
  mkdir -p "$dst"
  cp "$src/SKILL.md" "$dst/"
  print -P "${G}${B}Created override:${R} .rl/skills/$name/SKILL.md"
  print -P "${D}Edit this file to customize. It takes precedence over the source version.${R}"
}

cmd_installed() {
  if [[ -z "$REPO_ROOT" ]]; then
    print -P "${ERR}${B}Error:${R} Not inside a git repository."
    exit 1
  fi

  local skills_dir="$REPO_ROOT/.claude/skills"
  if [[ ! -d "$skills_dir" ]]; then
    print "No skills installed."
    return
  fi

  # Collect skills into category buckets
  local -a workflow_skills=() universal_skills=() language_skills=() stack_skills=() template_skills=() openspec_skills=() custom_skills=()

  for sdir in "$skills_dir"/*/; do
    [[ -f "$sdir/SKILL.md" ]] || continue
    local name="${${sdir%/}:t}"

    # Try to read category from HTML comment in SKILL.md
    local file_cat=""
    file_cat=$(sed -n 's/.*<!-- *category: *\([a-z]*\) *-->.*/\1/p' "$sdir/SKILL.md" 2>/dev/null | head -1)

    # Fall back to directory-based detection
    if [[ -z "$file_cat" ]]; then
      if [[ -d "$RL_ROOT/resources/skills/workflow/$name" ]]; then
        file_cat="workflow"
      elif [[ -d "$RL_ROOT/resources/skills/workflow-openspec/$name" ]]; then
        file_cat="openspec"
      elif [[ -d "$RL_ROOT/resources/skills/templates/$name" ]]; then
        file_cat="template"
      else
        file_cat="custom"
      fi
    fi

    case "$file_cat" in
      workflow)  workflow_skills+=("$name") ;;
      universal) universal_skills+=("$name") ;;
      language)  language_skills+=("$name") ;;
      stack)     stack_skills+=("$name") ;;
      template)  template_skills+=("$name") ;;
      openspec)  openspec_skills+=("$name") ;;
      *)         custom_skills+=("$name") ;;
    esac
  done

  print -P "${C}${B}Installed skills:${R}"

  if (( ${#workflow_skills} )); then
    print -P "\n  ${G}${B}Workflow${R} ${D}(layer 0 — how to operate)${R}"
    for s in "${workflow_skills[@]}"; do print -P "    ${G}$s${R}"; done
  fi

  if (( ${#universal_skills} )); then
    print -P "\n  ${G}${B}Universal${R} ${D}(layer 1 — principles)${R}"
    for s in "${universal_skills[@]}"; do print -P "    ${G}$s${R}"; done
  fi

  if (( ${#language_skills} )); then
    print -P "\n  ${Y}${B}Language${R} ${D}(layer 2 — language conventions)${R}"
    for s in "${language_skills[@]}"; do print -P "    ${Y}$s${R}"; done
  fi

  if (( ${#stack_skills} )); then
    print -P "\n  ${Y}${B}Stack${R} ${D}(layer 3 — library combinations)${R}"
    for s in "${stack_skills[@]}"; do print -P "    ${Y}$s${R}"; done
  fi

  if (( ${#template_skills} )); then
    print -P "\n  ${Y}${B}Technology${R} ${D}(layer 4 — individual tech)${R}"
    for s in "${template_skills[@]}"; do print -P "    ${Y}$s${R}"; done
  fi

  if (( ${#openspec_skills} )); then
    print -P "\n  ${C}${B}OpenSpec${R} ${D}(spec-driven workflow)${R}"
    for s in "${openspec_skills[@]}"; do print -P "    ${C}$s${R}"; done
  fi

  if (( ${#custom_skills} )); then
    print -P "\n  ${B}Custom${R} ${D}(layer 5 — project-specific)${R}"
    for s in "${custom_skills[@]}"; do print -P "    $s"; done
  fi

  print ""
}

cmd_new() {
  local global=false
  local name=""

  # Parse args
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --global) global=true; shift ;;
      *)        name="$1"; shift ;;
    esac
  done

  if [[ -z "$name" ]]; then
    print -P "${ERR}${B}Error:${R} Skill name required. Usage: rl skills new <name>"
    exit 1
  fi

  validate_slug "$name" || exit 1

  local template_src="$RL_ROOT/resources/skills/templates/_TEMPLATE.md"
  if [[ ! -f "$template_src" ]]; then
    print -P "${ERR}${B}Error:${R} Meta-template not found at $template_src"
    exit 1
  fi

  local dst_dir
  if [[ "$global" == "true" ]]; then
    dst_dir="$RL_ROOT/resources/skills/templates/$name"
    print -P "Creating ${C}global${R} skill template: $name"
  else
    if [[ -z "$REPO_ROOT" ]]; then
      print -P "${ERR}${B}Error:${R} Not inside a git repository. Use --global for reusable templates."
      exit 1
    fi
    dst_dir="$REPO_ROOT/.claude/skills/$name"
    print -P "Creating ${Y}project${R} skill: $name"
  fi

  if [[ -d "$dst_dir" ]]; then
    print -P "${ERR}${B}Error:${R} Skill already exists: $dst_dir"
    exit 1
  fi

  mkdir -p "$dst_dir"

  # Read template and substitute name
  local content
  content=$(<"$template_src")
  content="${content//_TEMPLATE/$name}"

  print "$content" > "$dst_dir/SKILL.md"
  print -P "${G}${B}Created:${R} $dst_dir/SKILL.md"
  print -P "${D}Edit the SKILL.md file and fill in the [FILL] sections.${R}"
}

cmd_add_openspec() {
  if [[ -z "$REPO_ROOT" ]]; then
    print -P "${ERR}${B}Error:${R} Not inside a git repository."
    exit 1
  fi

  print -P "${C}${B}Adding OpenSpec to this project...${R}\n"

  # Verify OpenSpec CLI is available (global tool)
  if ! (( $+commands[openspec] )) && ! npx openspec --version &>/dev/null 2>&1; then
    print -P "${ERR}${B}Error:${R} OpenSpec CLI not found."
    print -P "${D}Install globally: npm install -g @fission-ai/openspec${R}"
    exit 1
  fi

  # Initialize OpenSpec in the repo if not already done
  if [[ ! -d "$REPO_ROOT/openspec" ]]; then
    print -P "  ${G}Initializing:${R} openspec"
    ( cd "$REPO_ROOT" && openspec init 2>/dev/null || npx openspec init 2>/dev/null || true )
  else
    print -P "  ${D}skip:${R} openspec/ already initialized"
  fi

  # Install OpenSpec skills
  local skills_dir="$REPO_ROOT/.claude/skills"
  mkdir -p "$skills_dir"

  for skill_dir in "$RL_ROOT"/resources/skills/workflow-openspec/*/; do
    [[ -d "$skill_dir" ]] || continue
    local skill_name="${${skill_dir%/}:t}"
    copy_dir_safe "$skill_dir" "$skills_dir/$skill_name"
    print -P "  ${G}skill:${R} $skill_name"
  done

  # Install OpenSpec slash commands
  local commands_dir="$REPO_ROOT/.claude/commands/opsx"
  mkdir -p "$commands_dir"

  for cmd_file in "$RL_ROOT"/resources/commands/opsx/*.md; do
    [[ -f "$cmd_file" ]] || continue
    copy_safe "$cmd_file" "$commands_dir/${cmd_file:t}"
    print -P "  ${G}command:${R} /opsx/${${cmd_file:t}%.md}"
  done

  # Update config (.rl/config or .ralphrc)
  local config_file="$REPO_ROOT/.rl/config"
  [[ ! -f "$config_file" ]] && config_file="$REPO_ROOT/.ralphrc"
  if [[ -f "$config_file" ]]; then
    if grep -q "USE_OPENSPEC=false" "$config_file" 2>/dev/null; then
      sed -i '' 's/USE_OPENSPEC=false/USE_OPENSPEC=true/' "$config_file"
      print -P "  ${G}updated:${R} ${config_file:t} (USE_OPENSPEC=true)"
    fi
  fi

  print -P "\n${G}${B}OpenSpec installed!${R}"
  print -P "${D}Run 'rl loop interview' to start using spec-driven development.${R}"
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------
local subcmd="${1:-list}"
shift 2>/dev/null || true

case "$subcmd" in
  list)         cmd_list ;;
  add)          cmd_add "$@" ;;
  installed)    cmd_installed ;;
  new)          cmd_new "$@" ;;
  sync)         cmd_sync ;;
  override)     cmd_override "$@" ;;
  add-openspec) cmd_add_openspec ;;
  -h|--help)
    print "Usage: rl skills <command>"
    print ""
    print "Commands:"
    print "  list              Show available skill templates"
    print "  add <name>        Install a template to .rl/skills/ (project override)"
    print "  installed         Show skills installed in current repo"
    print "  new <name>        Create new skill in current repo"
    print "  new --global <n>  Create new reusable template in rl toolkit"
    print "  sync              Sync skills from rl source to .claude/skills/"
    print "  override <name>   Copy a workflow skill to .rl/skills/ for customization"
    print "  add-openspec      Install OpenSpec skills + commands + npm package"
    ;;
  *)
    print -P "${ERR}${B}Error:${R} Unknown command: $subcmd"
    print "Run 'rl skills --help' for usage."
    exit 1
    ;;
esac
