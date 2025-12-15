#!/usr/bin/env bash

# Activate the dev environment in the current shell, avoid swapping to a new shell without our home config

# Walk up the directory tree to find env/flake.nix
find_flake() {
	local dir="$PWD"
	while [ "$dir" != "/" ] && [ "$dir" != "$HOME" ]; do
		if [ -f "$dir/env/flake.nix" ]; then
			echo "$dir/env"
			return 0
		fi
		dir="$(dirname "$dir")"
	done
	# Check $HOME itself
	if [ -f "$HOME/env/flake.nix" ]; then
		echo "$HOME/env"
		return 0
	fi
	return 1
}

# Parse flake path from argument or find nearest env/flake.nix
if [ -z "$1" ]; then
	if ! FLAKE_PATH=$(find_flake); then
		echo "Error: No env/flake.nix found in current directory or parents up to \$HOME" >&2
		exit 1
	fi
else
	FLAKE_PATH="$1"
fi

eval "$(nix develop "$FLAKE_PATH" --command bash -c 'export -p')"

export DEV_ENV_ACTIVE=1
