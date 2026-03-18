# Auth Provider (Managed) Skill

<!-- category: template -->

## Overview
Managed authentication providers handle user identity, session management, and
security infrastructure as a service. You integrate their SDK/API rather than
running your own auth server. Choose based on developer experience, pricing model,
compliance needs, and acceptable vendor lock-in.
[FILL: Which provider is used in THIS project and why]

## Provider Comparison

| Provider       | Strength                    | Pricing Model         | Lock-in Risk |
|----------------|-----------------------------|-----------------------|--------------|
| Clerk          | DX, prebuilt components     | Per MAU (free tier)   | Medium       |
| Supabase Auth  | PostgreSQL-native, RLS      | Per MAU (generous free)| Low-Medium  |
| Firebase Auth  | Google ecosystem, scale     | Free to 50K MAU       | High         |
| Auth0          | Enterprise, SAML, SCIM      | Per MAU (expensive)   | Medium-High  |

## Decision Criteria

- **Best developer experience**: Clerk (prebuilt UI, React hooks, webhook-driven)
- **PostgreSQL-first + RLS**: Supabase Auth (row-level security out of the box)
- **Google Cloud ecosystem**: Firebase Auth (tight integration with Firestore, Functions)
- **Enterprise compliance (SAML, SCIM)**: Auth0 (or Clerk Enterprise)
- **Budget-sensitive**: Supabase (most generous free tier) or Firebase
- [FILL: Decision rationale for this project's choice]

## Clerk

- Prebuilt UI components: `<SignIn />`, `<SignUp />`, `<UserButton />`, `<UserProfile />`
- React hooks: `useUser()`, `useAuth()`, `useSession()`
- Webhook-driven architecture: User events (created, updated, deleted) sent to your
  backend via webhooks -- use Svix for signature verification
- Organizations and roles built in
- Backend verification: `clerkClient.verifyToken()` or middleware
- Next.js: `@clerk/nextjs` with middleware for route protection
- [FILL: Clerk features used -- organizations, custom claims, webhooks]
- Docs: https://clerk.com/docs

## Supabase Auth

- Built on PostgreSQL's Row-Level Security (RLS) -- auth policies live in the database
- `supabase.auth.signUp()`, `supabase.auth.signInWithPassword()`, `supabase.auth.signInWithOAuth()`
- JWT tokens issued by Supabase, verified automatically by PostgREST
- RLS policies reference `auth.uid()` directly in SQL -- zero backend code for authorization
- Social OAuth, magic link, phone OTP out of the box
- Self-hostable (Docker) if needed
- [FILL: RLS policies defined, social providers configured]
- Docs: https://supabase.com/docs/guides/auth

## Firebase Auth

- Supports email/password, phone, Google, Apple, Facebook, GitHub, anonymous auth
- Client SDK: `signInWithEmailAndPassword()`, `signInWithPopup()`, `onAuthStateChanged()`
- Server verification: `admin.auth().verifyIdToken(idToken)`
- Tight integration with Firestore Security Rules (like Supabase RLS but for Firestore)
- Multi-factor authentication support
- **Lock-in warning**: Firebase Auth tokens are tightly coupled to Google Cloud;
  migrating away requires exporting password hashes (scrypt format)
- [FILL: Firebase services used alongside Auth -- Firestore, Functions, Hosting]
- Docs: https://firebase.google.com/docs/auth

## Auth0

- Enterprise-grade: SAML, SCIM, LDAP, Active Directory integration
- Universal Login: Hosted login page (recommended) or embedded Lock widget
- Actions: Serverless functions that run during auth flows (post-login, pre-registration)
- Machine-to-machine (M2M) tokens for service-to-service auth
- Organizations for B2B multi-tenancy
- **Pricing caution**: Gets expensive quickly past free tier (7,500 MAU free)
- [FILL: Auth0 features used -- Actions, Organizations, M2M]
- Docs: https://auth0.com/docs

## Implementation Details

- Provider: [FILL: Clerk / Supabase / Firebase / Auth0]
- SDK version: [FILL: Package version]
- Framework integration: [FILL: How it connects to your framework]
- Session strategy: [FILL: JWT, session cookie, or provider-managed]
- [FILL: Social providers enabled -- Google, GitHub, Apple, etc.]

## Route Protection

- Middleware: [FILL: How routes are protected -- middleware, layout checks, HOC]
- API protection: [FILL: How API routes verify tokens -- SDK middleware, manual verification]
- Role-based access: [FILL: How roles are defined and enforced]
- [FILL: Redirect behavior for unauthenticated users]

## Webhook Integration

- Events: [FILL: Which user events trigger webhooks -- created, updated, deleted]
- Endpoint: [FILL: Path to webhook handler]
- Signature verification: [FILL: How webhook payloads are verified]
- Database sync: [FILL: How provider user data syncs to your application database]

## Migration Considerations

When migrating between providers:

- **Password hashes**: Most providers do NOT export raw password hashes. Supabase
  and self-hosted solutions are exceptions. Plan for forced password resets.
- **OAuth connections**: Social login connections must be re-established by users
  unless you can migrate the provider-specific user IDs.
- **User IDs**: Provider-assigned IDs will change. Map old IDs to new IDs in your
  database, or use email as the stable identifier during migration.
- [FILL: Specific migration concerns for this project]

## Key Constraints

- [FILL: MAU limits and pricing tier]
- [FILL: Compliance requirements -- SOC2, HIPAA, GDPR]
- [FILL: Rate limits on auth endpoints]
- [FILL: Data residency requirements]

## Where to Look

- Auth setup: [FILL: Path to auth configuration/provider initialization]
- Protected routes: [FILL: Path to middleware or route guards]
- Webhook handler: [FILL: Path to user event webhook endpoint]
- User sync: [FILL: Path to code that syncs provider users to local DB]
- Docs: [FILL: Link to chosen provider's documentation]

## Common Pitfalls

- Clerk: Webhook events arrive asynchronously; don't assume user exists in DB immediately after signup
- Supabase: RLS policies that forget to handle service-role bypass for admin operations
- Firebase: `onAuthStateChanged` fires on page load with null before resolving user
- Auth0: Universal Login redirect can feel jarring; customization requires Actions
- [FILL: Project-specific gotchas encountered]
