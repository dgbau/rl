# Rust + Axum + SQLx + Tower Stack Skill

<!-- category: stack -->

## Overview
Axum is a modular web framework built on top of Tower and Hyper. Combined with
SQLx for compile-time verified SQL and Tower for middleware, this stack provides
a high-performance, type-safe, async Rust backend with zero runtime ORM overhead.
[FILL: How this stack is used in THIS project -- API-only, SSR, microservice]

## Shared State with Arc

- Application state (DB pool, config, caches) is wrapped in `Arc<AppState>` and
  passed to the router via `.with_state()`
- Access state in handlers via `State(state): State<Arc<AppState>>`
- Never use global mutable state; all shared state goes through Arc
- [FILL: What lives in AppState -- PgPool, Redis, config, etc.]

```rust
struct AppState {
    db: PgPool,
    // [FILL: other shared resources]
}

let state = Arc::new(AppState { db: pool });
let app = Router::new()
    .route("/items", get(list_items))
    .with_state(state);
```

## Error Handling with IntoResponse

- Define a custom `AppError` enum that implements `IntoResponse`
- Map all error types (SQLx, validation, auth) into `AppError` variants
- Each variant returns an appropriate HTTP status code and JSON body
- Use `thiserror` for defining errors, implement `IntoResponse` manually
- Handlers return `Result<impl IntoResponse, AppError>`
- [FILL: Path to error module -- e.g., src/error.rs]

## SQLx: Compile-Time SQL

- Use `sqlx::query_as!` for type-checked queries against the real database schema
- Requires `DATABASE_URL` at compile time (set in `.env` or via `sqlx-data.json` offline mode)
- Offline mode: Run `cargo sqlx prepare` to save query metadata for CI builds
  without a live database
- [FILL: Database -- PostgreSQL / MySQL / SQLite]
- [FILL: Migration strategy -- sqlx migrate run, embedded migrations]

## Request-Scoped Transactions

- Use `axum_sqlx_tx` extractor for automatic request-scoped transactions
- Transaction commits on success (2xx response), rolls back on error
- Extract with `Tx(tx): Tx<Postgres>` in handler signature
- [FILL: Whether axum_sqlx_tx is used, or manual transaction handling]

```rust
async fn create_item(
    Tx(mut tx): Tx<Postgres>,
    Json(input): Json<CreateItem>,
) -> Result<Json<Item>, AppError> {
    let item = sqlx::query_as!(Item, "INSERT INTO items ...")
        .fetch_one(&mut *tx)
        .await?;
    Ok(Json(item))
}
```

## Tower Middleware Layering

- Middleware is composable via Tower layers, applied in reverse order (last added = outermost)
- Common layers: `TraceLayer` (logging), `CorsLayer`, `CompressionLayer`,
  `TimeoutLayer`, rate limiting, auth
- Apply globally on the router or scoped to specific route groups
- [FILL: Middleware stack used in this project, in order]

```rust
let app = Router::new()
    .merge(api_routes)
    .layer(TraceLayer::new_for_http())
    .layer(CorsLayer::permissive())
    .layer(TimeoutLayer::new(Duration::from_secs(30)));
```

## Router Organization

- Split routes into modules by domain: `routes::items`, `routes::users`, etc.
- Each module returns a `Router<Arc<AppState>>` that is merged into the main router
- Use `nest("/api/v1", api_routes)` for route prefixing
- [FILL: Route module location -- e.g., src/routes/]

## Graceful Shutdown

- Axum supports graceful shutdown via `tokio::signal` and `axum::serve().with_graceful_shutdown()`
- Wait for in-flight requests to complete before exiting
- Close database pool connections cleanly
- [FILL: Shutdown signal handling -- SIGTERM, SIGINT, custom]

## Integration Testing

- Use `axum::Router` directly with `tower::ServiceExt` (`.oneshot()`) for
  in-process testing -- no need to bind a port
- Or use `reqwest::Client` against a spawned test server for full HTTP testing
- Create test fixtures with a dedicated test database and run migrations
- [FILL: Test utilities location, test database strategy]

```rust
#[tokio::test]
async fn test_list_items() {
    let app = create_test_app().await;
    let response = app
        .oneshot(Request::builder().uri("/items").body(Body::empty()).unwrap())
        .await
        .unwrap();
    assert_eq!(response.status(), StatusCode::OK);
}
```

## Project Layout

```
src/
  main.rs            # Server bootstrap, graceful shutdown
  lib.rs             # App construction, router assembly
  routes/            # Route handlers by domain
  models/            # SQLx FromRow structs
  error.rs           # AppError + IntoResponse
  state.rs           # AppState definition
  middleware/        # Custom Tower layers
migrations/          # SQLx migrations
```
[FILL: Actual project layout]

## Key Constraints

- All SQL queries must be compile-time checked (no raw string queries without sqlx macros)
- Every handler must return `Result<_, AppError>` -- never unwrap in handlers
- [FILL: Performance targets, response time budgets]
- [FILL: Async runtime -- tokio (default), or other]

## Where to Look

- Router assembly: [FILL: Path to src/lib.rs or src/routes/mod.rs]
- Error handling: [FILL: Path to src/error.rs]
- Migrations: [FILL: Path to migrations/]
- State: [FILL: Path to src/state.rs]
- Docs: https://docs.rs/axum, https://docs.rs/sqlx, https://docs.rs/tower

## Common Pitfalls

- Forgetting `cargo sqlx prepare` before CI builds (offline mode stale)
- Middleware ordering confusion (layers wrap in reverse order of declaration)
- Axum extractor ordering matters: `State` must come last in handler params
- [FILL: Project-specific gotchas encountered]
