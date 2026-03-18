# Go Development Skill

<!-- category: language -->

## Language & Runtime

- **Language**: Go (Golang)
- **Version**: [FILL: Go version, e.g., 1.22+]
- **Module Path**: [FILL: e.g., github.com/org/project]

## Project Layout

- **Layout Style**: [FILL: Standard or domain-driven]
- **Conventions**:
  - `cmd/` — entrypoints for executables
  - `internal/` — private application code, not importable externally
  - `pkg/` — public library code (if applicable)

## Code Style & Conventions

- **Formatting**: Always run `gofmt` (or `goimports`). No exceptions.
- **Naming**:
  - Exported identifiers use `CamelCase`
  - Unexported identifiers use `lowerCamelCase`
  - Single-method interfaces use the `-er` suffix (e.g., `Reader`, `Writer`)
- **Error Handling**:
  - Use multiple return values: `func Foo() (Result, error)`
  - Check errors immediately: `if err != nil { return ..., err }`
  - Use `errors.Is()` and `errors.As()` for wrapped error inspection
  - Wrap errors with `fmt.Errorf("context: %w", err)`
- **Concurrency**:
  - Use channels for coordination and communication between goroutines
  - Use mutexes (`sync.Mutex`) for protecting shared state
  - Follow the Go proverb: "Share memory by communicating"

## Modules & Dependencies

- Use **Go modules** (`go.mod` / `go.sum`)
- Always commit `go.sum` to version control
- Run `go mod tidy` before committing

## Testing

- **Style**: Table-driven tests are the default pattern
- **Assertions**: Use `testify` (`require` and `assert` packages)
- **Subtests**: Use `t.Run("case name", func(t *testing.T) { ... })`
- **Run**: `go test ./...`

## Build & Lint

- **Vet**: `go vet ./...`
- **Lint**: `golangci-lint run ./...`
- **Build**: `go build ./...`
- **Test**: `go test ./...`

## Nx Integration

- [FILL: project.json targets for build/test/lint, or standalone without Nx]
- If using Nx, define targets in `project.json` for `build`, `test`, and `lint`

## Common Backpressure

Run these checks before pushing or submitting a PR.

**Standalone**:

```bash
golangci-lint run ./... && go test ./... && go build ./...
```

**Nx**:

```bash
npx nx affected -t lint test build
```

## Notes

- [FILL: Additional project-specific Go conventions or libraries]
