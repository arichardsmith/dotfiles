#!/usr/bin/env bash

# Query package.json with jq

set -euo pipefail

# Find package.json by walking up directories
find_package_json() {
	local dir="$PWD"
	while [[ "$dir" != "/" ]]; do
		if [[ -f "$dir/package.json" ]]; then
			echo "$dir/package.json"
			return 0
		fi
		dir="$(dirname "$dir")"
	done
	echo "Error: package.json not found" >&2
	return 1
}

# Resolve aliases to jq queries
resolve_aliases() {
	case "$1" in
		scripts) echo ".scripts" ;;
		deps) echo "{dependencies, devDependencies, peerDependencies, optionalDependencies}" ;;
		version) echo ".version" ;;
		*) echo "$1" ;;
	esac
}

show_help() {
	cat <<-'EOF'
	pkq - Query package.json with jq

	USAGE:
	    pkq <query|alias>
	    pkq -h, --help

	DESCRIPTION:
	    Finds the nearest package.json by walking up from the current directory
	    and queries it using jq. Supports aliases for common queries.

	ALIASES:
	    scripts    Query .scripts
	    deps       Query all dependency fields
	    version    Get the package version

	EXAMPLES:
	    pkq .name
	    pkq scripts
	    pkq deps
	    pkq '.scripts | keys'
	    pkq '.dependencies | length'

	EOF
}

main() {
	if [[ $# -eq 0 ]]; then
		show_help
		exit 1
	fi

	case "$1" in
		-h|--help)
			show_help
			exit 0
			;;
	esac

	local pkg_json
	pkg_json="$(find_package_json)" || exit 1

	local query
	query="$(resolve_aliases "$1")"

	jq "$query" "$pkg_json"
}

main "$@"
