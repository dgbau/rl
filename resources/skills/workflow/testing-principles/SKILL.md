# Testing Principles — Universal Practices

<!-- category: universal -->

## Overview

Core testing philosophy and patterns. Complements the `testing-strategy` template which covers project-specific test tooling and configuration.

## Test Pyramid

- **~70% Unit tests**: Fast, isolated, test single functions/modules
- **~20% Integration tests**: Test component interactions, real databases (Testcontainers), real APIs
- **~10% E2E tests**: Critical user flows only, run in CI, max 15-minute total runtime
- When in doubt, push tests down the pyramid — faster feedback, easier debugging

## Test Naming

Use descriptive names that document behavior:
- `should_<expected>_when_<condition>` — e.g., `should_return_404_when_user_not_found`
- `given_<state>_when_<action>_then_<result>` — e.g., `given_empty_cart_when_checkout_then_error`
- Test name should read as a specification — someone should understand the requirement from the name alone

## AAA Pattern

Every test follows Arrange → Act → Assert:
- **Arrange**: Set up test data, mocks, state
- **Act**: Execute the behavior under test (one call)
- **Assert**: Verify the result (one logical assertion — multiple `expect` calls for one concept is fine)
- Keep each section visually distinct with blank lines

## Test Data

- **Factories/builders** over static fixtures — generate minimal valid data with overrides
- Each test creates its own data — no shared mutable state between tests
- Use realistic but deterministic data (seeded random, fixed timestamps)
- Test edge cases: empty strings, zero, null, max values, Unicode, special characters

## Mocking Discipline

- **Mock at boundaries only**: External APIs, file systems, clocks, random generators
- **Never mock what you own**: If you mock your own service layer, you're testing implementation, not behavior
- **Integration tests > mocks**: Use Testcontainers for real databases, MSW for HTTP mocking
- Verify mock interactions sparingly — prefer asserting on outputs over asserting mock was called

## Property-Based Testing

- Use for any function with well-defined invariants (parsers, serializers, math, sorting)
- Define properties: idempotency, round-trip, commutativity, associativity
- Let the framework generate edge cases you wouldn't think of
- Tools: Hypothesis (Python), fast-check (JS/TS), proptest (Rust), testing/quick (Go)

## Integration Tests

- Use real databases via Testcontainers or equivalent — not mocked data layers
- Each test gets a clean database state (transaction rollback or truncate)
- Test the actual query/ORM behavior, not a mock that always returns what you expect
- Test error paths: connection failures, constraint violations, timeouts

## E2E Tests

- Cover critical user flows only: sign up, sign in, core business action, payment
- Max 15-minute total runtime — slow E2E suites get ignored
- Use stable selectors (`data-testid`, roles) — never CSS classes or dynamic text
- Handle flakiness: retry network requests, wait for elements, isolate test data

## CI Requirements

- All tests must pass before merge — no exceptions, no "known failures"
- No flaky tests tolerated — quarantine and fix or delete
- Test coverage as information, not gate — 80% is a guideline, not a rigid rule
- Run fast tests first; parallelize where possible

## Related Skills

- `testing-strategy` — project-specific test tooling, runners, and configuration
- `code-quality` — code patterns that make testing easier
- `backpressure` — how tests fit into the build verification loop
