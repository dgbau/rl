#!/usr/bin/env zsh
# create.sh — Create a new Nx project with the Ralph Loop pre-installed
# Usage: rl create

set -euo pipefail
source "${0:A:h}/lib/common.sh"

# ---------------------------------------------------------------------------
# Prerequisite checks
# ---------------------------------------------------------------------------
check_prereqs || exit 1

# Also need npx for Nx workspace creation
if ! (( $+commands[npx] )); then
  print -P "${ERR}${B}Error:${R} npx is required. Install Node.js first."
  exit 1
fi

# ---------------------------------------------------------------------------
# Interview
# ---------------------------------------------------------------------------
print -P "\n${C}${B}=== Ralph Loop — New Project ====${R}\n"

# Project name
local project_name
project_name=$(prompt_text "Project name (slug format)")
validate_slug "$project_name" || exit 1

local project_dir="$HOME/src/$project_name"
if [[ -d "$project_dir" ]]; then
  print -P "${ERR}${B}Error:${R} Directory already exists: $project_dir"
  exit 1
fi

# Project description (optional)
local project_desc
project_desc=$(prompt_text "Project description (optional)" "")

# Nx preset
print ""
local -a presets=()
while IFS= read -r line; do
  [[ -n "$line" ]] && presets+=("$line")
done < <(query_presets)

local nx_preset
nx_preset=$(prompt_select "Nx preset:" "${presets[@]}")

# App name (derived from preset)
local app_name=""
case "$nx_preset" in
  next|react|angular|vue|nuxt)
    app_name=$(prompt_text "App name" "web")
    ;;
  node|nest|express)
    app_name=$(prompt_text "App name" "api")
    ;;
  apps|ts)
    app_name=$(prompt_text "App name (optional)" "")
    ;;
  *)
    app_name=$(prompt_text "App name (optional)" "")
    ;;
esac

# Essential foundations
print -P "\n${C}${B}Essential Foundations${R}"

local use_tailwind=false
case "$nx_preset" in
  next|react|angular|vue|nuxt)
    if prompt_yn "Install Tailwind CSS v4?"; then
      use_tailwind=true
    fi
    ;;
esac

local use_ts_strict=true
if ! prompt_yn "TypeScript strict mode?"; then
  use_ts_strict=false
fi

# Skill templates
local -a available_templates=()
for tdir in "$RL_ROOT"/resources/skills/templates/*/; do
  [[ -f "$tdir/SKILL.md" ]] || continue
  local tname="${tdir:h:t}"
  [[ "$tname" == "_TEMPLATE" ]] && continue
  available_templates+=("$tname")
done

local -a selected_skills=()
if (( ${#available_templates} )); then
  print ""
  while IFS= read -r line; do
    [[ -n "$line" ]] && selected_skills+=("$line")
  done < <(prompt_multiselect "Skill templates to install:" "${available_templates[@]}")
fi

# OpenSpec
print ""
local use_openspec=false
if prompt_yn "Use OpenSpec for spec-driven development?"; then
  use_openspec=true
fi

# GitHub repo
local create_github=false
if prompt_yn "Create GitHub repository?" "n"; then
  create_github=true
fi

# ---------------------------------------------------------------------------
# Confirm
# ---------------------------------------------------------------------------
print -P "\n${C}${B}=== Summary ===${R}"
print -P "  ${D}Project:${R}    $project_name"
print -P "  ${D}Directory:${R}  $project_dir"
print -P "  ${D}Preset:${R}     $nx_preset"
[[ -n "$app_name" ]] && print -P "  ${D}App:${R}        $app_name"
print -P "  ${D}Tailwind:${R}   $use_tailwind"
print -P "  ${D}TS strict:${R}  $use_ts_strict"
print -P "  ${D}OpenSpec:${R}   $use_openspec"
print -P "  ${D}GitHub:${R}     $create_github"
(( ${#selected_skills} )) && print -P "  ${D}Skills:${R}     ${(j:, :)selected_skills}"
print ""

if ! prompt_yn "Proceed?"; then
  print "Aborted."
  exit 0
fi

# ---------------------------------------------------------------------------
# Create Nx workspace
# ---------------------------------------------------------------------------
print -P "\n${C}${B}Creating Nx workspace...${R}"

mkdir -p "$project_dir"

local -a nx_args=(
  .
  "--preset=$nx_preset"
  "--packageManager=pnpm"
  "--no-interactive"
)
[[ -n "$app_name" ]] && nx_args+=("--appName=$app_name")

( cd "$project_dir" && npx create-nx-workspace@latest "${nx_args[@]}" )

# ---------------------------------------------------------------------------
# Install essential foundations
# ---------------------------------------------------------------------------
if [[ "$use_tailwind" == "true" ]]; then
  print -P "\n${C}${B}Installing Tailwind CSS v4...${R}"
  ( cd "$project_dir" && pnpm add -D tailwindcss@^4 @tailwindcss/postcss@^4 )

  # Create postcss.config.mjs if it doesn't exist
  if [[ ! -f "$project_dir/postcss.config.mjs" ]]; then
    cat > "$project_dir/postcss.config.mjs" <<'EOF'
export default {
  plugins: {
    "@tailwindcss/postcss": {},
  },
};
EOF
  fi
fi

if [[ "$use_ts_strict" == "true" ]]; then
  # Ensure strict mode in tsconfig
  local tsconfig="$project_dir/tsconfig.base.json"
  [[ ! -f "$tsconfig" ]] && tsconfig="$project_dir/tsconfig.json"
  if [[ -f "$tsconfig" ]]; then
    local current_strict
    current_strict=$(jq -r '.compilerOptions.strict // false' "$tsconfig" 2>/dev/null || echo "false")
    if [[ "$current_strict" != "true" ]]; then
      local tmp
      tmp=$(mktemp)
      jq '.compilerOptions.strict = true' "$tsconfig" > "$tmp" && mv "$tmp" "$tsconfig"
      print -P "  ${G}enabled:${R} TypeScript strict mode"
    fi
  fi
fi

# ---------------------------------------------------------------------------
# Install OpenSpec (if opted in)
# ---------------------------------------------------------------------------
if [[ "$use_openspec" == "true" ]]; then
  print -P "\n${C}${B}Installing OpenSpec...${R}"
  ( cd "$project_dir" && pnpm add -D @fission-ai/openspec && npx openspec init 2>/dev/null || true )
fi

# ---------------------------------------------------------------------------
# Install Ralph Loop via install.sh
# ---------------------------------------------------------------------------
print -P "\n${C}${B}Installing Ralph Loop...${R}"

local -a install_args=("$project_dir" "--no-prompt")
if [[ "$use_openspec" == "true" ]]; then
  install_args+=("--use-openspec")
else
  install_args+=("--no-openspec")
fi
if (( ${#selected_skills} )); then
  install_args+=("--skills" "${(j:,:)selected_skills}")
fi

"${0:A:h}/install.sh" "${install_args[@]}"

# ---------------------------------------------------------------------------
# Git setup
# ---------------------------------------------------------------------------
print -P "\n${C}${B}Setting up git...${R}"
(
  cd "$project_dir"

  # Nx may have already initialized git; if not, do it
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    git init
  fi

  git add -A
  git commit -m "chore: scaffold $project_name with ralph loop

- Nx preset: $nx_preset
- OpenSpec: $use_openspec
- Tailwind: $use_tailwind
- TypeScript strict: $use_ts_strict"
)

# ---------------------------------------------------------------------------
# GitHub repo (optional)
# ---------------------------------------------------------------------------
if [[ "$create_github" == "true" ]]; then
  print -P "\n${C}${B}Creating GitHub repository...${R}"
  (
    cd "$project_dir"
    gh repo create "$project_name" --private --source=. --push
  )
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
print -P "\n${G}${B}Project created successfully!${R}\n"
print -P "  ${C}Directory:${R}  $project_dir"
print ""
print -P "${Y}Next steps:${R}"
print "  1. cd $project_dir"
print "  2. git checkout -b ralph/my-feature"
print "  3. ./ralph/loop.sh interview"
