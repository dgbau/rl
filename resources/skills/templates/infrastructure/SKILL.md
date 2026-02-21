# Infrastructure & Edge Deployment

<!-- category: template -->

## Overview

Production infrastructure patterns: CDN/edge deployment, security hardening,
caching, DNS, SSL, environment management, and Infrastructure as Code.

## Edge / CDN Platform

[FILL: Cloudflare / Vercel / AWS CloudFront / Fastly / Akamai]

## Infrastructure as Code

[FILL: Terraform / Pulumi / AWS CDK / SST / CloudFormation]

- All infrastructure must be version-controlled and reproducible
- Never make manual changes to production — drift detection catches these
- Use separate state files/stacks per environment
- Pin provider versions to avoid unexpected breaking changes

## DNS Configuration

```
# Example zone records
example.com.        A       203.0.113.10
www.example.com.    CNAME   example.com.
api.example.com.    CNAME   api-lb.provider.com.
_dmarc.example.com. TXT     "v=DMARC1; p=reject; rua=mailto:dmarc@example.com"
example.com.        MX      10 mail.provider.com.
example.com.        CAA     0 issue "letsencrypt.org"
```

- Set low TTLs (60-300s) during migrations; raise (3600s+) for stable records
- Use CAA records to restrict which CAs can issue certificates
- Configure DMARC, SPF, and DKIM for email deliverability and anti-spoofing
- Use CNAME flattening (Cloudflare) or ALIAS records for apex domain CDN routing

## SSL / TLS Management

- Use automated certificates (Let's Encrypt, Cloudflare, ACM) — never manage certs manually
- Enforce HTTPS everywhere: HSTS header with `max-age=31536000; includeSubDomains; preload`
- Set minimum TLS version to 1.2; prefer 1.3
- Enable OCSP stapling for faster TLS handshakes
- Monitor certificate expiry with automated alerts (30-day and 7-day warnings)

## WAF & DDoS Protection

- Enable managed WAF rulesets (OWASP CRS) at the edge
- Rate-limit API endpoints: per-IP and per-authenticated-user
- Block known bad user agents, scanners, and geographic regions if applicable
- Configure challenge pages for suspicious traffic patterns
- Use bot management to distinguish legitimate crawlers from scrapers

```
# Example Cloudflare WAF rate-limit rule (pseudo)
rule:
  match: path starts_with "/api/"
  rate_limit: 100 requests per 60 seconds per IP
  action: challenge
```

## Caching Layers

### CDN Cache (Edge)
- Cache static assets with long TTLs: `Cache-Control: public, max-age=31536000, immutable`
- Use content hashes in filenames for cache busting (`app.a1b2c3.js`)
- Cache HTML pages at edge with short TTLs + stale-while-revalidate

### Application Cache
- Cache rendered pages or API responses in Redis/Memcached
- Use cache tags for selective invalidation
- Implement stale-while-revalidate pattern for non-critical data

### Database Cache
- Use query result caching for expensive aggregations
- Cache invalidation via event-driven triggers on write operations

## Environment Management

```
Environments:
  dev        -> feature branches, ephemeral, relaxed security
  staging    -> mirrors production config, pre-release validation
  production -> locked down, monitored, auto-scaled
```

- Use environment variables for all config; never hardcode secrets
- Store secrets in a vault (AWS Secrets Manager, HashiCorp Vault, Doppler)
- Production deploys require CI/CD pipeline — no direct pushes
- Use environment-specific domain names: `staging.example.com`, `dev.example.com`

## Monitoring & Observability

- Uptime monitoring with alerting (Pingdom, Better Uptime, Checkly)
- Error tracking (Sentry) with source maps for production debugging
- Log aggregation with structured JSON logs (Datadog, Grafana Cloud)
- Set up dashboards for: p50/p95/p99 latency, error rate, throughput, cache hit ratio

## Deployment Checklist

- [ ] All infrastructure defined in code and version-controlled
- [ ] SSL/TLS enforced with HSTS; WAF and DDoS protection active
- [ ] DNS records include CAA, SPF, DMARC, DKIM
- [ ] Caching strategy defined for each layer
- [ ] Secrets stored in vault, not in environment files
- [ ] Monitoring, alerting, and rollback procedures configured
