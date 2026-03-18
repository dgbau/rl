---
<!-- sync: openspec -->
name: openspec-workflow
description: "OpenSpec spec-driven development workflow for creating proposals, writing delta specs, and archiving changes. Use when working with the openspec/ directory or managing the proposal-to-archive lifecycle."
---

# OpenSpec Workflow

[OpenSpec](https://github.com/fission-ai/openspec) maintains living system documentation through a proposal -> implement -> archive lifecycle.

## Directory Structure

```
openspec/
├── specs/                    # Source of truth: how the system works NOW
│   └── <domain>/
│       └── spec.md
├── changes/                  # Active proposals (one folder per change)
│   └── <change-id>/
│       ├── .openspec.yaml    # Schema and metadata
│       ├── README.md         # Change description
│       ├── proposal.md       # Why: intent, scope, capabilities (artifact 1)
│       ├── design.md         # How: technical approach (artifact 2)
│       ├── specs/            # What: delta specs (artifact 3)
│       │   └── <domain>/
│       │       └── spec.md
│       └── tasks.md          # Task breakdown (artifact 4)
└── config.yaml               # Optional configuration
```

Artifacts have a dependency chain: proposal → design + specs → tasks.
Use `npx openspec status --change <id>` to see which artifacts are complete.

## Commands

```bash
npx openspec new change <change-id>              # Create change folder
npx openspec status --change <change-id>          # Check artifact completion
npx openspec instructions <artifact> --change <id> # Get artifact template
npx openspec show <change-id>                     # View change proposal
npx openspec list                                 # List active changes
npx openspec validate <change-id>                 # Validate spec format
npx openspec archive <change-id> -y               # Merge deltas into specs/
```

## Delta Spec Format

Delta specs describe what's changing relative to current specs:

```markdown
# Delta for <Domain>

## ADDED Requirements

### Requirement: Feature Name
The system SHALL [behavior description].

#### Scenario: Happy path
- GIVEN [precondition]
- WHEN [action]
- THEN [expected result]

## MODIFIED Requirements

### Requirement: Existing Feature
The system SHALL [updated behavior].
(Previously: [old behavior])

## REMOVED Requirements

### Requirement: Deprecated Feature
(Reason for removal)
```

## Archive Behavior

When `npx openspec archive <change-id> -y` runs:
1. ADDED requirements are appended to the main spec
2. MODIFIED requirements replace the existing version
3. REMOVED requirements are deleted from the main spec
4. Change folder moves to `openspec/changes/archive/<date>-<change-id>/`

## Integration with tk

- Epic tickets carry `--external-ref "openspec:<change-id>"` to link to the OpenSpec change
- When all tickets in an epic are closed, archive the linked OpenSpec change
- The `external-ref` field is the glue between task execution ([`tk`](https://github.com/wedow/ticket)) and system documentation ([OpenSpec](https://github.com/fission-ai/openspec))
