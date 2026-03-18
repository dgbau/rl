# Cloudflare Skill

<!-- category: template -->

## Overview
Cloudflare provides edge compute, storage, security, and networking services.
Beyond CDN and DNS, the platform offers a full application stack: Workers for
compute, D1/KV/R2 for storage, and Zero Trust for access control. Wrangler CLI
is the unified tool for development and deployment.
[FILL: Which Cloudflare services are used in THIS project and their roles]

## Workers (Edge Compute)

- V8 isolates (not Node.js) -- lightweight, fast cold starts (~0ms)
- Limits: 10ms CPU per invocation (free), 30s (paid); 128MB memory
- No `fs`, `net`, or native Node.js modules -- use Web APIs (fetch, crypto, streams)
- Workers can serve full applications, API endpoints, or act as middleware
- Service bindings: Workers can call other Workers internally (zero network hop)
- Cron Triggers: Schedule Workers via cron expressions
- [FILL: Workers in this project -- name, purpose, routes]
- [FILL: Runtime compatibility -- Node.js compat flag enabled?]

## Pages (Static + SSR)

- Deploys static sites and full-stack frameworks (Next.js, Remix, Astro, SvelteKit)
- Automatic preview deployments per git branch
- `_worker.js` or framework adapter for SSR
- Functions: `functions/` directory for API routes (runs on Workers)
- [FILL: Framework deployed on Pages, build command, output directory]

## Storage Services

### R2 (S3-Compatible Object Storage)
- S3-compatible API -- use existing AWS SDK with R2 endpoint
- Zero egress fees (major cost advantage over S3)
- Bind to Workers via `R2Bucket` binding
- [FILL: R2 usage -- uploads, assets, backups]

### D1 (SQLite at the Edge)
- SQLite database replicated globally at the edge
- Bind to Workers via `D1Database` binding
- Migrations via `wrangler d1 migrations`
- Not suitable for write-heavy workloads (single writer, globally replicated reads)
- [FILL: D1 databases, schema, migration strategy]

### KV (Key-Value Store)
- Eventually consistent, global key-value store
- Optimized for read-heavy workloads (reads are fast, writes propagate in ~60s)
- Good for: configuration, feature flags, cached data, session storage
- Not good for: real-time data, counters, transactions
- [FILL: KV namespaces, what data is stored]

## Security Services

### Turnstile (CAPTCHA Alternative)
- Privacy-preserving alternative to reCAPTCHA
- Invisible or managed widget modes
- Server-side verification: POST to `https://challenges.cloudflare.com/turnstile/v0/siteverify`
- [FILL: Where Turnstile is used -- forms, login, signup]

### WAF (Web Application Firewall)
- Managed rulesets: OWASP Core Ruleset, Cloudflare Managed Rules
- Custom rules: Block by IP, country, ASN, user agent, URI path, request headers
- Rate limiting rules: Threshold-based blocking per IP or custom key
- [FILL: Custom WAF rules configured]

### DDoS Protection
- Always-on L3/L4/L7 DDoS mitigation (included in all plans)
- HTTP DDoS adaptive protection auto-tunes thresholds
- [FILL: Any DDoS rule customizations or sensitivity overrides]

## Zero Trust

- **Access**: Identity-aware proxy -- protect internal apps with SSO/IdP integration
  without VPN. Users authenticate via configured identity providers.
- **Gateway**: Secure DNS and HTTP filtering for outbound traffic
- Policies: Allow/block/bypass rules based on identity, device posture, IP, geo
- Service tokens: For machine-to-machine access to protected resources
- [FILL: Zero Trust policies configured -- which apps are protected, IdP used]

## Networking

### Argo Smart Routing
- Routes traffic through Cloudflare's optimized network paths
- Reduces latency by ~30% on average (paid add-on)
- [FILL: Whether Argo is enabled]

### DNS Management
- Cloudflare as authoritative DNS (required for proxied records)
- Proxied records (orange cloud): Traffic goes through Cloudflare (CDN, WAF, DDoS)
- DNS-only records (grey cloud): Direct to origin, no Cloudflare protection
- [FILL: Key DNS records and proxy status]

### SSL/TLS Modes
- **Flexible**: CF to browser encrypted, CF to origin unencrypted (insecure)
- **Full**: Encrypted to origin but accepts self-signed certs
- **Full (Strict)**: Encrypted to origin, requires valid CA cert (recommended)
- Origin certificates: Free Cloudflare-signed certs for origin servers
- [FILL: SSL mode configured, origin certificate setup]

## Wrangler CLI

- `wrangler dev` -- local development with miniflare (local Workers runtime)
- `wrangler deploy` -- deploy Worker to Cloudflare
- `wrangler d1` -- manage D1 databases and migrations
- `wrangler r2` -- manage R2 buckets
- `wrangler pages` -- manage Pages projects
- `wrangler secret` -- manage encrypted environment variables
- [FILL: Key wrangler commands used in this project's workflow]

## Configuration

- `wrangler.toml` (or `wrangler.json`): Bindings, routes, compatibility date, env vars
- [FILL: Path to wrangler config]
- [FILL: Environment setup -- production, staging, development]

## Where to Look

- Worker source: [FILL: Path to Worker entry point -- e.g., src/index.ts]
- Wrangler config: [FILL: Path to wrangler.toml]
- D1 migrations: [FILL: Path to migrations directory]
- Pages functions: [FILL: Path to functions/ directory]
- Dashboard: https://dash.cloudflare.com
- Docs: https://developers.cloudflare.com

## Common Pitfalls

- Workers are NOT Node.js: `process`, `Buffer`, `require` don't exist (unless compat flags enabled)
- KV is eventually consistent; don't use it for real-time state
- D1 has a single write point; high write throughput causes contention
- `wrangler dev` behavior may differ from production (test on preview/staging)
- [FILL: Project-specific gotchas encountered]
