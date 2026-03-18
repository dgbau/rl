# Next.js + Payload CMS Stack Skill

<!-- category: stack -->

## Overview
Payload 3.0 embeds directly inside a Next.js App Router application, sharing the
same `/app` directory, server components, and deployment pipeline. This eliminates
the need for a separate CMS server but introduces integration concerns around
styling, routing, and type sharing.
[FILL: How Payload is integrated in THIS project -- version, content types, admin route]

## Payload Embedding

- Payload lives inside the Next.js app as a plugin (not a separate process)
- Admin panel route: [FILL: e.g., /admin, /cms]
- Payload config location: [FILL: Path to payload.config.ts]
- Database adapter: [FILL: postgres / mongodb / sqlite]

## Styling & Tailwind Conflicts

- **Problem**: Tailwind's Preflight CSS resets conflict with Payload's admin UI
- **Solution**: Split stylesheets -- load Tailwind only on frontend routes, exclude
  it from the Payload admin route group
- Approach: [FILL: Route group (admin) with separate layout excluding Tailwind, or
  Tailwind `important` selector scoping]
- Dark mode: Use `data-theme` attribute, not Tailwind's `dark:` class, for Payload
  compatibility

## Rich Text & Custom Blocks

- Rich Text editor: [FILL: Lexical (default in 3.0) or Slate]
- Custom blocks: [FILL: List of custom block types -- e.g., CalloutBlock, CodeBlock]
- Block component location: [FILL: Path to block components]
- Serialization: Rich Text is stored as JSON; use Payload's `RichText` component
  or a custom serializer for frontend rendering

## Data Fetching & Revalidation

- **Local API** (preferred for server components): Direct DB access, no HTTP overhead,
  full TypeScript return types -- use `getPayload()` then `payload.find()`
- **REST API**: Use for external consumers or client components
- On-demand revalidation: Call `revalidateTag()` or `revalidatePath()` from Payload
  hooks (afterChange, afterDelete)
- [FILL: Caching strategy -- ISR intervals, cache tags per collection]

## Live Preview

- Payload's live preview sends draft data to the frontend in real time
- Configure `livePreview` in collection configs with target URL
- [FILL: Which collections have live preview enabled]
- Requires a client component wrapper to receive preview data via `postMessage`

## Shared Types

- Payload auto-generates TypeScript types from collection/global configs
- Generated types location: [FILL: Path to generated types, e.g., payload-types.ts]
- Import and reuse these types across frontend components -- never redefine manually
- Run `payload generate:types` after schema changes

## Admin Route Protection

- Payload has its own auth system (admin users collection)
- [FILL: How admin auth integrates with frontend auth -- shared users or separate]
- Protect admin routes via Payload's access control functions, not Next.js middleware
- [FILL: Access control pattern -- role-based, field-level, collection-level]

## Migration Patterns

- Payload uses Drizzle ORM under the hood (Postgres adapter) or Mongoose (MongoDB)
- Migrations: `payload migrate:create` to generate, `payload migrate` to run
- [FILL: Migration workflow -- auto-run on deploy, manual approval, etc.]

## Project Conventions

- [FILL: Collection naming conventions -- singular/plural, casing]
- [FILL: Hook organization -- collocated with collections or centralized]
- [FILL: Seed data strategy for development]

## Where to Look

- Payload config: [FILL: Path to payload.config.ts]
- Collections: [FILL: Path to collection definitions]
- Globals: [FILL: Path to global definitions]
- Custom components: [FILL: Path to admin UI customizations]
- Frontend rendering: [FILL: Path to page components that consume Payload data]
- Docs: https://payloadcms.com/docs

## Common Pitfalls

- Importing Payload server code in client components causes build failures
- Tailwind preflight breaking Payload admin is the #1 integration issue
- [FILL: Project-specific gotchas encountered]
- Hot reload can be slow when Payload re-initializes; use `PAYLOAD_DROP_DATABASE=true` sparingly
