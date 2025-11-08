#!/usr/bin/env bash

# Activate the dev environment in the current shell, avoid swapping to a new shell without our home config

DEFAULT_FLAKE_PATH="$HOME/dev/env"

# Parse flake path from argument or use default
if [ -z "$1" ]; then
	FLAKE_PATH="$DEFAULT_FLAKE_PATH"
else
	# If argument starts with #, prepend default path
	if [[ "$1" == \#* ]]; then
		FLAKE_PATH="$DEFAULT_FLAKE_PATH$1"
	else
		FLAKE_PATH="$1"
	fi
fi

eval "$(nix develop "$FLAKE_PATH" --command bash -c 'export -p')"

# Start colima only if COLIMA_INIT is set, command exists, and it's not running
if [ -n "$COLIMA_INIT" ] && command -v colima &>/dev/null; then
	if ! colima status &>/dev/null; then
		echo "Starting Colima..."
		colima start
	fi
fi

export DEV_ENV_ACTIVE=1
