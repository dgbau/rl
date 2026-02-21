# Python Development Skill

<!-- category: language -->

## Language & Runtime

- **Language**: Python
- **Version**: [FILL: e.g., 3.12+]
- **Package Manager**: [FILL: uv / poetry / pip] — uv is recommended

## Project Layout

- Use **src/ layout** with `pyproject.toml` (PEP 621)
- Structure:
  - `src/<package_name>/` — main package code
  - `tests/` — test suite
  - `pyproject.toml` — project metadata, dependencies, and tool config

## Virtual Environments

- **Always** use virtual environments; never install into the system Python
- With uv: `uv venv && source .venv/bin/activate`
- With poetry: `poetry install` creates and manages the venv automatically

## Code Style & Formatting

- **Linting & Formatting**: Use **Ruff** — it replaces black, isort, and flake8
  - `ruff check .` for linting
  - `ruff format .` for formatting
- Configure in `pyproject.toml` under `[tool.ruff]`

## Type Checking

- Use **mypy** in strict mode
- Add type annotations to all public API functions and methods
- Use `typing` module constructs: `Optional`, `Union`, `TypeVar`, generics
- Configure in `pyproject.toml` under `[tool.mypy]`

## Testing

- **Framework**: pytest
- **Property-based testing**: Hypothesis for invariant and fuzz testing
- **Fixtures**: Use pytest fixtures for setup/teardown and dependency injection
- **Structure**: Mirror `src/` layout in `tests/` with `test_` prefixed files
- Run: `pytest` or `pytest -v` for verbose output

## Build & Lint

- **Lint**: `ruff check .`
- **Format check**: `ruff format --check .`
- **Type check**: `mypy .`
- **Test**: `pytest`

## Nx Integration

- [FILL: project.json targets for build/test/lint, or standalone without Nx]
- If using Nx, define targets in `project.json` for `lint`, `test`, and `build`

## Common Backpressure

Run these checks before pushing or submitting a PR.

**Standalone**:

```bash
ruff check . && mypy src/ && pytest
```

**Nx**:

```bash
npx nx affected -t lint test build
```

## Notes

- [FILL: Additional project-specific Python conventions, frameworks, or libraries]
