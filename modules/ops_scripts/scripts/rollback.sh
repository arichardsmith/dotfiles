show_help() {
  cat << EOF
Usage: rollback.sh [options] [subcommand]

Rollback to the previous Home Manager generation, or list available generations.

Subcommands:
  list              List available generations without switching

Options:
  --n <count>       Number of generations to list (default: 10)
  --help            Show this help text and exit
EOF
}

list_generations() {
  local MAX_GENERATIONS="$1"
  local PROFILE_DIR CURRENT LINK TS HUMAN MARKER
  local -a LINKS SORTED_LINES

  PROFILE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles"

  if [ ! -d "$PROFILE_DIR" ]; then
    printf 'No Nix profile directory at %s\n' "$PROFILE_DIR" >&2
    return 1
  fi

  # Make an empty generation set expand to an empty array instead of the literal glob.
  shopt -s nullglob
  LINKS=("$PROFILE_DIR"/home-manager-*-link)
  shopt -u nullglob

  if [ "${#LINKS[@]}" -eq 0 ]; then
    printf 'No home-manager generations found in %s\n' "$PROFILE_DIR" >&2
    return 1
  fi

  CURRENT=""
  if [ -L "$PROFILE_DIR/home-manager" ]; then
    CURRENT="$(basename "$(readlink "$PROFILE_DIR/home-manager")")"
  fi

  # Emit "epoch<TAB>date<TAB>link" per generation, then sort by epoch descending.
  # stat/date have GNU and BSD variants; the || fallbacks cover Linux and macOS.
  mapfile -t SORTED_LINES < <(
    for LINK in "${LINKS[@]}"; do
      TS="$(stat -c %Y "$LINK" 2>/dev/null || stat -f %m "$LINK")"
      HUMAN="$(date -d "@$TS" '+%Y-%m-%d %H:%M' 2>/dev/null || date -r "$TS" '+%Y-%m-%d %H:%M')"
      printf '%s\t%s\t%s\n' "$TS" "$HUMAN" "$LINK"
    done | sort -rn
  )

  if [ "${#SORTED_LINES[@]}" -eq 0 ]; then
    return 0
  fi

  for LINE in "${SORTED_LINES[@]:0:MAX_GENERATIONS}"; do
    IFS=$'\t' read -r _ HUMAN LINK <<< "$LINE"
    MARKER=""
    [ "$(basename "$LINK")" = "$CURRENT" ] && MARKER="  <- current"
    printf '%s%s\n    %s/activate\n\n' "$HUMAN" "$MARKER" "$LINK"
  done
}

MAX_GENERATIONS=10
COMMAND=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --help|-h|help)
      show_help
      exit 0
      ;;
    --n)
      if [ "$#" -lt 2 ]; then
        printf 'Error: --n requires a value\n' >&2
        exit 1
      fi
      shift
      MAX_GENERATIONS="${1:-}"
      if ! [[ "$MAX_GENERATIONS" =~ ^[1-9][0-9]*$ ]]; then
        printf 'Error: --n must be a positive integer\n' >&2
        exit 1
      fi
      ;;
    list|rollback)
      if [ -z "$COMMAND" ]; then
        COMMAND="$1"
      else
        printf 'Unknown argument: %s\n' "$1" >&2
        exit 1
      fi
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      exit 1
      ;;
  esac
  shift
done

case "$COMMAND" in
  ""|rollback)
    if command -v home-manager >/dev/null 2>&1; then
      printf 'home-manager found on PATH; rolling back to the previous generation...\n'
      exec home-manager switch --rollback
    fi

    printf 'home-manager not on PATH. Listing generations for manual rollback.\n\n'
    list_generations "$MAX_GENERATIONS"
    ;;
  list)
    list_generations "$MAX_GENERATIONS"
    ;;
  *)
    printf 'Unknown argument: %s\n' "$COMMAND" >&2
    exit 1
    ;;
esac
