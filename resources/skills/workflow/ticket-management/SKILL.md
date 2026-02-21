---
name: ticket-management
description: "Expertise in git-native task tracking using the tk CLI. Use when creating, querying, or managing tickets, dependencies, and ticket lifecycle."
---

# Ticket Management (tk)

Tickets are markdown files with YAML frontmatter stored in [`.tickets/`](../../.tickets/). The [`tk`](https://github.com/wedow/ticket) CLI manages them.

## Key Commands

```bash
tk create "title" [options]   # Create ticket, prints ID
tk start <id>                 # Set status to in_progress
tk close <id>                 # Set status to closed
tk ready                      # List tickets with all deps resolved (sorted by priority)
tk blocked                    # List tickets with unresolved deps
tk ls [--status=X]            # List all tickets
tk show <id>                  # Display ticket with blockers/blocking info
tk dep <id> <dep-id>          # id depends on dep-id
tk add-note <id> "text"       # Append timestamped note
tk query [jq-filter]          # Output as JSON for scripting
```

## Create Options

```bash
-t, --type          bug|feature|task|epic|chore [default: task]
-p, --priority      0-4, 0=highest [default: 2]
-d, --description   Description text
--design            Design notes
--acceptance        Acceptance criteria
--parent            Parent ticket ID (for task under epic)
--external-ref      External reference (e.g., openspec:change-id)
--tags              Comma-separated tags
-a, --assignee      Assignee
```

## Ticket Lifecycle

```
open --> in_progress --> closed
```

- `tk start <id>` transitions from `open` to `in_progress`
- `tk close <id>` transitions from `in_progress` to `closed`
- The build agent picks the next ticket via `tk ready | head -1`

## Ticket File Format

```markdown
---
id: xx-a1b2
status: open
deps: []
links: []
created: 2026-02-20T15:00:00Z
type: task
priority: 1
parent: xx-x9y8
external-ref: openspec:add-dark-mode
tags: [feature]
---
# Task Title

Description of what needs to be done.

## Skills
- `skill-name` -- relevant skill for this task

## Acceptance Criteria
- Measurable done criteria

## Design
- Technical approach notes
```

## Patterns

- **Epic + tasks**: Create epic first, then tasks with `--parent <epic-id>`
- **Dependencies**: `tk dep <blocked> <blocker>` -- blocked ticket waits for blocker
- **Pick next work**: `tk ready | head -1 | awk '{print $1}'`
- **Check completion**: `tk ready` returns empty AND `tk ls --status=open` returns empty
- **Partial ID matching**: `tk show a1b` matches `xx-a1b2`
- **Commit messages**: Use ticket ID as scope: `feat(xx-a1b2): implement feature`
- **Notes for learning**: `tk add-note <id> "lesson learned"` -- timestamped, persists in ticket file
- **JSON scripting**: `tk query '.[] | select(.status == "open")'` -- pipe to `jq` for custom queries
