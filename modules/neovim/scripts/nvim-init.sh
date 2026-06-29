#!/usr/bin/env bash
set -euo pipefail

file=".nvim.lua"

if [[ -e "$file" ]]; then
  echo "$file already exists in $(pwd)" >&2
  exit 1
fi

cat >"$file" <<'LUA'
-- Per-project Neovim config. Sourced automatically because `exrc` is enabled.
-- Toggle format-on-save by uncommenting the line below.
-- vim.g.format_on_save = true
LUA

echo "Created $file"
