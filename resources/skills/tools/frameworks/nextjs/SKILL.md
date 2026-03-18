# Next.js Patterns — Core Design Principles & Best Practices

<!-- category: universal -->

## Overview

Comprehensive Next.js App Router patterns, conventions, and best practices. This is a core skill (always installed) that covers universal Next.js knowledge. The `nextjs` template skill covers project-specific configuration.

## App Router Architecture

### Server Components (default)
- Every component is a Server Component unless you add `'use client'`
- Server Components can: `async/await`, direct database access, read files, use secrets
- Server Components cannot: `useState`, `useEffect`, event handlers, browser APIs
- Server Components render once on the server — zero JavaScript shipped to client

### Client Components (`'use client'`)
- Required for: interactivity, hooks, browser APIs, event handlers, third-party client libraries
- The `'use client'` directive marks the **boundary** — everything imported by a Client Component is also client
- Push `'use client'` as far down the tree as possible — keep most of the app server-rendered

### Composition pattern (critical)
```
// ServerPage.tsx (Server Component — no directive)
import { InteractiveWidget } from './InteractiveWidget'  // client

export default async function Page() {
  const data = await db.query(...)  // server-only
  return (
    <main>
      <h1>{data.title}</h1>           {/* server-rendered */}
      <InteractiveWidget data={data} /> {/* client boundary */}
    </main>
  )
}
```

Pass server data DOWN to client components as serializable props. Never import a Server Component into a Client Component — pass it as `children` instead.

## Routing

### File conventions
| File | Purpose |
|------|---------|
| `page.tsx` | Route UI (the page itself) |
| `layout.tsx` | Shared UI wrapping child routes — persists across navigations, does NOT re-render |
| `loading.tsx` | Instant loading UI (Suspense boundary) shown while `page.tsx` loads |
| `error.tsx` | Error boundary wrapping the route segment |
| `not-found.tsx` | 404 UI for the route segment |
| `route.ts` | API endpoint (GET, POST, PUT, DELETE handlers) |
| `template.tsx` | Like layout but re-renders on every navigation (rare) |

### Route groups and parallel routes
- `(group)` — organize routes without affecting URL: `(marketing)/about/page.tsx` → `/about`
- `@slot` — parallel routes for modals, split views, conditional rendering
- `[param]` — dynamic segments: `[id]/page.tsx`, access via `params.id`
- `[...slug]` — catch-all: matches `/a`, `/a/b`, `/a/b/c`
- `[[...slug]]` — optional catch-all: also matches `/`

### Layouts vs templates
- **Layouts**: Persist across navigations, maintain state (navigation bar, sidebar)
- **Templates**: Re-mount on every navigation, reset state (entry animations, per-page analytics)
- Default to layouts. Use templates only when you need a fresh instance per navigation

## Data Fetching

### Server Components (preferred)
- Fetch directly in Server Components with `async/await` — no hooks, no client-side state
- Next.js automatically deduplicates `fetch()` calls with the same URL and options
- Use `cache()` from React for database queries and other non-fetch data sources

### Caching layers
| Layer | What | How | Default |
|-------|------|-----|---------|
| Request memoization | Duplicate `fetch()` in same render | Automatic dedup | On |
| Data cache | `fetch()` responses | `next: { revalidate: N }` | On (static) |
| Full route cache | Rendered HTML + RSC payload | Static vs dynamic detection | Static routes cached |
| Router cache | Client-side route cache | Prefetching + navigation | 30s dynamic, 5min static |

### Revalidation strategies
- **Time-based**: `fetch(url, { next: { revalidate: 60 } })` — stale after 60 seconds
- **On-demand**: `revalidatePath('/blog')` or `revalidateTag('posts')` — triggered by webhook/mutation
- **Opt out**: `{ cache: 'no-store' }` or `export const dynamic = 'force-dynamic'`

### When to use what
- **Static data**: Default caching, revalidate on deploy or with ISR
- **User-specific data**: `cookies()`, `headers()` — automatically makes route dynamic
- **Real-time data**: Client-side fetching with TanStack Query + SWR, or Server-Sent Events
- **Mutations**: Server Actions (form submissions, data changes)

## Server Actions

- Define with `'use server'` — either at top of file or inline in a function
- Can be called from Client Components as form actions or `onClick` handlers
- Always validate input — Server Actions are public HTTP endpoints
- Use `revalidatePath` / `revalidateTag` after mutations to update cached data
- Return typed responses: `{ success: true, data }` or `{ error: 'message' }`
- Use `useActionState` (React 19) for pending/error states in forms
- Use `useOptimistic` for instant UI feedback while the action completes

## Middleware

- `middleware.ts` at the project root — runs on EVERY request before routing
- Use for: auth redirects, geo-based routing, A/B testing, request logging, header manipulation
- Keep middleware fast — it runs on the Edge Runtime (limited Node.js APIs)
- Do NOT use for: heavy computation, database queries, complex auth logic (use route handlers instead)
- Matcher config: `export const config = { matcher: ['/dashboard/:path*', '/api/:path*'] }`

## Rendering Strategies

| Strategy | When | How |
|----------|------|-----|
| **Static (SSG)** | Content rarely changes | Default for routes with no dynamic data |
| **ISR** | Content changes periodically | `revalidate: N` on fetch or route segment |
| **Dynamic (SSR)** | Every request unique | `cookies()`, `headers()`, `searchParams`, `{ cache: 'no-store' }` |
| **Streaming** | Large pages with slow sections | `loading.tsx` or `<Suspense>` boundaries |
| **Client** | Highly interactive, user-specific | `'use client'` + client-side fetching |

### Streaming and Suspense
- Wrap slow data-fetching components in `<Suspense fallback={<Skeleton />}>`
- Next.js streams HTML progressively — fast parts appear immediately
- Use `loading.tsx` for route-level loading states (creates automatic Suspense boundary)
- Nest Suspense boundaries: outer for layout, inner for individual data sections

## API Routes (Route Handlers)

- `app/api/*/route.ts` — export named functions: `GET`, `POST`, `PUT`, `DELETE`
- Return `NextResponse.json()` for JSON responses
- Use for: webhooks, third-party API proxying, file uploads, OAuth callbacks
- Prefer Server Actions over API routes for form submissions and mutations
- API routes are NOT cached by default (unlike page routes)

## Performance

### Bundle optimization
- Dynamic imports: `const Modal = dynamic(() => import('./Modal'))` — code-split heavy components
- `next/image`: Always use for images — automatic optimization, lazy loading, responsive sizing
- `next/font`: Load fonts with zero layout shift — `next/font/google` or `next/font/local`
- `next/script`: Control third-party script loading (`beforeInteractive`, `afterInteractive`, `lazyOnload`)

### Core Web Vitals
- **LCP** (Largest Contentful Paint): Prioritize above-fold images with `priority` prop on `<Image>`
- **CLS** (Cumulative Layout Shift): Set width/height on images, use `next/font`, avoid dynamic content insertion
- **INP** (Interaction to Next Paint): Keep Client Components small, defer non-critical JS, use `useTransition`

## Environment Variables

- `NEXT_PUBLIC_*` — exposed to browser AND server (public values only — never secrets)
- All others — server-only (Server Components, API routes, Server Actions)
- Validate with `@t3-oss/env-nextjs` or manual checks in a central config file
- Never use `process.env` directly in Client Components — access via `NEXT_PUBLIC_*` or Server Actions

## Common Patterns

### Authentication
- Check auth in `middleware.ts` for route protection (redirect unauthenticated users)
- Access session in Server Components via `cookies()` — no client-side overhead
- Pass user data down as props, not via client-side context (reduces client JS)

### SEO
- `export const metadata` or `generateMetadata()` in `layout.tsx` / `page.tsx`
- Structured data with `<script type="application/ld+json">`
- `sitemap.ts` and `robots.ts` for search engine configuration
- `opengraph-image.tsx` for dynamic OG images

### Error handling
- `error.tsx` at each route segment — catches rendering and data fetching errors
- `global-error.tsx` at app root — catches errors in root layout
- `notFound()` function to trigger the nearest `not-found.tsx`
- Server Actions: return error objects, don't throw (throws break the client-side form state)

## Related Skills

- `nextjs` — project-specific Next.js configuration (template)
- `react-patterns` — React fundamentals and patterns
- `tailwind` — styling patterns commonly used with Next.js
- `api-design` — REST/GraphQL API conventions
- `testing-principles` — testing Next.js applications
