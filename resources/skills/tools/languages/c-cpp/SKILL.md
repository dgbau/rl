# C/C++ Development Skill

<!-- category: language -->

## Language & Standard

- **Language**: [FILL: C / C++ / both]
- **C Standard**: [FILL: C11 / C17 / C23]
- **C++ Standard**: [FILL: C++17 / C++20 / C++23]
- **Compiler**: [FILL: GCC / Clang / MSVC]

## Build System

- **Build Tool**: [FILL: CMake / Meson / Bazel]
- **Generator**: [FILL: Ninja / Make / MSBuild] (if using CMake or Meson)

## Dependency Management

- **Method**: [FILL: vcpkg / Conan / FetchContent / system packages]
- Keep dependency manifests committed (e.g., `vcpkg.json`, `conanfile.txt`)
- Pin dependency versions for reproducible builds

## Project Structure

- `src/` — application source files
- `include/` — public headers (for libraries)
- `tests/` — test source files
- `build/` — out-of-source build directory (never commit)
- `CMakeLists.txt` or `meson.build` at project root

## Memory Safety

- **Sanitizers**: Enable ASan, TSan, and UBSan in CI builds
  - CMake: `-DCMAKE_CXX_FLAGS="-fsanitize=address,undefined"`
  - Meson: `b_sanitize=address,undefined`
- **C++ Smart Pointers**: Use `std::unique_ptr` and `std::shared_ptr`; avoid raw `new`/`delete`
- **C**: Use consistent allocation/deallocation patterns; document ownership
- Prefer stack allocation and RAII (C++) over heap allocation when possible

## Code Style & Conventions

- **Formatting**: Use `clang-format` with a committed `.clang-format` config
- **Naming**: [FILL: snake_case / CamelCase / project convention]
- Header guards: Prefer `#pragma once` or include guards matching the file path
- Prefer `const` and `constexpr` by default

## Testing

- **Framework**: [FILL: GoogleTest / Catch2 / CTest]
- Write unit tests for all public interfaces
- Use CTest as the test runner for CMake projects
- Run: `ctest --output-on-failure` from the build directory

## Linting & Static Analysis

- **clang-tidy**: Enable and configure via `.clang-tidy` at project root
- **clang-format**: Enforce formatting via `.clang-format`
- **cppcheck**: Additional static analysis for common issues
- Run analysis as part of CI; treat warnings as errors

## Build & Lint

- **CMake**:
  - Configure: `cmake -B build -G Ninja`
  - Build: `cmake --build build`
  - Test: `cd build && ctest --output-on-failure`
- **Meson**:
  - Configure: `meson setup build`
  - Build: `meson compile -C build`
  - Test: `meson test -C build`

## Nx Integration

- [FILL: project.json targets for build/test/lint, or standalone without Nx]
- If using Nx, define targets in `project.json` for `build`, `test`, and `lint`

## Common Backpressure

Run these checks before pushing or submitting a PR.

**Standalone**:

```bash
cmake --build build && cd build && ctest --output-on-failure
```

**Nx**:

```bash
npx nx affected -t lint test build
```

## Notes

- [FILL: Additional project-specific C/C++ conventions, libraries, or toolchain details]
