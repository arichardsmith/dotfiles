#!/usr/bin/env zsh

show_help() {
	local editor_ui_val="${EDITOR_UI:-$EDITOR:-\$EDITOR_UI}"
	local editor_val="${EDITOR:-\$EDITOR}"

	cat << EOF
Usage: $(basename "$0") [OPTIONS] [PATH]

Opens a file or directory in the appropriate editor.

OPTIONS:
  -t, --terminal    Force using $editor_val instead of $editor_ui_val
  -h, --help        Show this help message

ARGUMENTS:
  PATH              File or directory to open (defaults to current directory)

ENVIRONMENT:
  \$EDITOR_UI       Preferred GUI/UI editor (used by default)
                    Currently: ${EDITOR_UI:-not set}
  \$EDITOR          Fallback or terminal editor
                    Currently: ${EDITOR:-not set}

EXAMPLES:
  $(basename "$0")                    # Open current directory in $editor_ui_val
  $(basename "$0") file.txt           # Open file.txt in $editor_ui_val
  $(basename "$0") -t file.txt        # Open file.txt in $editor_val
  $(basename "$0") --terminal .       # Open current directory in $editor_val
EOF
}

use_terminal=false
filepath=""

# Parse arguments
while [[ $# -gt 0 ]]; do
	case $1 in
		-h|--help)
			show_help
			exit 0
			;;
		-t|--terminal)
			use_terminal=true
			shift
			;;
		-*)
			echo "Error: Unknown option: $1" >&2
			echo "" >&2
			show_help >&2
			exit 1
			;;
		*)
			filepath="$1"
			shift
			;;
	esac
done

# Default to current directory if no path provided
if [[ -z "$filepath" ]]; then
	filepath="."
fi

# Select editor
if [[ "$use_terminal" == "true" ]]; then
	editor="${EDITOR:-}"
else
	editor="${EDITOR_UI:-${EDITOR:-}}"
fi

# Check if an editor is configured
if [[ -z "$editor" ]]; then
	echo "Error: No editor configured" >&2
	if [[ "$use_terminal" == "true" ]]; then
		echo "Please set the EDITOR environment variable" >&2
	else
		echo "Please set the EDITOR_UI or EDITOR environment variable" >&2
	fi
	exit 1
fi

# Open the file/directory with the selected editor
exec "$editor" "$filepath"
