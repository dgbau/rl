# Data Integration — Consuming External APIs & Data

<!-- category: universal -->

## Overview

Core patterns for any project consuming external APIs, third-party data sources, or inter-service communication.

## Rate Limiting (Client-Side)

- Respect API rate limits — read documentation, honor `Retry-After` headers
- Implement client-side token bucket or sliding window to stay under limits
- Queue requests when approaching limits rather than failing
- Log rate limit events for monitoring; alert on sustained throttling

## Retry Strategy

- **Exponential backoff with jitter**: `delay = base * 2^attempt + random(0, base)`
- **Max 3 retries** for transient failures (timeouts, 502/503/504, network errors)
- **Never retry**: 400 (bad request), 401 (auth), 403 (forbidden), 404 (not found), 422 (validation)
- **Circuit breaker**: After N consecutive failures (e.g., 5), stop calling for a cooldown period; probe periodically to detect recovery

## Caching

- **HTTP cache headers**: Respect `Cache-Control`, `ETag`, `Last-Modified` from upstream
- **Application-level TTL**: Cache API responses with appropriate TTL (seconds for real-time, hours for reference data)
- **Stale-while-revalidate**: Serve cached data immediately, refresh in background — best for non-critical data
- **Cache invalidation**: Time-based (TTL), event-based (webhooks), or manual purge — pick the simplest that works

## Error Handling

- **Structured error mapping**: Convert external API errors into your domain's error types
- **Graceful degradation**: Show cached/stale data with timestamp when upstream is down
- **Fallback data**: Provide sensible defaults when non-critical data is unavailable
- **Partial failure**: If 1 of 5 API calls fails, return partial results with clear indication of what's missing

## Timeouts

- **Connection timeout**: 3-5s — fail fast if server is unreachable
- **Read timeout**: 5-10s for most APIs; longer (30s) for batch/export endpoints
- **Total request timeout**: Set a hard ceiling including retries
- Fail fast over hanging — a slow external API should not bring down your service

## Type Safety

- Generate clients from OpenAPI/Swagger specs where available (`openapi-generator`, `orval`, `openapi-ts`)
- Validate response shapes at runtime (Zod, io-ts, pydantic, serde) — external APIs can change without notice
- Version your API client types separately from your domain types
- Handle unknown/new fields gracefully — don't break on extra properties

## Monitoring

- Track per-endpoint: response time (p50, p95, p99), error rate, availability
- Set up alerts for degraded upstream services (error rate > threshold, latency spike)
- Log external API calls with correlation IDs for distributed tracing
- Dashboard showing dependency health at a glance

## Security

- API keys in environment variables — never in source code or query parameters
- OAuth scopes: request least privilege needed
- HTTPS only — reject HTTP endpoints
- Validate and sanitize data from external sources — treat as untrusted input
- Rotate API keys regularly; support rotation without downtime

## Webhook Handling

- **Verify signatures**: Validate webhook payloads using shared secrets (HMAC-SHA256)
- **Idempotency**: Handle duplicate deliveries gracefully — use event ID for deduplication
- **Async processing**: Accept webhook quickly (200 OK), process in background job
- **Retry support**: Return 2xx only after successful processing; return 5xx to trigger redelivery

## Related Skills

- `api-design` — designing APIs others consume (the other side of integration)
- `security` — secure handling of API keys and external data
- `observability` — monitoring external dependency health
