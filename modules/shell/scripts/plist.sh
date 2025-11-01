#!/usr/bin/env zsh
set -e
set -u

show_help() {
	cat << EOF
Usage: plist [PATTERN...]

Display a coloured process list, optionally filtered by pattern.

Arguments:
  PATTERN    One or more patterns to filter processes (case-insensitive)

Options:
  --help     Show this help message

Examples:
  plist              List all processes
  plist firefox      List processes matching "firefox"
  plist node deno    List processes matching "node" or "deno"
EOF
}

if [[ $# -gt 0 && "$1" == "--help" ]]; then
	show_help
	exit 0
fi

process_list="$(ps -eo 'pid command')"

# Filter the list with the command option if provided
if [[ $# != 0 ]]; then
	process_list="$(echo "$process_list" | grep -Fiw "$@")"
fi

echo "$process_list" |
	grep -Fv "${BASH_SOURCE[0]}" | # Remove the current process
	grep -Fv grep | # Remove any grep processes
	GREP_COLORS='mt=00;35' grep -E --colour=auto '^\s*[[:digit:]]+'
