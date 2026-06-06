flake="github:arichardsmith/dotfiles"
machine="${DOTFILE_MACHINE:-}"

show_help() {
  cat << EOF
Usage: rebuild.sh [options]

Run home-manager switch for a given flake and machine.

Options:
  --flake <url>     Flake URL (default: $flake)
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
    --flake)   flake="$2";   shift 2 ;;
    --machine) machine="$2"; shift 2 ;;
    *) printf 'Unknown argument: %s\n' "$1" >&2; exit 1 ;;
  esac
done

if [[ -z "$machine" ]]; then
  printf 'Error: machine not set (use --machine or DOTFILE_MACHINE)\n' >&2
  exit 1
fi

home-manager switch --flake "$flake#$machine"
