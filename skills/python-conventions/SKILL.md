---
name: python-conventions
description: Conventions for Python code style and tooling. Use when writing or reviewing Python code, pyproject.toml files, or any .py files.
---

# Python Conventions

## Naming

- `snake_case` for variables, functions, methods, modules
- `PascalCase` for classes and type aliases
- `UPPER_SNAKE_CASE` for constants

## Tooling

- Package manager: `uv`
- Type checker: `basedpyright`
- Linter/formatter: `ruff`

## Type Hints

Use strict type hints throughout. Code must pass basedpyright with no errors. Type all function signatures, including return types. Use `None` return annotation explicitly.

```python
def parse_config(path: str) -> dict[str, str]:
    ...

def process(items: list[Item]) -> None:
    ...
```

Prefer modern type syntax (`list[str]`, `dict[str, int]`, `str | None`) over `typing` module equivalents.
