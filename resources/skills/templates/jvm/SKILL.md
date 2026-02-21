# JVM Development Skill

<!-- category: language -->

## Language & Runtime

- **Language**: [FILL: Java / Kotlin / Scala]
- **Language Version**: [FILL: e.g., Java 21, Kotlin 2.0, Scala 3.x]
- **JVM Version**: [FILL: e.g., 21 LTS]

## Build System

- **Build Tool**: [FILL: Gradle (Kotlin DSL) / Maven / sbt]
- **Framework**: [FILL: Spring Boot / Quarkus / Micronaut / Play / ZIO]

## Project Structure

- Follow the standard Maven/Gradle directory layout:
  - `src/main/java/` or `src/main/kotlin/` — application source
  - `src/main/scala/` — Scala source (if using Scala)
  - `src/main/resources/` — configuration and static resources
  - `src/test/java/` or `src/test/kotlin/` or `src/test/scala/` — test source
  - `src/test/resources/` — test resources

## Dependency Management

- **Gradle**: Use version catalogs (`libs.versions.toml`) for centralized dependency versions
- **Maven**: Use `<dependencyManagement>` in parent POM
- **sbt**: Define versions in `build.sbt` or `project/Dependencies.scala`

## Code Style & Conventions

- **Java**: Follow Google Java Style or project-specific checkstyle rules
- **Kotlin**: Follow Kotlin coding conventions; use `ktlint` or `spotless`
- **Scala**: Follow Scala style guide; use `scalafmt` for formatting
- Prefer immutability and value objects
- Use sealed classes/interfaces for restricted type hierarchies

## Scala Specifics

- Favor functional patterns: pure functions, immutable data, effect systems
- Use `given`/`using` (Scala 3) or implicits (Scala 2) judiciously; document intent
- Leverage pattern matching and exhaustive `match` expressions
- Prefer `case class` for data modeling; use `enum` (Scala 3) for ADTs

## Testing

- **Java/Kotlin**: JUnit 5 with `@Test`, `@ParameterizedTest`, `@Nested`
- **Scala**: ScalaTest (FlatSpec, FunSuite) or MUnit; ScalaMock for mocking
- **Mocking**: MockK (Kotlin), Mockito (Java), ScalaMock (Scala)
- **Integration**: Testcontainers for database and service dependencies
- **Run**:
  - Gradle: `./gradlew test`
  - Maven: `mvn test`
  - sbt: `sbt test`

## Build & Lint

- **Gradle**: `./gradlew check` (runs compile, test, lint)
- **Maven**: `mvn verify`
- **sbt**: `sbt clean compile test`
- **Kotlin lint**: `ktlint` or `spotless`
- **Scala lint**: `scalafmt --check`
- **Java lint**: `checkstyle`

## Nx Integration

- [FILL: project.json targets for build/test/lint, or standalone without Nx]
- If using Nx, define targets in `project.json` for `build`, `test`, and `lint`

## Common Backpressure

Run these checks before pushing or submitting a PR.

**Standalone**:

```bash
# Gradle
./gradlew check

# Maven
mvn verify

# sbt
sbt clean compile test
```

**Nx**:

```bash
npx nx affected -t lint test build
```

## Notes

- [FILL: Additional project-specific JVM conventions, libraries, or architecture patterns]
