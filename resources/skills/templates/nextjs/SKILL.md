# Next.js Skill

<!-- SKILL TEMPLATE — Sections marked [FILL] should be populated
     with project-specific details by the ralph loop during interview
     or build mode. -->

## Overview
Next.js is a React framework providing server-side rendering, static generation,
file-based routing, and API routes. It supports both the App Router (v13+) and
the legacy Pages Router.
[FILL: How Next.js is used in THIS project — version, router choice, rendering strategy]

## Router Architecture
- Router type: [FILL: App Router / Pages Router / hybrid]
- Layout strategy: [FILL: Root layout, nested layouts, route groups]
- Dynamic routes: [FILL: Patterns used — [slug], [...catchAll], etc.]
- Middleware: [FILL: What middleware does — auth checks, redirects, i18n]

## Server vs Client Components
- Default rendering: [FILL: Server Components by default? Client-heavy?]
- `"use client"` boundary rules: [FILL: Where client boundaries live]
- [FILL: Any patterns for mixing server/client — e.g., passing server data as props]

## Data Fetching
- Strategy: [FILL: fetch in Server Components / Route Handlers / SWR / React Query]
- Caching: [FILL: revalidate intervals, on-demand revalidation, cache tags]
- Loading states: [FILL: loading.tsx, Suspense boundaries, skeleton patterns]

## Project Conventions
- File naming: [FILL: kebab-case dirs? collocated components?]
- Route organization: [FILL: Route groups like (auth), (dashboard), etc.]
- API routes location: [FILL: app/api/ structure or separate backend]
[FILL: Any other project-specific Next.js conventions]

## Key Constraints
- [FILL: Dos and don'ts specific to how this project uses Next.js]
- [FILL: Performance budgets, bundle size limits]
- [FILL: SSR vs CSR decisions and why]

## Where to Look
- Configuration: [FILL: Path to next.config.js / next.config.mjs]
- Layouts: [FILL: Path to root and nested layouts]
- Middleware: [FILL: Path to middleware.ts]
- Types/interfaces: [FILL: Path to type definitions]
- Examples: [FILL: Path to a well-structured route to use as reference]
- Docs: https://nextjs.org/docs

## Environment & Config
- Environment variables: [FILL: .env files, NEXT_PUBLIC_ prefix usage]
- Image optimization: [FILL: next/image config, allowed domains]
- Redirects/rewrites: [FILL: Any configured in next.config]

## Common Pitfalls
- [FILL: Things discovered during development that weren't obvious]
- [FILL: Hydration mismatches encountered and how they were resolved]
- [FILL: Edge runtime gotchas if applicable]
