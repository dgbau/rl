# API Layer Skill

<!-- SKILL TEMPLATE — Sections marked [FILL] should be populated
     with project-specific details by the ralph loop during interview
     or build mode. -->

## Overview
The API layer defines how the client and server communicate. This skill covers
the API style, endpoint conventions, validation, error handling, and
authentication integration.
[FILL: How the API is structured in THIS project — style, framework, location]

## API Style
- Type: [FILL: REST / GraphQL / tRPC / gRPC / hybrid]
- Framework: [FILL: Next.js API routes / Express / Fastify / Hono / NestJS]
- Base URL: [FILL: /api/v1, /trpc, /graphql — base path convention]
- Versioning: [FILL: URL versioning, header versioning, or none]

## Endpoint Conventions
- Naming: [FILL: RESTful resources — /users, /posts/:id — or RPC-style]
- HTTP methods: [FILL: GET/POST/PUT/PATCH/DELETE usage patterns]
- URL structure: [FILL: Nesting conventions — /users/:id/posts or flat]
- Pagination: [FILL: Cursor-based / offset-based / page-based — params used]
- Filtering: [FILL: Query parameter conventions for filtering and sorting]

## Request Handling
- Validation: [FILL: Zod / Joi / Yup / class-validator — where validation runs]
- Parsing: [FILL: How request bodies are parsed and typed]
- File uploads: [FILL: Multipart handling, size limits, storage destination]
- Rate limiting: [FILL: Strategy, limits per endpoint, library used]

## Response Format
- Success shape: [FILL: { data: T } / { result: T, meta: {} } / raw]
- Error shape: [FILL: { error: { code, message, details } } or similar]
- Status codes: [FILL: Conventions — 200 vs 201, 400 vs 422, etc.]
- Envelope: [FILL: Wrapped responses or direct data?]

## Error Handling
- Error classes: [FILL: Custom error types — NotFoundError, ValidationError]
- Global handler: [FILL: Centralized error middleware / catch-all]
- Client errors: [FILL: How 4xx errors are structured and returned]
- Server errors: [FILL: How 5xx errors are logged and masked]

## Authentication Integration
- Auth middleware: [FILL: How requests are authenticated — header, cookie, token]
- Authorization: [FILL: Role checks, permission guards per endpoint]
- Public endpoints: [FILL: Which endpoints skip auth — health, webhooks, etc.]
- [FILL: How the authenticated user is accessed in handlers]

## Type Safety
- Shared types: [FILL: Types shared between client and server — monorepo, codegen]
- Client generation: [FILL: OpenAPI codegen / tRPC inference / manual types]
- Schema source of truth: [FILL: Database schema, Zod schemas, or GraphQL SDL]

## Project Conventions
[FILL: Project-specific API patterns and conventions]
- Handler structure: [FILL: How route handlers are organized — controller pattern?]
- Middleware chain: [FILL: Order of middleware — auth, validation, logging]
- [FILL: Naming conventions for handlers, validators, transformers]

## Key Constraints
- [FILL: Response time requirements — p99 latency targets]
- [FILL: Payload size limits]
- [FILL: CORS configuration and allowed origins]
- [FILL: API documentation requirements — OpenAPI spec maintained?]

## Where to Look
- Routes: [FILL: Path to route/endpoint definitions]
- Middleware: [FILL: Path to middleware files]
- Validators: [FILL: Path to validation schemas]
- Types: [FILL: Path to API request/response types]
- Error handling: [FILL: Path to error classes and global handler]
- Examples: [FILL: Path to a well-structured endpoint to use as reference]
- Docs: [FILL: Link to API framework docs]
- API spec: [FILL: Path to OpenAPI spec or GraphQL schema if maintained]

## Common Pitfalls
- [FILL: Things discovered during development that weren't obvious]
- [FILL: Serialization edge cases — dates, BigInt, etc.]
- [FILL: Auth token propagation issues between services]
