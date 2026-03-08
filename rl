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
  skills)
    shift
    exec "$RL_DIR/skills.sh" "$@"
    ;;
  -h|--help|"")
    print "Usage: rl <command> [args...]"
    print ""
    print "Commands:"
    print "  create          Create a new Nx project with Ralph Loop (--help for flags)"
    print "  install [dir]   Add Ralph Loop to an existing repository"
    print "  skills          Manage skill templates (list, add, new)"
    print ""
    print "Run 'rl <command> --help' for details."
    ;;
  *)
    print "rl: unknown command '$1'" >&2
    print "Run 'rl --help' for usage." >&2
    exit 1
    ;;
esac
