# Authentication Skill

<!-- category: template -->
<!-- SKILL TEMPLATE — Sections marked [FILL] should be populated
     with project-specific details by the ralph loop during interview
     or build mode. -->

## Overview
Authentication controls who can access the application and what they can do.
This skill covers auth strategy, token handling, session management, and authorization.
[FILL: How auth is implemented in THIS project — library, strategy, providers]

## Auth Strategy Decision Matrix

### Self-Hosted (recommended for control and privacy)
| Solution | Best For | Framework | Complexity |
|----------|----------|-----------|------------|
| Better Auth | TypeScript-first, plugins | Any TS | Low |
| Auth.js v5 | Next.js projects | Next.js | Low-Medium |
| Better Auth | TypeScript-first | Any TS | Low |
| Ory (Kratos+Hydra) | Enterprise, OIDC/SAML | Any | High |
| Keycloak | Enterprise Java, SAML+OIDC | Any | High |

### Hosted Providers (recommended for speed-to-ship)
| Provider | Best For | Key Feature |
|----------|----------|-------------|
| Clerk | Developer UX, prebuilt components | Webhook-driven, UI components |
| Supabase Auth | PostgreSQL + RLS integration | Row-level security |
| Firebase Auth | Google ecosystem | Multi-platform SDKs |
| Auth0 | Enterprise, SAML, SCIM | Extensive compliance |

- Selected approach: [FILL: Self-hosted or provider, and which one]
- Rationale: [FILL: Why this approach was chosen]

## Auth Type & Configuration
- Type: [FILL: JWT / session-based / OAuth 2.0 / magic link / passkey]
- Library: [FILL: NextAuth/Auth.js / Clerk / Lucia / custom / etc.]
- Providers: [FILL: Email+password, Google, GitHub, SSO — list all enabled]
- Session storage: [FILL: Cookie / httpOnly cookie / database-backed sessions]

## Token Handling
- Access token: [FILL: Where stored, expiry duration, refresh strategy]
- Refresh token: [FILL: Rotation policy, storage location]
- CSRF protection: [FILL: Strategy — double submit, synchronizer token, SameSite]
- [FILL: How tokens are attached to requests — Authorization header, cookie]

### Session vs JWT Tradeoffs
| Concern | Sessions | JWTs |
|---------|----------|------|
| Revocation | Immediate (delete from store) | Delayed (wait for expiry) |
| Scalability | Requires shared store | Stateless, no store needed |
| Payload | Server-side, unlimited | Client-side, keep small (<4KB) |
| Security | Server controls lifetime | Vulnerable to replay until expiry |
**Default recommendation:** Database-backed sessions for most apps. JWTs for stateless APIs or microservices.

## Passkey / WebAuthn Support
- FIDO2 / WebAuthn for passwordless authentication
- Registration: `navigator.credentials.create()` with platform authenticator
- Authentication: `navigator.credentials.get()` with challenge-response
- Libraries: SimpleWebAuthn (JS), py_webauthn (Python), webauthn-rs (Rust)
- [FILL: Whether passkeys are supported in this project and how]

## OAuth 2.0 / OIDC Flows
- **Authorization Code + PKCE**: Recommended for all client types (web, mobile, SPA)
- Never use Implicit Flow (deprecated, insecure)
- Store authorization codes server-side, exchange for tokens server-side
- Validate `id_token` signature and claims (iss, aud, exp, nonce)
- [FILL: Which OAuth providers are configured and their callback URLs]

## User Model
- Schema: [FILL: Key user fields — id, email, role, etc.]
- Roles/permissions: [FILL: RBAC or ABAC, permission model]
- Profile data: [FILL: Where profile info lives, how it's fetched]

## Protected Routes
- Route protection: [FILL: Middleware, layout-level checks, HOC, or per-page]
- Redirect behavior: [FILL: Where unauthenticated users go]
- Role-based access: [FILL: How different roles see different routes/features]
- API protection: [FILL: How API routes verify auth]

## Auth Flow
- Sign up: [FILL: Registration flow — email verification, onboarding steps]
- Sign in: [FILL: Login flow — MFA, remember me, account lockout]
- Sign out: [FILL: Logout behavior — token invalidation, redirect target]
- Password reset: [FILL: Reset flow — email, expiry]

## Key Constraints
- [FILL: Password policy — minimum length, complexity requirements]
- [FILL: MFA requirements — which accounts, which methods]
- [FILL: Compliance needs — GDPR, SOC2, HIPAA]
- [FILL: Rate limiting on auth endpoints — attempts per minute]
- Passwords: Bcrypt (cost 12+) or Argon2id — never MD5/SHA
- Sessions: httpOnly, Secure, SameSite=Lax minimum

## Where to Look
- Configuration: [FILL: Path to auth config]
- Middleware: [FILL: Path to auth middleware]
- User model: [FILL: Path to user schema/model]
- Auth pages: [FILL: Path to login/signup/reset pages]
- Types: [FILL: Path to auth type definitions]
- Docs: [FILL: Link to auth library docs]

## Common Pitfalls
- [FILL: Token expiry edge cases encountered]
- [FILL: Session synchronization across tabs]
- [FILL: OAuth callback URL mismatches between environments]
- Never store tokens in localStorage (XSS vulnerable) — use httpOnly cookies
- Always verify email before granting full access
