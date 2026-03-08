#!/usr/bin/env zsh
# create.sh — Create a new Nx project with the Ralph Loop pre-installed
#
# Usage:
#   rl create                    # Interactive mode (prompts for all options)
#   rl create --no-prompt \      # Non-interactive mode (for programmatic use)
#     --name my-app \
#     --preset apps \
#     --skills react,tailwind
#
# Required with --no-prompt:
#   --name NAME         Project name (kebab-case slug)
#   --preset PRESET     Nx preset (apps, ts, next, react, node, etc.)
#
# Optional:
#   --app-name NAME     App name within workspace
#   --description TEXT  Project description
#   --skills LIST       Comma-separated skill templates
#   --tailwind          Install Tailwind CSS v4 (default for frontend presets)
#   --no-tailwind       Skip Tailwind
#   --strict-ts         Enable TypeScript strict mode (default: true)
#   --no-strict-ts      Disable TypeScript strict mode
#   --openspec          Enable OpenSpec spec-driven development
#   --no-openspec       Disable OpenSpec (default)
#   --github            Create GitHub repository
#   --no-github         Skip GitHub repo creation (default)
#   --no-prompt         Skip all interactive prompts (requires --name, --preset)

set -euo pipefail
source "${0:A:h}/lib/common.sh"

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
local NO_PROMPT=false
local project_name=""
local project_desc=""
local nx_preset=""
local app_name=""
local use_tailwind=""        # "" = unset (will use smart default or prompt)
local use_ts_strict=true
local use_openspec=false
local create_github=false
local -a selected_skills=()

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-prompt)     NO_PROMPT=true; shift ;;
    --name)          project_name="$2"; shift 2 ;;
    --preset)        nx_preset="$2"; shift 2 ;;
    --app-name)      app_name="$2"; shift 2 ;;
    --description)   project_desc="$2"; shift 2 ;;
    --skills)        selected_skills=("${(@s:,:)2}"); shift 2 ;;
    --tailwind)      use_tailwind=true; shift ;;
    --no-tailwind)   use_tailwind=false; shift ;;
    --strict-ts)     use_ts_strict=true; shift ;;
    --no-strict-ts)  use_ts_strict=false; shift ;;
    --openspec)      use_openspec=true; shift ;;
    --no-openspec)   use_openspec=false; shift ;;
    --github)        create_github=true; shift ;;
    --no-github)     create_github=false; shift ;;
    -h|--help)
      print "Usage: rl create [options]"
      print ""
      print "Options:"
      print "  --name NAME         Project name (kebab-case slug)"
      print "  --preset PRESET     Nx preset (apps, ts, next, react, node, etc.)"
      print "  --app-name NAME     App name within workspace"
      print "  --description TEXT  Project description"
      print "  --skills LIST       Comma-separated skill templates to install"
      print "  --tailwind          Install Tailwind CSS v4"
      print "  --no-tailwind       Skip Tailwind installation"
      print "  --strict-ts         Enable TypeScript strict mode (default)"
      print "  --no-strict-ts      Disable TypeScript strict mode"
      print "  --openspec          Enable OpenSpec spec-driven development"
      print "  --no-openspec       Disable OpenSpec (default)"
      print "  --github            Create GitHub repository"
      print "  --no-github         Skip GitHub repo (default)"
      print "  --no-prompt         Skip all interactive prompts"
      print ""
      print "Examples:"
      print "  rl create                          # Interactive mode"
      print "  rl create --no-prompt --name my-app --preset next --skills nextjs,tailwind"
      exit 0
      ;;
    *)
      print -P "${ERR}${B}Error:${R} Unknown option: $1"
      print "Run 'rl create --help' for usage."
      exit 1
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Prerequisite checks
# ---------------------------------------------------------------------------
check_prereqs || exit 1

if ! (( $+commands[npx] )); then
  print -P "${ERR}${B}Error:${R} npx is required. Install Node.js first."
  exit 1
fi

# ---------------------------------------------------------------------------
# Interview (interactive) or validate flags (non-interactive)
# ---------------------------------------------------------------------------
if [[ "$NO_PROMPT" == "true" ]]; then
  # Validate required flags
  if [[ -z "$project_name" ]]; then
    print -P "${ERR}${B}Error:${R} --name is required with --no-prompt"
    exit 1
  fi
  if [[ -z "$nx_preset" ]]; then
    print -P "${ERR}${B}Error:${R} --preset is required with --no-prompt"
    exit 1
  fi
  validate_slug "$project_name" || exit 1

  # Smart defaults for tailwind if not explicitly set
  if [[ -z "$use_tailwind" ]]; then
    case "$nx_preset" in
      next|react|angular|vue|nuxt) use_tailwind=true ;;
      *) use_tailwind=false ;;
    esac
  fi

  # Smart defaults for app name if not set
  if [[ -z "$app_name" ]]; then
    case "$nx_preset" in
      next|react|angular|vue|nuxt) app_name="web" ;;
      node|nest|express) app_name="api" ;;
      *) app_name="" ;;
    esac
  fi
else
  # --- Interactive interview ---
  print -P "\n${C}${B}=== Ralph Loop — New Project ====${R}\n"

  # Project name
  if [[ -z "$project_name" ]]; then
    project_name=$(prompt_text "Project name (slug format)")
  fi
  validate_slug "$project_name" || exit 1

  # Project description
  if [[ -z "$project_desc" ]]; then
    project_desc=$(prompt_text "Project description (optional)" "")
  fi

  # Nx preset
  if [[ -z "$nx_preset" ]]; then
    print ""
    local -a presets=()
    while IFS= read -r line; do
      [[ -n "$line" ]] && presets+=("$line")
    done < <(query_presets)
    nx_preset=$(prompt_select "Nx preset:" "${presets[@]}")
  fi

  # App name (derived from preset)
  if [[ -z "$app_name" ]]; then
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
  fi

  # Tailwind
  if [[ -z "$use_tailwind" ]]; then
    use_tailwind=false
    print -P "\n${C}${B}Essential Foundations${R}"
    case "$nx_preset" in
      next|react|angular|vue|nuxt)
        if prompt_yn "Install Tailwind CSS v4?"; then
          use_tailwind=true
        fi
        ;;
    esac
  fi

  # TypeScript strict
  if ! prompt_yn "TypeScript strict mode?"; then
    use_ts_strict=false
  fi

  # Skill templates
  if (( ${#selected_skills} == 0 )); then
    local -a available_templates=()
    for tdir in "$RL_ROOT"/resources/skills/templates/*/; do
      [[ -f "$tdir/SKILL.md" ]] || continue
      local tname="${${tdir%/}:t}"
      [[ "$tname" == "_TEMPLATE" ]] && continue
      available_templates+=("$tname")
    done

    if (( ${#available_templates} )); then
      print ""
      while IFS= read -r line; do
        [[ -n "$line" ]] && selected_skills+=("$line")
      done < <(prompt_multiselect "Skill templates to install:" "${available_templates[@]}")
    fi
  fi

  # OpenSpec
  print ""
  if prompt_yn "Use OpenSpec for spec-driven development?" "n"; then
    use_openspec=true
  fi

  # GitHub repo
  if prompt_yn "Create GitHub repository?" "n"; then
    create_github=true
  fi

  # Confirm
  print -P "\n${C}${B}=== Summary ===${R}"
  print -P "  ${D}Project:${R}    $project_name"
  print -P "  ${D}Directory:${R}  $HOME/src/$project_name"
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
fi

# ---------------------------------------------------------------------------
# Validate project directory
# ---------------------------------------------------------------------------
local project_dir="$HOME/src/$project_name"
if [[ -d "$project_dir" ]]; then
  print -P "${ERR}${B}Error:${R} Directory already exists: $project_dir"
  exit 1
fi

# ---------------------------------------------------------------------------
# Create Nx workspace
# ---------------------------------------------------------------------------
print -P "\n${C}${B}Creating Nx workspace...${R}"

local parent_dir="${project_dir:h}"
mkdir -p "$parent_dir"

local -a nx_args=(
  "$project_name"
  "--preset=$nx_preset"
  "--packageManager=pnpm"
  "--nxCloud=skip"
  "--no-interactive"
)
[[ -n "$app_name" ]] && nx_args+=("--appName=$app_name")

( cd "$parent_dir" && npx create-nx-workspace@latest "${nx_args[@]}" )

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
