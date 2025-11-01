#!/usr/bin/env zsh
set -e
set -u

if hash pbpaste 2>/dev/null; then
	# Darwin
  	exec pbpaste
elif hash xclip 2>/dev/null; then
	# Linux
  	exec xclip -selection clipboard -o
else
	echo "No clipboard command available on this system" >&2
	exit 1
fi
