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
# Helpers
# ---------------------------------------------------------------------------

# Find a tool skill by name across the two-level tree (tools/<category>/<name>/)
# Sets REPLY to the full path, or empty if not found
find_tool_skill() {
  local name="$1"
  local tools_dir="$RL_ROOT/resources/skills/tools"
  for cat_dir in "$tools_dir"/*/; do
    [[ -d "$cat_dir/$name" && -f "$cat_dir/$name/SKILL.md" ]] && { REPLY="$cat_dir/$name"; return 0; }
  done
  REPLY=""
  return 1
}

# Extract description from a SKILL.md file
extract_skill_desc() {
  local file="$1"
  local desc=""
  desc=$(sed -n '/^description:/{s/^description: *"*//;s/"*$//;p;q;}' "$file" 2>/dev/null)
  if [[ -z "$desc" ]]; then
    desc=$(sed -n '/^[^#< -]/{s/\[FILL[^]]*\]//g; s/^ *//; /^$/d; p; q;}' "$file" 2>/dev/null)
  fi
  [[ -z "$desc" ]] && desc="(no description)"
  print "$desc"
}

# ---------------------------------------------------------------------------
# Subcommands
# ---------------------------------------------------------------------------

cmd_list() {
  setopt local_options nullglob

  print -P "${C}${B}Available skills by category:${R}"

  local tools_dir="$RL_ROOT/resources/skills/tools"
  for cat_dir in "$tools_dir"/*/; do
    [[ -d "$cat_dir" ]] || continue
    local cat_name="${cat_dir:t}"

    # Collect skills in this category
    local -a skills_in_cat=()
    for tdir in "$cat_dir"/*/; do
      [[ -f "$tdir/SKILL.md" ]] || continue
      skills_in_cat+=("$tdir")
    done
    (( ${#skills_in_cat} )) || continue

    print -P "\n  ${C}${B}$cat_name${R}"
    for tdir in "${skills_in_cat[@]}"; do
      local name="${tdir:t}"
      local desc=$(extract_skill_desc "$tdir/SKILL.md")

      local installed=""
      if [[ -n "$REPO_ROOT" && -d "$REPO_ROOT/.claude/skills/$name" ]]; then
        installed=" ${G}(installed)${R}"
      fi

      print -P "    ${Y}$name${R}${installed}"
      print -P "      ${D}$desc${R}"
    done
  done

  print ""
  print -P "${D}Use 'rl skills add <name>' to install a skill.${R}"
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

  if ! find_tool_skill "$name"; then
    print -P "${ERR}${B}Error:${R} Skill not found: $name"
    print -P "Run 'rl skills list' to see available skills."
    exit 1
  fi
  local src="$REPLY"

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

  # Detect if we're developing the rl toolkit itself
  local is_rl_toolkit=false
  if [[ -f "$REPO_ROOT/resources/core/loop.sh" && -f "$REPO_ROOT/lib/common.sh" ]]; then
    is_rl_toolkit=true
  fi

  # Read config
  local use_openspec=false
  if [[ -f "$REPO_ROOT/.rl/config" ]]; then
    ( set +u; source "$REPO_ROOT/.rl/config"; print "${USE_OPENSPEC:-true}" ) | read use_openspec
  elif [[ -f "$REPO_ROOT/.ralphrc" ]]; then
    ( set +u; source "$REPO_ROOT/.ralphrc"; print "${USE_OPENSPEC:-true}" ) | read use_openspec
  fi

  # --- Universal skills (always) ---
  for skill_dir in "$skills_src/universal"/*/; do
    [[ -d "$skill_dir" ]] || continue
    local skill_name="${skill_dir:t}"
    mkdir -p "$REPO_ROOT/.claude/skills/$skill_name"
    cp "$skill_dir/SKILL.md" "$REPO_ROOT/.claude/skills/$skill_name/"
    count=$((count + 1))
  done

  # --- rl skills (check sync condition per skill) ---
  # Skills in rl/ use <!-- sync: CONDITION --> metadata:
  #   (no marker or "always") = always synced
  #   "openspec"              = only when USE_OPENSPEC=true
  #   "dogfooding"            = only when developing rl itself
  for skill_dir in "$skills_src/rl"/*/; do
    [[ -d "$skill_dir" ]] || continue
    local skill_name="${skill_dir:t}"

    # Read sync condition from SKILL.md
    local sync_cond="always"
    if [[ -f "$skill_dir/SKILL.md" ]]; then
      local found_cond=$(sed -n 's/.*<!-- *sync: *\([a-z]*\) *-->.*/\1/p' "$skill_dir/SKILL.md" 2>/dev/null | head -1)
      [[ -n "$found_cond" ]] && sync_cond="$found_cond"
    fi

    # Check condition
    case "$sync_cond" in
      openspec)
        [[ "$use_openspec" != "true" ]] && continue
        ;;
      dogfooding)
        [[ "$is_rl_toolkit" != "true" ]] && continue
        ;;
    esac

    mkdir -p "$REPO_ROOT/.claude/skills/$skill_name"
    cp "$skill_dir/SKILL.md" "$REPO_ROOT/.claude/skills/$skill_name/"
    count=$((count + 1))
  done

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

  # Generate .gitignore for synced skills — project-specific skills stay committable
  {
    echo "# Auto-generated by rl skills sync — do not edit"
    echo "# Synced skills are managed by rl and should not be committed."
    echo "# Project-specific skills (not listed here) SHOULD be committed."
    echo ""
    echo "SKILLS_INDEX.md"
    # Universal
    for skill_dir in "$skills_src/universal"/*/; do
      [[ -d "$skill_dir" ]] || continue
      echo "${skill_dir:t}/"
    done
    # rl (same condition logic as sync)
    for skill_dir in "$skills_src/rl"/*/; do
      [[ -d "$skill_dir" ]] || continue
      local sync_cond="always"
      if [[ -f "$skill_dir/SKILL.md" ]]; then
        local found_cond=$(sed -n 's/.*<!-- *sync: *\([a-z]*\) *-->.*/\1/p' "$skill_dir/SKILL.md" 2>/dev/null | head -1)
        [[ -n "$found_cond" ]] && sync_cond="$found_cond"
      fi
      case "$sync_cond" in
        openspec)   [[ "$use_openspec" != "true" ]] && continue ;;
        dogfooding) [[ "$is_rl_toolkit" != "true" ]] && continue ;;
      esac
      echo "${skill_dir:t}/"
    done
  } > "$REPO_ROOT/.claude/skills/.gitignore"

  # Generate SKILLS_INDEX.md — machine-readable index for LLM skill selection
  # The bootstrapper and build agent read this to match skills to tickets
  {
    echo "# Available Skills"
    echo ""
    echo "This index is auto-generated by \`rl skills sync\`. Read this file to understand"
    echo "which skills are available and when to use each one. When creating tickets,"
    echo "list relevant skill names in the ticket's \`## Skills\` section."
    echo ""
    for sdir in "$REPO_ROOT/.claude/skills"/*/; do
      [[ -f "$sdir/SKILL.md" ]] || continue
      local sname="${sdir:t}"
      # Extract description from frontmatter or first meaningful line
      local sdesc=""
      sdesc=$(sed -n '/^description:/{s/^description: *"*//;s/"*$//;p;q;}' "$sdir/SKILL.md" 2>/dev/null)
      if [[ -z "$sdesc" ]]; then
        sdesc=$(sed -n '/^[^#<@ -]/{s/\[FILL[^]]*\]//g; s/^ *//; /^$/d; p; q;}' "$sdir/SKILL.md" 2>/dev/null)
      fi
      # Extract tags if present
      local stags=""
      stags=$(sed -n 's/.*<!-- *tags: *\(.*\) *-->.*/\1/p' "$sdir/SKILL.md" 2>/dev/null | head -1)
      [[ -z "$sdesc" ]] && sdesc="(no description)"
      if [[ -n "$stags" ]]; then
        echo "- **$sname** [$stags] — $sdesc"
      else
        echo "- **$sname** — $sdesc"
      fi
    done
  } > "$REPO_ROOT/.claude/skills/SKILLS_INDEX.md"

  print -P "${G}${B}Synced:${R} $count skills from source, $override_count project overrides applied."
  print -P "${D}Updated .claude/skills/.gitignore and SKILLS_INDEX.md${R}"
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

  # Find the skill in rl/ or universal/
  local src=""
  if [[ -d "$RL_ROOT/resources/skills/rl/$name" ]]; then
    src="$RL_ROOT/resources/skills/rl/$name"
  elif [[ -d "$RL_ROOT/resources/skills/universal/$name" ]]; then
    src="$RL_ROOT/resources/skills/universal/$name"
  else
    print -P "${ERR}${B}Error:${R} Skill not found in rl source: $name"
    print -P "${D}Only rl and universal skills can be overridden. Tool skills are added via 'rl skills add'.${R}"
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
  local -a rl_skills=() universal_skills=() tools_skills=() custom_skills=()

  for sdir in "$skills_dir"/*/; do
    [[ -f "$sdir/SKILL.md" ]] || continue
    local name="${${sdir%/}:t}"

    # Try to read category from HTML comment in SKILL.md
    local file_cat=""
    file_cat=$(sed -n 's/.*<!-- *category: *\([a-z]*\) *-->.*/\1/p' "$sdir/SKILL.md" 2>/dev/null | head -1)

    # Fall back to directory-based detection
    if [[ -z "$file_cat" ]]; then
      if [[ -d "$RL_ROOT/resources/skills/rl/$name" ]]; then
        file_cat="rl"
      elif [[ -d "$RL_ROOT/resources/skills/universal/$name" ]]; then
        file_cat="universal"
      elif find_tool_skill "$name"; then
        file_cat="tools"
      else
        file_cat="custom"
      fi
    fi

    case "$file_cat" in
      rl)        rl_skills+=("$name") ;;
      universal) universal_skills+=("$name") ;;
      tools)     tools_skills+=("$name") ;;
      *)         custom_skills+=("$name") ;;
    esac
  done

  print -P "${C}${B}Installed skills:${R}"

  if (( ${#rl_skills} )); then
    print -P "\n  ${G}${B}rl${R} ${D}(Ralph Loop operations)${R}"
    for s in "${rl_skills[@]}"; do print -P "    ${G}$s${R}"; done
  fi

  if (( ${#universal_skills} )); then
    print -P "\n  ${G}${B}Universal${R} ${D}(software engineering principles)${R}"
    for s in "${universal_skills[@]}"; do print -P "    ${G}$s${R}"; done
  fi

  if (( ${#tools_skills} )); then
    print -P "\n  ${Y}${B}Tools${R} ${D}(technology-specific)${R}"
    for s in "${tools_skills[@]}"; do print -P "    ${Y}$s${R}"; done
  fi

  if (( ${#custom_skills} )); then
    print -P "\n  ${B}Custom${R} ${D}(project-specific)${R}"
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

  # _TEMPLATE.md lives in domain/ directory
  local template_src="$RL_ROOT/resources/skills/tools/_TEMPLATE.md"
  if [[ ! -f "$template_src" ]]; then
    print -P "${ERR}${B}Error:${R} Meta-template not found at $template_src"
    exit 1
  fi

  local dst_dir
  if [[ "$global" == "true" ]]; then
    # Pick a category
    local category=""
    print -P "Available categories:"
    local -a cats=()
    for cdir in "$RL_ROOT"/resources/skills/tools/*/; do
      [[ -d "$cdir" ]] || continue
      cats+=("${cdir:t}")
      print -P "  ${cdir:t}"
    done
    print -n "  Category: "
    read -r category
    if [[ -z "$category" ]] || ! [[ -d "$RL_ROOT/resources/skills/tools/$category" ]]; then
      print -P "${ERR}${B}Error:${R} Invalid category: $category"
      exit 1
    fi
    dst_dir="$RL_ROOT/resources/skills/tools/$category/$name"
    print -P "Creating ${C}global${R} skill: $category/$name"
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

  for skill_dir in "$RL_ROOT"/resources/skills/rl/openspec-*/; do
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
