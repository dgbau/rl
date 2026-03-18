# Code Quality — Universal Best Practices

<!-- category: universal -->

## Overview

Language-agnostic principles for writing clean, maintainable, correct code. These apply to every file in every project.

## SOLID Principles

- **Single Responsibility**: Each module/function/class has one reason to change
- **Open/Closed**: Extend through composition and interfaces, not modification of existing code
- **Liskov Substitution**: Subtypes must be substitutable for their base types without breaking behavior
- **Interface Segregation**: Many small interfaces over one large one — clients shouldn't depend on methods they don't use
- **Dependency Inversion**: Depend on abstractions, not concretions; core domain has no external dependencies

## Clean Architecture

- **Hexagonal / ports-and-adapters**: Core domain defines interfaces (ports), infrastructure implements them (adapters)
- **Dependency direction**: Always inward — handlers → services → domain; never domain → infrastructure
- **No framework coupling in domain**: Business logic must be testable without HTTP, databases, or frameworks

## Functions & Methods

- Small, single-purpose — if you need a comment to explain a section, extract it
- Max 2-3 parameters; group related params into a struct/object
- Minimize side effects; prefer pure functions where possible
- Return early to avoid deep nesting

## Naming

- Intent-revealing names — a reader should understand purpose without reading the body
- Consistent vocabulary: pick one term per concept and use it everywhere (e.g., `fetch` vs `get` vs `retrieve` — choose one)
- No abbreviations except universally understood ones (`id`, `url`, `http`)
- Booleans: `is_`, `has_`, `can_`, `should_` prefixes

## DRY Threshold

- **Rule of Three**: Tolerate two duplications; abstract on the third occurrence
- Premature abstraction is worse than duplication — wait for the pattern to stabilize
- When abstracting, the shared code must represent a single concept, not just textual similarity

## Error Handling

- Fail fast at system boundaries (user input, API responses, file I/O)
- Use structured error types with context (what failed, why, what to do)
- Never swallow errors silently — log or propagate
- Distinguish recoverable errors (retry, fallback) from fatal errors (crash with context)

## Logging

- Structured format (JSON) with consistent field names
- Include correlation/request IDs on every log entry
- Never log secrets, tokens, passwords, PII, or credit card numbers
- Log levels: ERROR (action required), WARN (degraded), INFO (significant events), DEBUG (development only)

## Performance

- Measure before optimizing — profile first, then fix the bottleneck
- Database queries are usually the bottleneck, not application code
- Prefer batch operations over N+1 patterns
- Cache at the right layer (HTTP, application, database)

## Related Skills

- `testing-principles` — how to verify code quality
- `security` — security-specific code patterns
- `observability` — logging and monitoring in depth
