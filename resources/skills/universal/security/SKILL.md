# Security — Universal Practices

<!-- category: universal -->

## Overview

OWASP Top 10 encoded as actionable rules. These apply to every project handling user data, network communication, or external input.

## Input Validation

- Validate all external input at system boundaries (user input, API responses, file uploads)
- Whitelist valid input rather than blacklisting bad input
- Validate type, length, range, and format — reject anything unexpected
- Never trust client-side validation alone; always re-validate server-side

## Injection Prevention

- **SQL**: Parameterized queries / prepared statements — never concatenate user input into SQL strings
- **Command injection**: Avoid spawning shell processes with user input; use structured APIs instead
- **XSS**: Escape output by default; use framework-provided sanitization (React JSX, Go html/template, etc.)
- **Path traversal**: Canonicalize paths and verify they stay within allowed directories

## Authentication

- **Password storage**: Bcrypt (cost 12+) or Argon2id — never MD5, SHA-1, or plain SHA-256
- **MFA**: Enforce for privileged accounts; support TOTP and WebAuthn/passkeys
- **Session management**: Secure, httpOnly, SameSite cookies; regenerate session ID on login
- **Brute force**: Rate limit auth endpoints, implement account lockout with exponential backoff

## Authorization

- Deny by default — explicitly grant permissions, never implicitly allow
- Check permissions server-side on every request; never trust client-side role claims
- Use principle of least privilege — grant minimum permissions needed
- Log authorization failures for audit trails

## CSRF / XSS Protection

- CSRF tokens for state-changing requests, or SameSite=Strict cookies
- Content Security Policy (CSP) headers — restrict script sources
- httpOnly cookies for session tokens — prevent JS access
- X-Content-Type-Options: nosniff — prevent MIME type sniffing

## Secrets Management

- Environment variables or secret managers (Vault, AWS Secrets Manager, Doppler) — never in source code
- Rotate secrets regularly; support rotation without downtime
- Use `.env.example` with placeholder values; never commit `.env` files
- Scan for secrets in CI (gitleaks, trufflehog)

## Dependencies

- Track vulnerabilities: `npm audit`, `cargo audit`, `pip-audit`, `safety check`, `govulncheck`
- Update promptly — especially for security patches
- Lock dependency versions (lockfiles committed)
- Review new dependencies before adding — check maintenance status, download counts, known issues

## Transport Security

- HTTPS for all endpoints — no exceptions
- HSTS headers with long max-age
- No mixed content (HTTP resources on HTTPS pages)
- TLS 1.2+ only; disable legacy protocols

## Rate Limiting

- Auth endpoints: strict limits (e.g., 5 attempts per minute per IP)
- API endpoints: per-user or per-API-key limits with clear headers
- Form submissions: prevent spam with rate limits + CAPTCHA fallback
- Return 429 with Retry-After header

## Supply Chain

- Lock dependencies and verify checksums
- Use SBOMs for production deployments
- Pin CI action versions by SHA, not tags
- Prefer well-maintained dependencies with active security response

## Related Skills

- `auth` / `auth-self-hosted` / `auth-providers` — implementation-specific auth patterns
- `code-quality` — general code hygiene supports security
- `observability` — security event logging and monitoring
