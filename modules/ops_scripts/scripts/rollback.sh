show_help() {
  cat << EOF
Usage: rollback.sh [options] [subcommand]

Rollback to the previous Home Manager generation, or list available generations.

Subcommands:
  list              List available generations without switching

Options:
  --help            Show this help text and exit
EOF
}

list_generations() {
  local PROFILE_DIR LINKS CURRENT LINK TS HUMAN MARKER

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
  for LINK in "${LINKS[@]}"; do
    TS="$(stat -c %Y "$LINK" 2>/dev/null || stat -f %m "$LINK")"
    HUMAN="$(date -d "@$TS" '+%Y-%m-%d %H:%M' 2>/dev/null || date -r "$TS" '+%Y-%m-%d %H:%M')"
    printf '%s\t%s\t%s\n' "$TS" "$HUMAN" "$LINK"
  done | sort -rn | while IFS=$'\t' read -r _ HUMAN LINK; do
    MARKER=""
    [ "$(basename "$LINK")" = "$CURRENT" ] && MARKER="  <- current"
    printf '%s%s\n    %s/activate\n\n' "$HUMAN" "$MARKER" "$LINK"
  done
}

COMMAND="${1:-}"

case "$COMMAND" in
  ""|rollback)
    if command -v home-manager >/dev/null 2>&1; then
      printf 'home-manager found on PATH; rolling back to the previous generation...\n'
      exec home-manager switch --rollback
    fi

    printf 'home-manager not on PATH. Listing generations for manual rollback.\n\n'
    list_generations
    ;;
  list)
    list_generations
    ;;
  --help|-h|help)
    show_help
    ;;
  *)
    printf 'Unknown argument: %s\n' "$COMMAND" >&2
    exit 1
    ;;
esac
