---
name: go-conventions
description: Conventions for Go code style and patterns. Use when writing or reviewing Go code, go.mod files, or any .go files.
---

# Go Conventions

Follow standard Go idioms. Write code that passes `go vet` and `golangci-lint`.

## Naming

Follow Go standard conventions: `camelCase`/`PascalCase` based on export visibility, short variable names in tight scopes, descriptive names for wider scopes.

## Project Layout

Prefer flat layouts. Avoid `cmd/internal/pkg` unless the project genuinely warrants it.

## Style

- Accept interfaces, return structs
- Wrap errors with `fmt.Errorf("context: %w", err)`
- Use table-driven tests
