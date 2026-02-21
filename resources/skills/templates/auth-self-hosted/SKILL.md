# Self-Hosted Authentication Skill

<!-- category: template -->

## Overview
Self-hosted authentication means running your own identity and access management
infrastructure. This provides full control over user data, compliance posture,
and customization at the cost of operational responsibility. Choose based on scale,
compliance needs, and team capacity.
[FILL: Which self-hosted auth solution is used in THIS project and why]

## Solution Comparison

| Solution     | Language    | Best For                        | Complexity | Protocol Support     |
|--------------|-------------|---------------------------------|------------|----------------------|
| Better Auth  | TypeScript  | TypeScript-first, plugin system | Low-Med    | OAuth, Email, Passkey|
| Auth.js v5   | TypeScript  | Next.js / SvelteKit focused     | Low-Med    | OAuth, Credentials   |
| Ory Stack    | Go          | Enterprise, microservices       | High       | OIDC, OAuth2, SAML   |
| Keycloak     | Java        | Enterprise, legacy integration  | High       | OIDC, OAuth2, SAML   |

## Decision Criteria

- **Small project, TypeScript**: Better Auth (modern, plugin-based, actively maintained)
- **Next.js ecosystem**: Auth.js v5 (best integration, large community)
- **Multi-service architecture**: Ory Stack (dedicated identity service)
- **Enterprise with SAML/SCIM**: Keycloak or Ory Hydra
- [FILL: Decision rationale for this project's choice]

## Auth.js / NextAuth v5

- The most popular auth library for Next.js
- Built-in OAuth providers (Google, GitHub, Discord, etc.)
- Credentials provider for email/password (you handle password hashing)
- Session strategies: JWT (default, stateless) or Database (stateful)
- Edge runtime compatible with JWT strategy
- Middleware integration for route protection
- Docs: https://authjs.dev

## Better Auth

- TypeScript-first, framework-agnostic auth library
- Plugin system for extending functionality (2FA, passkeys, organizations)
- Built-in email/password, OAuth, magic link, and passkey support
- Database adapters: Prisma, Drizzle, Kysely, MongoDB
- Admin dashboard plugin for user management
- Best when: You want a batteries-included TS auth library
- Docs: https://www.better-auth.com

## Ory Stack

- **Ory Kratos**: Identity management (registration, login, account recovery, MFA)
- **Ory Hydra**: OAuth2 and OpenID Connect provider (delegate login to Kratos)
- **Ory Oathkeeper**: Identity-aware reverse proxy (access rules, token validation)
- Each component is a standalone Go binary, deployed as a service
- Configuration via YAML files, headless (you build your own login UI)
- Best when: Microservices architecture, need OAuth2 provider, compliance-critical
- Docs: https://www.ory.sh/docs

## Keycloak

- Java-based identity and access management server
- Provides full admin console, account management UI out of the box
- Supports SAML 2.0, OpenID Connect, OAuth 2.0, LDAP/AD integration
- Realm-based multi-tenancy, fine-grained authorization (policies, permissions)
- Heavy footprint (~500MB+ memory), slower startup
- Best when: Enterprise with existing Java infrastructure, need SAML
- Docs: https://www.keycloak.org/documentation

## Implementation Details

- Solution chosen: [FILL: Which solution from above]
- Version: [FILL: Version deployed]
- Deployment: [FILL: Docker, Kubernetes, embedded in app, etc.]
- Database: [FILL: Where user/session data is stored]
- [FILL: OAuth providers configured]
- [FILL: MFA strategy -- TOTP, WebAuthn, SMS]

## Session & Token Management

- Session strategy: [FILL: JWT, database sessions, or opaque tokens]
- Session duration: [FILL: Expiry time, refresh policy]
- Token storage: [FILL: httpOnly cookie, Authorization header, etc.]
- CSRF protection: [FILL: Strategy used]

## User Model & Authorization

- User schema: [FILL: Key fields -- id, email, role, emailVerified, etc.]
- Authorization: [FILL: RBAC, ABAC, or simple role checks]
- [FILL: How roles/permissions are assigned and checked]

## Where to Look

- Auth configuration: [FILL: Path to auth config file]
- User model/schema: [FILL: Path to user model or migration]
- Login/signup pages: [FILL: Path to auth UI pages]
- Middleware/guards: [FILL: Path to auth middleware or route guards]
- Docs: [FILL: Link to chosen solution's documentation]

## Migration Considerations

- Moving between solutions requires migrating the user table and password hashes
- bcrypt/argon2 hashes are generally portable between solutions
- OAuth account linkages must be re-mapped to the new provider table schema
- [FILL: Any planned migration path or lock-in concerns]

## Common Pitfalls

- Auth.js: Credentials provider doesn't support MFA out of the box
- Ory: YAML config complexity, headless UI means building every auth page
- Keycloak: Memory-hungry, theme customization is painful (FreeMarker templates)
- [FILL: Project-specific gotchas encountered]
