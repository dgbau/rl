# Testing Strategy Skill

<!-- SKILL TEMPLATE — Sections marked [FILL] should be populated
     with project-specific details by the ralph loop during interview
     or build mode. -->

## Overview
Testing ensures code correctness and prevents regressions. This skill covers
the testing framework, patterns, and expectations for unit, integration, and
end-to-end tests.
[FILL: Testing philosophy in THIS project — coverage goals, what gets tested]

## Test Framework
- Unit/integration: [FILL: Jest / Vitest / Node test runner]
- E2E: [FILL: Playwright / Cypress / none]
- Component testing: [FILL: React Testing Library / Storybook interaction tests]
- API testing: [FILL: Supertest / MSW / direct handler calls]

## Test Organization
- File naming: [FILL: *.test.ts / *.spec.ts / __tests__/ directory]
- Colocation: [FILL: Tests next to source or in separate test directory?]
- Directory structure: [FILL: Mirror src structure? Flat? Grouped by type?]

## Test Patterns
- Arrange/Act/Assert: [FILL: Conventions for structuring test bodies]
- Test data: [FILL: Factories, fixtures, builders — how test data is created]
- Descriptions: [FILL: Naming conventions for describe/it blocks]
- Setup/teardown: [FILL: beforeEach patterns, database cleanup approach]

## Mocking
- Strategy: [FILL: jest.mock / vi.mock / MSW / manual mocks]
- External services: [FILL: How API calls are mocked — MSW handlers, fixtures]
- Database: [FILL: In-memory DB, test database, or mocked repository]
- Time/date: [FILL: How time-dependent tests are handled]
- [FILL: What should NOT be mocked — integration boundaries]

## E2E Testing
- Framework: [FILL: Playwright / Cypress setup and config]
- Test environment: [FILL: Local dev server, staging, Docker compose]
- Authentication: [FILL: How E2E tests handle login — fixtures, API setup]
- Data seeding: [FILL: How test data is prepared for E2E runs]
- [FILL: Key user flows covered by E2E tests]

## Coverage
- Target: [FILL: Coverage percentage goal — e.g., 80% lines]
- Enforcement: [FILL: CI check, pre-commit hook, or advisory only]
- Exclusions: [FILL: Files/patterns excluded from coverage]

## Running Tests
- All tests: [FILL: Command — e.g., npm test, pnpm test]
- Single file: [FILL: Command to run one test file]
- Watch mode: [FILL: Command for watch mode during development]
- E2E: [FILL: Command to run E2E suite]
- CI: [FILL: How tests run in CI — parallel, sharded, etc.]

## Project Conventions
[FILL: Project-specific testing patterns and conventions]
- [FILL: What must be tested vs what's optional]
- [FILL: PR requirements — tests required for new features?]

## Key Constraints
- [FILL: Test performance expectations — max suite duration]
- [FILL: Flaky test policy — how they're handled]
- [FILL: Environment isolation requirements]

## Where to Look
- Configuration: [FILL: Path to test config — jest.config, vitest.config, playwright.config]
- Test utilities: [FILL: Path to shared test helpers, custom renders]
- Fixtures: [FILL: Path to test fixtures and factories]
- Mocks: [FILL: Path to mock handlers — e.g., MSW handlers]
- Examples: [FILL: Path to a well-written test to use as reference]
- Docs: [FILL: Link to test framework docs — e.g., https://vitest.dev]

## Common Pitfalls
- [FILL: Things discovered during development that weren't obvious]
- [FILL: Flaky test causes and solutions]
- [FILL: Environment-specific test failures]
