---
name: rust-error-handling
description: Rust error handling patterns and conventions. Use when writing, reviewing, or refactoring error handling in Rust code, or when choosing between anyhow, thiserror, or custom error types.
---

# Rust Error Handling

## Application Code

Use `anyhow` from the start. It is production-ready whilst maintaining development velocity. Always add context with `.with_context()` or `.context()`. Use `bail!` for early returns.

```rust
use anyhow::{Context, Result, bail};

fn read_config() -> Result<String> {
    let content = fs::read_to_string("config.toml")
        .context("Failed to read config file")?;

    if content.is_empty() {
        bail!("Config file is empty");
    }

    Ok(content)
}
```

## Library Code

Use `thiserror` for public APIs so consumers can match on specific error variants. Use `#[from]` for automatic conversion from underlying errors.

```rust
#[derive(Error, Debug)]
pub enum ConfigError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Missing required field: {field}")]
    MissingField { field: String },
}
```

For complex libraries with large public APIs, consider hand-implementing `Display` and `Error` for full control over error reporting.

## Prototyping Only

`Box<dyn Error>` and `.unwrap()` are acceptable for throwaway code. Never in production, never in libraries.
