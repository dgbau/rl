#!/usr/bin/env zsh
# rl — Ralph Loop Toolkit
# Usage: rl <command> [args...]

set -euo pipefail

RL_DIR="${0:A:h}"

case "${1:-}" in
  create)
    shift
    exec "$RL_DIR/create.sh" "$@"
    ;;
  install)
    shift
    exec "$RL_DIR/install.sh" "$@"
    ;;
  loop)
    shift
    # Resolve repo root from current directory
    RL_REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
    export RL_REPO_ROOT
    exec "$RL_DIR/resources/core/loop.sh" "$@"
    ;;
  skills)
    shift
    exec "$RL_DIR/skills.sh" "$@"
    ;;
  migrate)
    shift
    exec "$RL_DIR/migrate.sh" "$@"
    ;;
  release)
    shift
    exec "$RL_DIR/release.sh" "$@"
    ;;
  update)
    shift
    echo "Updating rl toolkit..."
    (cd "$RL_DIR" && git pull --ff-only)
    echo "rl updated to $(cd "$RL_DIR" && git log --oneline -1)"
    ;;
  version|-v|--version)
    local ver=$(cd "$RL_DIR" && git describe --tags --always 2>/dev/null || echo "dev")
    print "rl $ver"
    ;;
  -h|--help|"")
    print "Usage: rl <command> [args...]"
    print ""
    print "Commands:"
    print "  create          Create a new Nx project with Ralph Loop"
    print "  install [dir]   Add Ralph Loop to an existing repository"
    print "  loop [mode]     Run the Ralph Loop (interview, bootstrap, build, amend, review, e2e)"
    print "  skills          Manage skill templates (list, add, new)"
    print "  migrate         Migrate a repo from ralph/ to .rl/ model"
    print "  release         Create a release (tag, changelog, GitHub release)"
    print "  update          Update the rl toolkit (git pull)"
    print "  version         Show rl version"
    print ""
    print "Run 'rl <command> --help' for details."
    ;;
  *)
    print "rl: unknown command '$1'" >&2
    print "Run 'rl --help' for usage." >&2
    exit 1
    ;;
esac
