# Observability — Logging, Metrics, Tracing

<!-- category: universal -->

## Overview

Universal observability principles covering the three pillars: logs (why something happened), metrics (what is happening), and traces (where it happened across services).

## Three Pillars

| Pillar | Question | Format | Tool |
|--------|----------|--------|------|
| Logs | Why did this happen? | Structured JSON events | ELK, Loki, CloudWatch |
| Metrics | What is the system doing? | Time-series numbers | Prometheus, Datadog, CloudWatch |
| Traces | Where did the request go? | Span trees across services | Jaeger, Tempo, Datadog APM |

## Structured Logging

- **Format**: JSON with consistent field names (`timestamp`, `level`, `message`, `service`, `correlationId`)
- **Correlation IDs**: Generate at system edge (API gateway, first handler); propagate through all layers and services
- **Context enrichment**: Include request method, path, user ID (hashed), response status, duration
- **Parseable output**: Logs are for machines to search and humans to read — structured first, readable second

## Log Levels

| Level | Meaning | Action | Example |
|-------|---------|--------|---------|
| ERROR | Something broke | Page on-call / investigate | Database connection failed |
| WARN | Degraded but functional | Review in next business day | Cache miss, falling back to DB |
| INFO | Significant business event | No action, audit trail | User signed up, order placed |
| DEBUG | Development detail | Never in production | SQL query text, parsed config |

## Never Log

- Passwords, tokens, API keys, session IDs
- PII (full names, emails, phone numbers, addresses) — use hashed/masked values
- Credit card numbers, SSNs, health data
- Full request/response bodies containing user data — log structure only

## Metrics

### RED Method (request-driven services)
- **Rate**: Requests per second
- **Errors**: Failed requests per second (by type)
- **Duration**: Request latency distribution (p50, p95, p99)

### USE Method (infrastructure resources)
- **Utilization**: Percentage of resource capacity used
- **Saturation**: Queue depth, backlog
- **Errors**: Error count by type

### Key Metrics
- Application: request rate, error rate, latency percentiles, active connections
- Business: sign-ups, orders, payments, conversion rates
- Infrastructure: CPU, memory, disk, network I/O

## Distributed Tracing

- **OpenTelemetry**: Use as the standard instrumentation library — vendor-neutral, wide adoption
- **Trace context propagation**: W3C `traceparent` header across HTTP, message queues, async jobs
- **Span naming**: `<operation> <resource>` (e.g., `GET /users/:id`, `query users_table`)
- **Span attributes**: Include relevant context (user ID, resource count, cache hit/miss)
- **Sampling**: Use head-based sampling in production (e.g., 10% of traces); always trace errors

## Alerting

- **Alert on symptoms**, not causes: "Error rate > 1%" not "CPU > 80%"
- **Actionable alerts only**: Every alert should have a clear runbook or investigation path
- **Severity levels**: P1 (page immediately), P2 (business hours), P3 (next sprint)
- **Avoid alert fatigue**: Tune thresholds, suppress duplicates, escalate unacknowledged

## Related Skills

- `code-quality` — logging and error handling patterns in code
- `infrastructure` — infrastructure monitoring and alerting setup
- `data-integration` — monitoring external API health
