# Next.js Skill

<!-- category: template -->

## Overview
Next.js is a React framework for building fast, server-rendered web applications with file-based routing, API routes, image optimization, and first-class Vercel deployment support. It supports multiple rendering strategies: SSR, SSG, ISR, and client-side rendering.
[FILL: How Next.js is used in this project — e.g. full-stack app, marketing site, API layer only]

## Core Setup
- Version: [FILL: Next.js version, e.g. 14.x with App Router / 13.x with Pages Router]
- Node version: [FILL: Node.js version required, e.g. 18.x]
- Configuration: [FILL: `next.config.js` / `next.config.ts` key settings — e.g. custom headers, rewrites, env vars, experimental flags]
- Environment variables: [FILL: Which `.env.*` files are used and what keys are required]
- Package manager: [FILL: npm / yarn / pnpm]

## Router & Rendering Strategy
- Router: [FILL: App Router (`app/`) or Pages Router (`pages/`)]
- Rendering: [FILL: Default rendering strategy — SSR, SSG, ISR, or hybrid; which routes use which]
- Data fetching: [FILL: How data is fetched — `fetch` with caching, React Server Components, SWR, React Query, getServerSideProps, etc.]
- Caching: [FILL: Next.js cache configuration — revalidation intervals, cache tags, opt-out patterns]

## Architecture & Patterns
[FILL: Key architectural decisions — monorepo setup, API-only usage, multi-zone, middleware strategy]
- Directory structure: [FILL: Which top-level directories exist, e.g. `app/`, `components/`, `lib/`, `public/`]
- Layouts: [FILL: How root and nested layouts are organized]
- API routes: [FILL: Where API routes live and how they are structured — `app/api/` Route Handlers or `pages/api/`]
- Middleware: [FILL: Whether `middleware.ts` is used and what it handles — auth, redirects, localization]

## Project Conventions
[FILL: Project-specific patterns, naming conventions, file locations]
- Naming: [FILL: File naming conventions — e.g. `kebab-case` for routes, `PascalCase` for components]
- Components: [FILL: Where shared components live and how they are split between server and client (`"use client"` usage policy)]
- Styles: [FILL: CSS approach — Tailwind, CSS Modules, styled-components, global CSS]
- State: [FILL: Client-side state management — Zustand, Jotai, Redux, Context, etc.]
- Auth: [FILL: Authentication approach — NextAuth.js, Clerk, custom JWT, etc.]

## Key Constraints
- [FILL: Bundle size budgets or Lighthouse score targets]
- [FILL: Which pages must be statically generated vs dynamically rendered]
- [FILL: Third-party scripts or iframes — how they are loaded to protect Core Web Vitals]
- [FILL: Security headers configured in `next.config.js` or middleware]
- [FILL: Compatibility targets — browsers, Node versions, edge runtime restrictions]

## Workflow
- Development: `[FILL: package manager] dev` — runs on `[FILL: port, e.g. 3000]`
- Building: `[FILL: package manager] build` then `[FILL: package manager] start`
- Linting: [FILL: `next lint` configuration and any custom ESLint rules]
- Type-checking: [FILL: `tsc --noEmit` or integrated into CI]
- Debugging: [FILL: How to debug — VS Code launch config, `NODE_OPTIONS='--inspect'`, React DevTools, Next.js debug mode]

## Deployment
- Platform: [FILL: Vercel / AWS / self-hosted / Docker — how the app is deployed]
- Preview environments: [FILL: How preview deployments work — Vercel preview URLs, branch deploys, etc.]
- Environment promotion: [FILL: staging → production promotion process]

## Where to Look
- Configuration: [FILL: Path to `next.config.js`, `middleware.ts`, `instrumentation.ts`]
- App source: [FILL: Path to `app/` or `pages/` directory]
- Shared components: [FILL: e.g. `src/components/`]
- API layer: [FILL: e.g. `app/api/` or `pages/api/`]
- Types/interfaces: [FILL: e.g. `src/types/`]
- Public assets: [FILL: e.g. `public/`]
- Docs: https://nextjs.org/docs

## Dependencies & Related Skills
- React skill (if present) for component patterns
- TypeScript skill (if present) for type conventions
- [FILL: CSS/styling skill — Tailwind, etc.]
- [FILL: Testing skill — Jest, Playwright, Vitest, Cypress]
- [FILL: Auth library — NextAuth, Clerk, etc.]
- [FILL: ORM or data layer — Prisma, Drizzle, tRPC, etc.]

## Common Pitfalls
- Forgetting `"use client"` on components that use browser APIs or React hooks (App Router)
- Mixing `async` Server Components with client-only hooks without a boundary
- [FILL: Project-specific gotchas discovered during development]
- [FILL: Known issues with specific Next.js version used]
- [FILL: Workarounds for third-party libraries that break SSR]