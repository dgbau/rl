# Database Skill

<!-- SKILL TEMPLATE — Sections marked [FILL] should be populated
     with project-specific details by the ralph loop during interview
     or build mode. -->

## Overview
The database layer handles data persistence, schema management, and query
execution. This skill covers the ORM/driver, schema conventions, migrations,
and connection management.
[FILL: How the database is used in THIS project — engine, ORM, hosting]

## Database Engine
- Engine: [FILL: PostgreSQL / MySQL / SQLite / MongoDB / etc.]
- Hosting: [FILL: Supabase / PlanetScale / Neon / Railway / self-hosted]
- ORM/Driver: [FILL: Prisma / Drizzle / Knex / TypeORM / Mongoose / raw SQL]
- Version: [FILL: Database and ORM versions]

## Schema Design
- Schema location: [FILL: Path to schema file(s) — e.g., prisma/schema.prisma]
- Naming conventions: [FILL: Table names (plural/singular), column names (snake/camel)]
- ID strategy: [FILL: UUID / auto-increment / cuid / nanoid]
- Timestamps: [FILL: createdAt/updatedAt pattern, timezone handling]
- Soft deletes: [FILL: Used? deletedAt column pattern?]

## Relationships
- [FILL: Key entity relationships — User hasMany Posts, etc.]
- Junction tables: [FILL: Many-to-many patterns used]
- Cascade rules: [FILL: Delete/update cascade policies]

## Migrations
- Tool: [FILL: Prisma migrate / Drizzle Kit / knex migrate / raw SQL]
- Workflow: [FILL: How to create, run, and rollback migrations]
- Seed data: [FILL: Seeding strategy, seed file location]
- [FILL: Migration naming conventions]

## Query Patterns
- Data access layer: [FILL: Repository pattern / service layer / direct ORM calls]
- Common queries: [FILL: Patterns for pagination, filtering, sorting]
- Transactions: [FILL: How transactions are handled]
- Raw queries: [FILL: When raw SQL is used and why]

## Connection Management
- Connection string: [FILL: Env var name — e.g., DATABASE_URL]
- Pooling: [FILL: Connection pool config, serverless considerations]
- [FILL: Multiple databases or read replicas if applicable]

## Project Conventions
[FILL: Project-specific database patterns and conventions]
- Query location: [FILL: Where database queries live in the codebase]
- Error handling: [FILL: How database errors are caught and surfaced]

## Key Constraints
- [FILL: Performance requirements — query time limits, index policies]
- [FILL: Data integrity rules — required validations before writes]
- [FILL: Backup and recovery procedures]

## Where to Look
- Schema: [FILL: Path to schema definition files]
- Migrations: [FILL: Path to migration directory]
- Seeds: [FILL: Path to seed files]
- Data access: [FILL: Path to repository/service files]
- Types/interfaces: [FILL: Path to generated or manual DB types]
- Examples: [FILL: Path to a well-structured query to use as reference]
- Docs: [FILL: Link to ORM docs — e.g., https://www.prisma.io/docs]

## Common Pitfalls
- [FILL: Things discovered during development that weren't obvious]
- [FILL: N+1 query issues encountered and how they were resolved]
- [FILL: Migration ordering or conflict issues]
