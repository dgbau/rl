# Go + Templ + Tailwind + HTMX (GOTTH) Stack Skill

<!-- category: stack -->

## Overview
The GOTTH stack is a server-authoritative web architecture: Go handles all business
logic, Templ renders type-safe HTML templates, Tailwind provides utility-first
styling, and HTMX enables dynamic interactions by swapping HTML partials over the
wire -- no client-side JavaScript framework required.
[FILL: How GOTTH is used in THIS project -- routing library, database, deployment target]

## Architecture: Server-Authoritative UI

- The server owns ALL state and rendering logic -- no client-side state management
- HTMX sends requests, server returns HTML fragments, HTMX swaps them into the DOM
- This is an intentional architectural choice: simpler mental model, better
  accessibility, faster initial page loads, zero JS bundle to manage
- [FILL: Any exceptions where client-side JS is used -- e.g., charts, maps]

## Go Handler Structure

- HTTP framework: [FILL: net/http (stdlib) / Chi / Echo / Fiber / Gin]
- Architecture: Onion / clean architecture -- handlers -> services -> repositories
- Handler pattern:
  1. Parse and validate request (form values, path params, query params)
  2. Call service layer
  3. Render Templ component and write response
- [FILL: How handlers are organized -- by domain, by route group]

```go
// Example handler pattern
func (h *Handler) CreateItem(w http.ResponseWriter, r *http.Request) {
    input := parseForm(r)        // 1. Parse
    item, err := h.svc.Create(input) // 2. Service call
    if err != nil { ... }
    components.ItemRow(item).Render(r.Context(), w) // 3. Render partial
}
```

## Templ Component Patterns

- Templ generates type-safe Go functions from `.templ` files
- Component hierarchy: layouts -> pages -> partials (for HTMX swaps)
- Always pass data as typed Go structs, never as `interface{}`
- [FILL: Path to templ components -- e.g., internal/views/ or ui/]
- Run `templ generate` after modifying `.templ` files (or use `templ generate --watch`)

## HTMX Integration

- Use `hx-get`, `hx-post`, `hx-put`, `hx-delete` for AJAX requests
- Target elements with `hx-target` and `hx-swap` (innerHTML, outerHTML, beforeend, etc.)
- Return **HTML partials** from handlers, not JSON
- Detect HTMX requests server-side: check `HX-Request` header to decide between
  full page render vs partial render
- Real-time updates: Use `hx-ws` (WebSocket) or `hx-sse` (Server-Sent Events)
- [FILL: Which real-time patterns are used and where]

## CSRF Protection

- **Important**: Do NOT rely on framework-built-in CSRF if using Fiber (it has known
  issues with HTMX). Use `gorilla/csrf` middleware instead.
- Include CSRF token in HTMX requests via `hx-headers` or a meta tag
- [FILL: CSRF strategy used -- gorilla/csrf, custom middleware, double-submit cookie]

## Tailwind Build Integration

- Tailwind scans `.templ` files for class names
- `tailwind.config.js` content paths must include `**/*.templ`
- Build pipeline: `templ generate` -> `tailwindcss -i input.css -o output.css` -> `go build`
- [FILL: Asset pipeline -- embedded via go:embed, served from /static, or CDN]
- [FILL: Path to Tailwind config and input/output CSS]

## Project Layout

```
cmd/
  server/main.go       # Entrypoint
internal/
  handler/             # HTTP handlers grouped by domain
  service/             # Business logic
  repository/          # Database access
  views/
    layouts/           # Base layouts (head, nav, footer)
    pages/             # Full page templates
    partials/          # HTMX-swappable fragments
    components/        # Reusable UI pieces
static/                # CSS output, favicon, images
```
[FILL: Actual project layout and any deviations]

## Development Workflow

- Use `air` for Go hot reload + `templ generate --watch` + Tailwind `--watch`
- [FILL: Single command to start dev -- Makefile target, Taskfile, or Procfile]
- [FILL: How to run all three watchers concurrently]

## Key Constraints

- Never return JSON from handlers unless building an explicit API endpoint
- All form handling should use progressive enhancement (works without JS)
- [FILL: Performance requirements, database choice, caching strategy]

## Where to Look

- Handlers: [FILL: Path to handler package]
- Templates: [FILL: Path to templ files]
- Static assets: [FILL: Path to CSS and static files]
- Tailwind config: [FILL: Path to tailwind.config.js]
- Docs: https://templ.guide, https://htmx.org/docs

## Common Pitfalls

- Forgetting to run `templ generate` after template changes (stale output)
- Tailwind not detecting classes in `.templ` files (check content config)
- HTMX swap targeting wrong element (use browser dev tools network tab to debug)
- [FILL: Project-specific gotchas encountered]
