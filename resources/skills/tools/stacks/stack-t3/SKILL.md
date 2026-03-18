# T3 Stack Skill

<!-- category: stack -->

## Overview
The T3 Stack combines Next.js, tRPC, Prisma, Tailwind CSS, and NextAuth (Auth.js)
into a full-stack, end-to-end type-safe TypeScript application. The guiding
principles are typesafety, modularity, and full-stack TypeScript with zero codegen
beyond Prisma.
[FILL: How the T3 stack is used in THIS project -- which optional pieces are included]

## Core Components

| Layer          | Tool              | Role                                  |
|----------------|-------------------|---------------------------------------|
| Framework      | Next.js (App Router) | Routing, SSR, API routes           |
| API            | tRPC              | Type-safe RPC between client/server   |
| ORM            | Prisma            | Database access, migrations, schema   |
| Styling        | Tailwind CSS      | Utility-first styling                 |
| Auth           | NextAuth / Auth.js| Authentication, session management    |
| Validation     | Zod               | Input validation for tRPC procedures  |
| Client Data    | @tanstack/react-query | Caching, refetching (powers tRPC client) |

## tRPC Setup

- Router location: [FILL: Path to src/server/api/routers/]
- Root router: [FILL: Path to src/server/api/root.ts]
- tRPC context: [FILL: Path to src/server/api/trpc.ts -- createTRPCContext]
- Every procedure input MUST use a Zod schema -- never use raw `any`
- Use `protectedProcedure` for auth-required endpoints, `publicProcedure` otherwise

## Server Components + tRPC

- Use server-side caller (`createCaller`) in Server Components for direct DB access
  without HTTP round-trips
- Use `api` from `@trpc/react-query` in Client Components for reactive data
- [FILL: Pattern used -- RSC caller, prefetching with hydration, or client-only]

## Type-Safe End-to-End Flow

1. Define Zod schema for input validation
2. Prisma generates types from database schema
3. tRPC infers input/output types from Zod + Prisma return types
4. Client gets full autocomplete and type checking -- zero manual type definitions
- [FILL: Any custom type utilities or overrides used in this project]

## Environment Validation

- Uses `@t3-oss/env-nextjs` for runtime-validated environment variables
- All env vars declared in: [FILL: Path to src/env.js or src/env.mjs]
- Server-only vars use `server: {}` block, client vars use `client: {}` with
  `NEXT_PUBLIC_` prefix
- Build fails if required env vars are missing -- this is intentional

## Project Structure Conventions

```
src/
  app/               # Next.js App Router pages and layouts
  server/
    api/
      routers/       # tRPC routers (one per domain)
      root.ts        # Merges all routers
      trpc.ts        # tRPC initialization, context, middleware
    db.ts            # Prisma client singleton
    auth.ts          # NextAuth configuration
  trpc/              # Client-side tRPC setup (react.tsx, server.ts)
  components/        # Shared UI components
  lib/               # Utility functions
prisma/
  schema.prisma      # Database schema
```
[FILL: Deviations from the standard T3 structure in this project]

## Auth Integration

- NextAuth session available via `auth()` in Server Components and API routes
- tRPC context automatically includes session via `createTRPCContext`
- [FILL: Auth providers configured -- GitHub, Google, Credentials, etc.]
- [FILL: Session strategy -- JWT or database sessions]

## Database & Prisma

- Schema location: [FILL: Path to prisma/schema.prisma]
- Prisma Client singleton pattern prevents hot-reload connection exhaustion
- Migrations: `npx prisma migrate dev` (development), `npx prisma migrate deploy` (production)
- [FILL: Database provider -- PostgreSQL, MySQL, SQLite, PlanetScale]

## Key Constraints

- Never import server code (`server/`) in client components
- All tRPC inputs must have Zod validation -- no exceptions
- [FILL: Performance requirements, rate limiting on procedures]
- [FILL: Additional project-specific constraints]

## Common Backpressure

```bash
npx prisma generate && npx tsc --noEmit && npm run lint && npm run build
```

## Where to Look

- tRPC routers: [FILL: Path to src/server/api/routers/]
- Prisma schema: [FILL: Path to prisma/schema.prisma]
- Auth config: [FILL: Path to src/server/auth.ts]
- Env validation: [FILL: Path to src/env.js]
- Docs: https://create.t3.gg/en/introduction

## Common Pitfalls

- Forgetting to run `prisma generate` after schema changes causes stale types
- tRPC batching can cause confusing errors if one procedure in a batch fails
- [FILL: Project-specific gotchas encountered]
