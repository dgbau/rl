# Nx — Monorepo Tooling & Features

<!-- category: universal -->

## Overview

Comprehensive guide to Nx monorepo tooling — task orchestration, caching, code generation, dependency graph, and all major features. This is a core skill (always installed) since `rl create` generates Nx workspaces and many rl-managed projects use Nx.

## Core Concepts

### What Nx does
- **Task orchestration**: Run build/test/lint across projects respecting dependency order
- **Computation caching**: Never rebuild what hasn't changed (local + remote cache)
- **Affected analysis**: Only run tasks on projects impacted by current changes
- **Code generation**: Scaffold projects, libraries, and components consistently
- **Dependency graph**: Visualize and enforce project boundaries

### Project types
| Type | Purpose | Location |
|------|---------|----------|
| Application | Deployable unit | `apps/<name>/` |
| Library | Shared code | `libs/<name>/` |
| E2E project | End-to-end tests | `apps/<name>-e2e/` |

### Key files
| File | Purpose |
|------|---------|
| `nx.json` | Workspace-wide Nx configuration (caching, task pipelines, plugins) |
| `project.json` | Per-project targets (build, test, lint, serve) — equivalent to package.json scripts |
| `tsconfig.base.json` | Shared TypeScript paths for cross-project imports |
| `.nxignore` | Files/directories Nx should ignore for change detection |

## Task Running

### Essential commands
```bash
npx nx <target> <project>           # Run single target
npx nx run <project>:<target>       # Explicit form
npx nx affected -t <target>         # Run on affected projects only
npx nx run-many -t <target>         # Run on all projects
npx nx run-many -t lint test build  # Multiple targets
```

### Task pipelines (`nx.json`)
Define task dependencies — e.g., build depends on building dependencies first:
```json
{
  "targetDefaults": {
    "build": {
      "dependsOn": ["^build"],
      "cache": true
    },
    "test": {
      "cache": true
    },
    "lint": {
      "cache": true
    }
  }
}
```
- `^build` means "build my dependencies first" (topological)
- `dependsOn: ["build"]` means "run my own build first" (same project)
- Tasks without `dependsOn` can run in parallel

### Parallelization
- Nx automatically parallelizes independent tasks
- `--parallel=<N>` controls max concurrent tasks (default: 3)
- CI: `--parallel=1` for memory-constrained environments
- Task pipelines ensure correct execution order despite parallelism

## Caching

### How it works
1. Nx hashes: source files, dependencies, environment variables, command flags
2. On cache hit: restore output files and replay terminal output instantly
3. On cache miss: run the task, store results in cache

### Cache configuration
```json
{
  "targetDefaults": {
    "build": {
      "cache": true,
      "inputs": ["production", "^production"],
      "outputs": ["{projectRoot}/dist"]
    }
  },
  "namedInputs": {
    "production": ["default", "!{projectRoot}/**/*.spec.ts"]
  }
}
```

### Cache inputs
- `default` — all project files tracked by git
- `production` — exclude test files, stories, etc.
- `^production` — production files from dependencies
- `{ "env": "NODE_ENV" }` — include environment variable in hash
- `{ "runtime": "node --version" }` — include command output in hash

### Cache outputs
- `{projectRoot}/dist` — build artifacts
- `{projectRoot}/coverage` — test coverage reports
- Outputs are restored from cache on hit — must be accurate

### Remote caching (Nx Cloud)
- Share cache across CI and developers — dramatic CI speedup
- `npx nx connect` to enable Nx Cloud
- Self-hosted option: `@nx/powerpack-s3-cache`, `@nx/powerpack-gcs-cache`
- Cache is read-only in CI by default (only main branch populates)

## Affected Analysis

### How it works
```bash
npx nx affected -t test              # Test only what changed
npx nx affected -t lint test build   # Multiple targets on affected
npx nx affected --graph              # Visualize affected projects
```

- Compares current HEAD against base branch (default: `main`)
- Uses dependency graph to find all downstream projects
- `--base=origin/main --head=HEAD` — explicit base/head comparison
- Critical for CI: skip rebuilding unchanged projects

### What triggers "affected"
- Direct file changes in a project
- Changes to a dependency (library) that the project imports
- Changes to shared configuration (tsconfig.base.json, nx.json)
- Global file changes (root package.json, .env files)

## Code Generation

### Built-in generators
```bash
npx nx g @nx/react:app my-app          # New React app
npx nx g @nx/react:lib shared-ui       # New React library
npx nx g @nx/react:component Button    # New component
npx nx g @nx/node:app api              # New Node.js app
npx nx g @nx/next:app web              # New Next.js app
npx nx g @nx/express:app server        # New Express app
```

### Plugin ecosystem
| Plugin | Purpose |
|--------|---------|
| `@nx/react` | React apps, libs, components, hooks |
| `@nx/next` | Next.js applications |
| `@nx/node` | Node.js applications and libraries |
| `@nx/express` | Express applications |
| `@nx/nest` | NestJS applications |
| `@nx/angular` | Angular applications |
| `@nx/vue` | Vue applications |
| `@nx/js` | TypeScript/JavaScript libraries |
| `@nx/web` | Web applications (framework-agnostic) |
| `@nx/vite` | Vite-based build and test |
| `@nx/webpack` | Webpack-based build |
| `@nx/esbuild` | esbuild-based build |
| `@nx/rollup` | Rollup-based build |
| `@nx/jest` | Jest testing |
| `@nx/cypress` | Cypress E2E testing |
| `@nx/playwright` | Playwright E2E testing |
| `@nx/storybook` | Storybook integration |
| `@nx/eslint` | ESLint with project boundaries |
| `@nx/linter` | Linting infrastructure |

### Custom generators
- Create workspace-specific generators with `npx nx g @nx/plugin:generator`
- Define templates, prompts, and file transformations
- Share across the workspace for consistent scaffolding

## Dependency Graph

### Visualization
```bash
npx nx graph                    # Open interactive dependency graph in browser
npx nx graph --affected         # Show only affected projects
npx nx graph --focus=my-app     # Focus on specific project
```

### Module boundary enforcement
Use `@nx/eslint-plugin` to enforce project boundaries:
```json
// .eslintrc.json
{
  "rules": {
    "@nx/enforce-module-boundaries": ["error", {
      "depConstraints": [
        { "sourceTag": "scope:app", "onlyDependOnLibsWithTags": ["scope:shared", "scope:feature"] },
        { "sourceTag": "scope:feature", "onlyDependOnLibsWithTags": ["scope:shared"] },
        { "sourceTag": "scope:shared", "onlyDependOnLibsWithTags": ["scope:shared"] }
      ]
    }]
  }
}
```

### Project tags
- Tag projects in `project.json`: `"tags": ["scope:feature", "type:ui"]`
- Use tags in boundary rules to enforce architecture layers
- Common tag schemes: `scope:*` (domain), `type:*` (app/lib/util), `platform:*` (web/mobile/server)

## Library Organization

### Library types
| Type | Purpose | Example |
|------|---------|---------|
| Feature | Smart components, business logic | `libs/feature-auth/` |
| UI | Presentational components | `libs/ui-components/` |
| Data-access | API clients, state management | `libs/data-access-users/` |
| Utility | Pure functions, helpers | `libs/util-formatting/` |

### Naming convention
`<scope>-<type>-<name>`: `user-feature-profile`, `shared-ui-buttons`, `shared-util-date`

### When to extract a library
- Code is used by 2+ applications
- Code represents a distinct domain boundary
- Code has a clear public API
- You want independent caching/testing for that code

## Non-JS/TS Integration

For Go, Rust, Python, JVM, C/C++ projects in an Nx monorepo:

### `project.json` with `nx:run-commands`
```json
{
  "targets": {
    "build": {
      "executor": "nx:run-commands",
      "options": { "command": "go build ./..." },
      "cache": true,
      "inputs": ["default"],
      "outputs": ["{projectRoot}/bin"]
    },
    "test": {
      "executor": "nx:run-commands",
      "options": { "command": "go test ./..." },
      "cache": true
    },
    "lint": {
      "executor": "nx:run-commands",
      "options": { "command": "golangci-lint run ./..." },
      "cache": true
    }
  }
}
```

- Wrap any language's build tool in `nx:run-commands`
- Set `cache: true` with appropriate `inputs`/`outputs` for caching
- Affected analysis works automatically via the dependency graph
- `npx nx affected -t lint test build` orchestrates all languages

## CI Configuration

### GitHub Actions (typical)
```yaml
- uses: nrwl/nx-set-shas@v4            # Set base/head SHAs for affected
- run: npx nx affected -t lint test build --parallel=3
```

### Key CI flags
- `--configuration=ci` — CI-specific target configuration
- `--parallel=N` — control parallelism
- `--skip-nx-cache` — force fresh run (debugging)
- `--nx-bail` — stop on first failure (fail fast)

### Distributed task execution (Nx Agents)
- Split tasks across multiple CI machines automatically
- `npx nx-cloud start-ci-run --distribute-on="5 linux-medium-js"`
- Each machine pulls tasks from the queue, shares results via remote cache

## Migration and Updates

```bash
npx nx migrate latest              # Generate migrations for latest Nx version
npx nx migrate --run-migrations    # Apply generated migrations
```

- Nx provides automatic code migrations (codemods) for breaking changes
- Always review generated migrations before applying
- Update Nx and plugins together to maintain version compatibility

## Related Skills

- `backpressure` — Nx-aware backpressure commands
- `code-quality` — architecture principles Nx helps enforce
- `testing-principles` — testing patterns Nx orchestrates
