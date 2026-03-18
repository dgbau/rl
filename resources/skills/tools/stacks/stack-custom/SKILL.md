# Custom Stack Skill

<!-- category: stack -->

## Overview
This is a universal template for any technology combination not covered by a
dedicated stack template. Fill in each section with your project's specific
technologies, patterns, and conventions.
[FILL: One-paragraph description of what this project does and the technologies it combines]

## Stack Components

| Layer           | Tool / Technology | Version | Role                         |
|-----------------|-------------------|---------|------------------------------|
| Frontend        | [FILL]            | [FILL]  | [FILL: UI rendering]         |
| Backend / API   | [FILL]            | [FILL]  | [FILL: Business logic, API]  |
| Database        | [FILL]            | [FILL]  | [FILL: Persistence]          |
| Auth            | [FILL]            | [FILL]  | [FILL: Authentication]       |
| Styling         | [FILL]            | [FILL]  | [FILL: CSS / design system]  |
| Hosting         | [FILL]            | [FILL]  | [FILL: Deployment target]    |
| [FILL: Other]   | [FILL]            | [FILL]  | [FILL: Role]                 |

## Integration Points

How the stack components connect to each other:

- Frontend <-> API: [FILL: REST, GraphQL, tRPC, gRPC, WebSocket, etc.]
- API <-> Database: [FILL: ORM, query builder, raw SQL, driver]
- Auth flow: [FILL: How auth tokens/sessions propagate across layers]
- [FILL: Other integration points -- cache, queue, storage, CDN]
- [FILL: Shared types or contracts between layers -- OpenAPI, Protobuf, TypeScript types]

## Known Conflicts & Gotchas

Things that don't work together smoothly out of the box:

- [FILL: CSS conflicts between libraries/frameworks]
- [FILL: Version incompatibilities or peer dependency issues]
- [FILL: Runtime conflicts -- e.g., SSR hydration, module systems, polyfills]
- [FILL: Configuration overlaps -- two tools wanting to own the same config]
- [FILL: Development server port conflicts or proxy needs]

## Configuration Crossover

Where configuration of one tool affects another:

- [FILL: Build tool config that must account for multiple frameworks]
- [FILL: TypeScript/type config shared across frontend and backend]
- [FILL: Environment variables needed by multiple components]
- [FILL: Shared configuration files and their locations]

## Architecture & Patterns

- Architecture style: [FILL: Monolith, monorepo, microservices, serverless, etc.]
- Data flow: [FILL: Unidirectional, event-driven, request-response, etc.]
- State management: [FILL: Where state lives -- server, client, both, how synced]
- Rendering strategy: [FILL: SSR, CSR, SSG, ISR, streaming, or N/A]
- [FILL: Key architectural decisions and their rationale]

## Project Structure

```
[FILL: Directory tree showing where each technology's code lives]
```

## Development Workflow

- Setup: [FILL: Steps to get a new developer running -- install, configure, seed]
- Dev server(s): [FILL: Commands to start development -- single command or multiple]
- Hot reload: [FILL: Which parts hot-reload and which require restart]
- [FILL: How to run the full stack locally -- Docker Compose, Procfile, Turborepo]

## Build & Deploy Pipeline

- Build order: [FILL: Dependency order for building components]
- Build command: [FILL: Single build command or per-component]
- Deploy target: [FILL: Vercel, AWS, GCP, Docker, bare metal, etc.]
- CI checks: [FILL: Lint, type-check, test, build steps]

## Testing Strategy

- Unit tests: [FILL: Framework, location, what they cover]
- Integration tests: [FILL: How components are tested together]
- E2E tests: [FILL: Tool (Playwright, Cypress), what flows are covered]
- [FILL: How to run each test suite]

## Key Constraints

- [FILL: Performance budgets or SLAs]
- [FILL: Browser/platform support requirements]
- [FILL: Security requirements -- encryption, compliance, audit]
- [FILL: Scaling constraints -- concurrent users, data volume]

## Where to Look

- [FILL: Path to frontend code]
- [FILL: Path to backend/API code]
- [FILL: Path to database schema/migrations]
- [FILL: Path to configuration files for each tool]
- [FILL: Path to shared types or contracts]

## Lessons Learned

Document hard-won knowledge from building with this stack:

- [FILL: What worked well and should be repeated]
- [FILL: What was painful and how it was resolved]
- [FILL: Libraries that were tried and abandoned, and why]
- [FILL: Performance optimizations discovered]
- [FILL: Deployment lessons -- cold starts, memory, timeouts]

## Dependencies & Related Skills

- [FILL: Other skills this one depends on or complements]
- [FILL: Links to official documentation for each technology in the stack]
