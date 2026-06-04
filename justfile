# Apply the Home Manager config for DOTFILE_MACHINE.
install:
  #!/usr/bin/env bash
  set -euo pipefail
  if [[ -z "${DOTFILE_MACHINE:-}" ]]; then
    printf 'Error: DOTFILE_MACHINE is not set\n' >&2
    printf 'Valid values: laptop, mininas\n' >&2
    exit 1
  fi
  home-manager switch --flake ".#${DOTFILE_MACHINE}"

