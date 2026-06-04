flake="github:arichardsmith/dotfiles"
machine="${DOTFILE_MACHINE:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      printf 'Usage: rebuild.sh [options]\n'
      printf '\n'
      printf 'Run home-manager switch for a given flake and machine.\n'
      printf '\n'
      printf 'Options:\n'
      printf '  --flake <url>     Flake URL (default: %s)\n' "$flake"
      printf '  --machine <name>  Machine name (default: $DOTFILE_MACHINE)\n'
      printf '  --help            Show this help text and exit\n'
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
