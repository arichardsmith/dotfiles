FLAKE="github:arichardsmith/dotfiles"
MACHINE="${DOTFILE_MACHINE:-}"

show_help() {
  cat << EOF
Usage: rebuild.sh [options]

Run home-manager switch for a given flake and machine.

Options:
  --flake <url>     Flake URL (default: $FLAKE)
  --machine <name>  Machine name (default: $DOTFILE_MACHINE)
  --help            Show this help text and exit
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      show_help
      exit 0
      ;;
    --flake)   FLAKE="$2";   shift 2 ;;
    --machine) MACHINE="$2"; shift 2 ;;
    *) printf 'Unknown argument: %s\n' "$1" >&2; exit 1 ;;
  esac
done

if [[ -z "$MACHINE" ]]; then
  printf 'Error: machine not set (use --machine or DOTFILE_MACHINE)\n' >&2
  exit 1
fi

# Nix caches remote flakes, so we need to add `--refresh` to force it to get the latest version
# However, this also forces a re-fetch of all the input flakes. So we don't want to add this flag
# if not needed, such as when switching to a local flake.

ARGS=()
case "$FLAKE" in
  .*|/*|path:*|file:*)
    ARGS+=(--refresh)
    ;;
esac

home-manager switch "${ARGS[@]}" --flake "$FLAKE#$MACHINE"
