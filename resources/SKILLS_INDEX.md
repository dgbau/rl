# Skills Index

A catalog of all available skill templates with descriptions, categories, and detection signals.

## Workflow Skills (Always Installed)

| Skill | Description |
|-------|-------------|
| `ralph-workflow` | Core loop orchestration — modes, state management, decision tree |
| `backpressure` | Quality gate — lint, test, build verification before commits |
| `ticket-management` | tk CLI usage — ticket lifecycle, creation, querying |
| `self-update` | rl update procedure — what changes, what's preserved |
| `github-pr-review` | PR review handling — triage, respond, verify |
| `code-quality` | Universal code best practices — SOLID, clean architecture, naming |
| `security` | OWASP Top 10 as actionable rules — input validation, auth, secrets |
| `ui-ux` | Universal design principles — accessibility, color, typography, responsive |
| `api-design` | REST/GraphQL conventions — endpoints, errors, versioning, idempotency |
| `testing-principles` | Test pyramid, AAA pattern, mocking discipline, CI requirements |
| `observability` | Logging, metrics, tracing — three pillars, structured logging, alerting |
| `data-integration` | External API consumption — retry, caching, circuit breakers, webhooks |
| `react-patterns` | React design principles — hooks, state, composition, rendering optimization |
| `nextjs-patterns` | Next.js App Router — RSC, routing, caching, Server Actions, middleware |
| `nx` | Nx monorepo tooling — task orchestration, caching, affected, code generation |

## Language Templates

| Template | Detection Signal | Description |
|----------|-----------------|-------------|
| `go` | `go.mod` | Go conventions — gofmt, error handling, concurrency, table-driven tests |
| `rust` | `Cargo.toml` | Rust patterns — ownership, Result/thiserror/anyhow, traits, unsafe isolation |
| `python` | `pyproject.toml`, `setup.py` | Python practices — uv/ruff/mypy/pytest, src layout, type annotations |
| `jvm` | `build.gradle*`, `pom.xml`, `build.sbt` | Java/Kotlin/Scala — build systems, frameworks, testing |
| `c-cpp` | `CMakeLists.txt`, `meson.build` | C/C++ — build systems, sanitizers, memory safety, linting |
| `swift-ios` | `*.xcodeproj`, `Package.swift` | Swift & iOS — SwiftUI, UIKit, SwiftData, concurrency, App Store deployment |
| `audio-plugin` | JUCE, `nih-plug`, `iPlug2` in project | Audio plugin dev — VST3/AU/CLAP, real-time DSP, parameter management, distribution |

## Technology Templates

| Template | Detection Signal | Description |
|----------|-----------------|-------------|
| `nextjs` | `next` in deps | Next.js App Router, RSC, SSR/SSG, middleware, caching |
| `react` | `react` in deps | React patterns, hooks, state management, component design |
| `tailwind` | `tailwindcss` in deps | Tailwind CSS utility classes, config, responsive, dark mode |
| `auth` | — | Authentication strategy, token handling, protected routes |
| `auth-self-hosted` | — | Lucia, Auth.js, Ory, Keycloak, Better Auth comparison |
| `auth-providers` | — | Clerk, Supabase Auth, Firebase Auth, Auth0 comparison |
| `api-layer` | — | Project-specific API configuration, clients, middleware |
| `database` | — | Database choice, ORM, migrations, query patterns |
| `testing-strategy` | — | Project-specific test tooling, runners, configuration |
| `deployment` | — | CI/CD, hosting, environment management |
| `mobile` | — | React Native / mobile-specific patterns |
| `canvas` | — | Canvas API, requestAnimationFrame, HiDPI, hit testing |
| `data-visualization` | `d3`, `recharts`, `echarts` | Chart libraries, responsive charts, accessible visualization |
| `blockchain` | `wagmi`, `viem` | Solidity, smart contracts, wallet integration, gas optimization |
| `webgpu` | — | WGSL shaders, compute/render pipelines, progressive enhancement |
| `ecommerce` | — | Cart/checkout, inventory, order lifecycle, PCI compliance |
| `cms` | `@payloadcms/*` | Content modeling, rich text, preview, media, webhooks |
| `infrastructure` | — | Edge/CDN, WAF, DNS, caching layers, SSL, IaC |
| `realtime` | `socket.io`, `ably` | WebSocket/SSE, connection lifecycle, presence, scaling |
| `matrix-synapse` | — | Matrix protocol, federation, E2EE, bridges, Element |
| `notifications` | — | Push notifications, in-app, email routing, batching |
| `stripe` | `stripe` in deps | Checkout/Elements/Payment Intents, webhooks, subscriptions |
| `shopify` | `@shopify/*` in deps | Hydrogen, Storefront API, Admin API, Liquid themes |
| `cloudflare` | — | Workers, Pages, R2, D1, KV, Turnstile, Zero Trust |
| `python-ai-ml` | `torch`, `tensorflow`, `sklearn` | ML/AI pipelines, CV, data analysis, model training/deployment |
| `raspberry-pi` | — | GPIO, sensors, touchscreen UI, camera, motors, kiosk deployment |

## Stack Templates

| Template | Detection Signal | Description |
|----------|-----------------|-------------|
| `stack-nextjs-payload` | `next` + `@payloadcms/*` | Payload 3.0 in /app, CSS conflicts, live preview, revalidation |
| `stack-t3` | `next` + `@trpc/*` + `prisma` | tRPC + Prisma + Tailwind + Auth.js, type-safe end-to-end |
| `stack-gotth` | `go.mod` + templ + htmx | Go + Templ + Tailwind + HTMX, server-authoritative UI |
| `stack-rust-axum` | `Cargo.toml` + axum | Axum + SQLx + Tower, compile-time SQL, middleware layering |
| `stack-custom` | — | Universal catch-all for any tech combination |

## Tool Recommendations by Use-Case

### Authentication

| Use Case | Recommended | Why |
|----------|-------------|-----|
| Self-hosted, lightweight | Better Auth | TypeScript-first, plugin system, actively maintained |
| Self-hosted, enterprise | Ory (Kratos+Hydra) | OIDC/SAML, Docker-native, open source |
| Next.js specific | Auth.js v5 | First-party Next.js support, many providers |
| Fastest to ship | Clerk | Prebuilt components, managed infrastructure |
| Supabase ecosystem | Supabase Auth | Tight PostgreSQL+RLS integration |

### Data Visualization

| Use Case | Recommended | Why |
|----------|-------------|-----|
| Quick dashboards (React) | Recharts | JSX API, minimal setup |
| Custom/bespoke charts | D3.js or Visx | Maximum control, SVG primitives |
| Large datasets, streaming | Apache ECharts | Canvas renderer, built-in streaming |
| Exploratory / notebook-style | Observable Plot | Concise API, D3 team backing |

### Real-time Communication

| Use Case | Recommended | Why |
|----------|-------------|-----|
| Chat / messaging | Matrix (Synapse) | Federation, E2EE, rich ecosystem |
| Notifications + presence | Socket.IO or Ably | Simple pub/sub, managed option |
| Video/audio | LiveKit | Open source, WebRTC, scalable |
| Collaborative editing | Liveblocks or Yjs | CRDT-based, real-time sync |

### Payments

| Use Case | Recommended | Why |
|----------|-------------|-----|
| Custom checkout | Stripe Payment Intents | Full control, global coverage |
| Quick checkout | Stripe Checkout | Hosted, PCI compliant |
| Marketplace | Stripe Connect | Multi-party payments |
| Shopify storefront | Hydrogen + Storefront API | Official React framework |

### Deployment / Edge

| Use Case | Recommended | Why |
|----------|-------------|-----|
| Edge compute + CDN | Cloudflare Workers + Pages | Global, fast, integrated |
| Full-stack hosting | Vercel or Railway | Git-push deploy, preview URLs |
| Container orchestration | Docker + Fly.io or Railway | Simple Dockerfile deploys |
| Enterprise / multi-cloud | AWS CDK or Pulumi | IaC, full control |

### Databases

| Use Case | Recommended | Why |
|----------|-------------|-----|
| PostgreSQL + type safety | Drizzle ORM or Prisma | Schema-first, migrations, type generation |
| Edge/embedded | SQLite (Turso, D1) | Low latency, no server, replicated |
| Document store | MongoDB with Mongoose | Flexible schema, rapid prototyping |
| Real-time + auth | Supabase (PostgreSQL) | RLS, real-time subscriptions, auth built-in |
| Graph data | Neo4j or Dgraph | Relationship-heavy domains |

### Testing

| Use Case | Recommended | Why |
|----------|-------------|-----|
| Unit + integration (JS/TS) | Vitest | Fast, ESM-native, Jest-compatible API |
| E2E (web) | Playwright | Cross-browser, auto-wait, codegen |
| API testing | Hurl or Bruno | Declarative HTTP testing, CI-friendly |
| Property-based | fast-check (JS), Hypothesis (Py) | Edge case discovery, invariant testing |
| Component testing | Storybook + Testing Library | Visual + interaction testing |
