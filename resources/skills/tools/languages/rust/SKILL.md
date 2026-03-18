# Rust Development Skill

<!-- category: language -->

## Language & Runtime

- **Language**: Rust
- **Edition**: [FILL: 2021 or 2024]
- **MSRV**: [FILL: Minimum supported Rust version, e.g., 1.75]

## Ownership & Borrowing

- Follow borrow checker patterns; prefer borrowing over cloning
- Use lifetime elision rules — only annotate lifetimes when the compiler requires it
- Prefer `&str` over `String` in function parameters when ownership is not needed
- Use `Cow<'_, str>` when a function may or may not need to allocate

## Error Handling

- Use `Result<T, E>` for all fallible operations
- **Libraries**: Use `thiserror` to define structured error enums
- **Applications**: Use `anyhow` for ergonomic, context-rich error propagation
- Chain context with `.context("what went wrong")?`

## Pattern Matching

- Prefer `if let` for single-variant checks
- Use `while let` for consuming iterators or channels
- Ensure exhaustive matching — avoid wildcard `_` catches unless intentional

## Traits & Abstraction

- Traits are the core abstraction mechanism
- Prefer trait-based polymorphism over enum dispatch when extensibility matters
- Use `impl Trait` in argument/return position for simple cases
- Use `dyn Trait` (trait objects) when dynamic dispatch is required

## Unsafe Code

- **Minimize** unsafe blocks; isolate them into small, well-tested modules
- **Document** safety invariants with `// SAFETY:` comments above every `unsafe` block
- Prefer safe abstractions that encapsulate unsafe internals

## Testing

- Use `#[test]` attributes for unit tests in the same file
- Integration tests go in `tests/` directory
- Use `cargo test` to run the full suite
- Property-based testing with `proptest` for invariant validation

## Build & Lint

- **Format**: `cargo fmt` (always, non-negotiable)
- **Lint**: `cargo clippy` with warnings denied in CI
- **Test**: `cargo test`
- **Build**: `cargo build` (use `--release` for production)

## Nx Integration

- [FILL: project.json targets for build/test/lint, or standalone without Nx]
- If using Nx, define targets in `project.json` for `build`, `test`, and `lint`

## Common Backpressure

Run these checks before pushing or submitting a PR.

**Standalone**:

```bash
cargo fmt --check && cargo clippy -- -D warnings && cargo test && cargo build
```

**Nx**:

```bash
npx nx affected -t lint test build
```

## Notes

- [FILL: Additional project-specific Rust conventions, crate choices, or async runtime]
