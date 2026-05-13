#!/usr/bin/env zsh
set -euo pipefail

show_help() {
  cat <<'EOF'
install - Apply home-manager configuration for this machine

USAGE:
    install.sh [OPTIONS]

DESCRIPTION:
    Applies the home-manager configuration for the current machine.
    The machine is determined by the DOTFILE_MACHINE environment variable.

OPTIONS:
    -u, --update    Update the flake lock file before installing
    -h, --help      Show this help message

EXAMPLES:
    install.sh
    install.sh --update

EOF
}

update_flake=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -u|--update)
      update_flake=true
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "${DOTFILE_MACHINE:-}" ]]; then
  echo "Error: DOTFILE_MACHINE is not set" >&2
  echo "Valid values: laptop, mininas" >&2
  exit 1
fi

cd "$(dirname "$0")"

if [[ "$update_flake" == true ]]; then
  nix flake update
fi

home-manager switch --flake ".#${DOTFILE_MACHINE}"
