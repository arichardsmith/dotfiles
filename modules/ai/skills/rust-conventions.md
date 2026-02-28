---
name: rust-conventions
description: Conventions for Rust code style and patterns. Use when writing or reviewing Rust code, Cargo.toml files, or any .rs files.
---

# Rust Conventions

Follow standard Rust idioms (clippy-clean code, standard naming conventions).

## Naming

Follow Rust standard conventions: `snake_case` for functions/variables, `PascalCase` for types/traits, `UPPER_SNAKE_CASE` for constants.

## Async

Use tokio as the async runtime.

## Serialisation

Use serde for serialisation. Derive `Serialize`/`Deserialize` on data types. Use `#[serde(rename_all = "snake_case")]` for consistency with field naming.

## Error Handling

See the `rust-error-handling` skill for detailed conventions. In short: `anyhow` for applications, `thiserror` for libraries, never `unwrap()` in production code.
