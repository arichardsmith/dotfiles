---
name: cli-conventions
description: CLI tool aliases and conventions on this machine. Use whenever running shell commands, listing files, or interacting with the filesystem via the terminal.
user-invocable: false
---

# CLI Conventions

## File Listing

`ls` is aliased to `erdtree`. Standard `ls` flags like `-la` will not work.

- `erd --long --hidden` — list files with details, including hidden files
- `erd --hidden --level 2` — peek into subdirectories
- `ols` — the original `ls` binary, if needed
