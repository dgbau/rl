# API Design — Universal Principles

<!-- category: universal -->

## Overview

Core API design patterns for REST, GraphQL, and inter-service communication. Complements the `api-layer` template which covers project-specific configuration.

## REST Conventions

- **Resource-oriented URLs**: `/users`, `/users/:id`, `/users/:id/orders` — nouns, not verbs
- **Plural nouns**: `/users` not `/user`; collection and item share the same base path
- **HTTP methods**: GET (read), POST (create), PUT (full replace), PATCH (partial update), DELETE (remove)
- **Status codes**: 200 (OK), 201 (created), 204 (no content), 400 (bad request), 401 (unauthenticated), 403 (forbidden), 404 (not found), 409 (conflict), 422 (validation), 429 (rate limit), 500 (server error)
- **Pagination**: Cursor-based preferred (`?cursor=abc&limit=20`); offset-based acceptable for small datasets

## Error Response Format

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable explanation",
    "details": [
      { "field": "email", "issue": "Invalid email format" }
    ]
  }
}
```

- Consistent structure across all endpoints
- Machine-readable `code` + human-readable `message`
- `details` array for field-level validation errors
- Never expose stack traces, internal paths, or SQL in production errors

## Versioning

- URL path versioning (`/v1/users`) — simplest, most explicit
- Header-based (`Accept: application/vnd.api.v2+json`) — cleaner URLs, harder to test
- Never break existing consumers — additive changes only within a version
- Deprecation: warn via `Sunset` header, document migration path, provide reasonable timeline

## Authentication & Authorization

- Bearer tokens in `Authorization` header — never in query parameters (logged in URLs)
- API keys for machine-to-machine; OAuth2/OIDC for user-facing
- Scoped permissions — tokens should carry minimum required access
- Short-lived access tokens + longer-lived refresh tokens

## Rate Limiting

- Include headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`
- Return `429 Too Many Requests` with `Retry-After` header
- Rate limit by API key / user / IP as appropriate
- Different tiers for different endpoint sensitivity (auth endpoints stricter)

## Idempotency

- GET, PUT, DELETE are naturally idempotent
- POST with `Idempotency-Key` header for safe retries (payment creation, order submission)
- Store idempotency results for 24h; return cached response on duplicate key
- Return 409 if key reused with different request body

## GraphQL Specifics

- **Query complexity limits**: Prevent expensive nested queries with depth/complexity analysis
- **Depth limiting**: Max query depth (typically 5-10 levels)
- **Persisted queries**: Hash-based query lookup in production to prevent arbitrary queries
- **N+1 prevention**: DataLoader pattern for batching database lookups
- **Schema design**: Connections pattern for pagination, input types for mutations

## Documentation

- OpenAPI/Swagger for REST — generate from code or maintain alongside
- GraphQL: schema introspection + descriptions on types and fields
- Include request/response examples for every endpoint
- Document error codes and their meanings
- Keep docs in sync with code — CI checks for spec drift where possible

## Related Skills

- `api-layer` — project-specific API configuration (base URLs, middleware, clients)
- `data-integration` — patterns for consuming external APIs
- `security` — API security practices (auth, rate limiting, input validation)
