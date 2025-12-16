#!/usr/bin/env zsh
set -e
set -u

show_help() {
  cat << EOF
Usage: ijs [--bun|--deno|--node]

Open an interactive JavaScript REPL.

Options:
  --bun     Force use of Bun
  --deno    Force use of Deno
  --node    Force use of Node.js
  --help    Show this help message

Without flags, prefers Bun if available, then Deno, then Node.js.
EOF
}

runtime=""

# Parse command line argument to allow forcing a specific runtime
if [[ $# -gt 0 ]]; then
  case "$1" in
    --bun)
      runtime="bun"
      ;;
    --deno)
      runtime="deno"
      ;;
    --node)
      runtime="node"
      ;;
    --help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      show_help
      exit 1
      ;;
  esac
fi

# Auto-detect runtime if none was specified via flags
if [[ -z "$runtime" ]]; then
  if hash bun 2>/dev/null; then
    runtime="bun"
  elif hash deno 2>/dev/null; then
    runtime="deno"
  elif hash node 2>/dev/null; then
    runtime="node"
  else
    echo 'no js runtime found' >&2
    exit 1
  fi
fi

# Verify the chosen runtime is actually installed (catches forced runtime that doesn't exist)
if ! hash "$runtime" 2>/dev/null; then
  echo "$runtime is not installed" >&2
  exit 1
fi

# Launch the appropriate REPL, replacing this process
case "$runtime" in
  bun)
    exec bun repl
    ;;
  deno)
    exec deno repl
    ;;
  node)
    exec node
    ;;
esac
