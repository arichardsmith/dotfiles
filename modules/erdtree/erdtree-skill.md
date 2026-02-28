---
name: erdtree
description: This machine uses the erdtree command for listing files. Use whenever running shell commands, listing files, or interacting with the filesystem via the terminal.
---

# Erdtree CLI Conventions

This machine has `erdtree` aliased to `ls`. Standard `ls` flags like `-la` will NOT work.

## Available Commands

- `erd --long --hidden` — list files with details, including hidden files
- `erd --hidden --level 2` — peek into subdirectories
- `ols` — the original `ls` binary, if you need it

## Important

Always use `erd` commands instead of traditional `ls` flags. If you need the original `ls` behavior, use `ols`.
