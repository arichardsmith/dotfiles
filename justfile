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

# Symlink shared AI config files and skills into Claude and agent paths.
link-ai:
  #!/usr/bin/env bash
  set -euo pipefail
  shopt -s nullglob
  repo_root="$PWD"
  agents_file="$repo_root/agents.md"
  claude_file="$repo_root/CLAUDE.md"
  dest_dirs=(
    "$repo_root/.claude/skills"
    "$repo_root/.agents/skills"
  )
  skill_paths=(
    "$repo_root"/skills/change-*
    "$repo_root"/skills/nix-conventions
  )

  if [[ -L "$claude_file" ]]; then
    rm "$claude_file"
  elif [[ -e "$claude_file" ]]; then
    printf 'Error: %s exists and is not a symlink\n' "$claude_file" >&2
    exit 1
  fi

  ln -s "agents.md" "$claude_file"
  printf 'Linked %s -> %s\n' "$claude_file" "agents.md"

  for dest_dir in "${dest_dirs[@]}"; do
    mkdir -p "$dest_dir"

    for skill_path in "${skill_paths[@]}"; do
      [[ -d "$skill_path" ]] || continue

      skill_name="$(basename "$skill_path")"
      link_path="$dest_dir/$skill_name"
      target="../../skills/$skill_name"

      if [[ -L "$link_path" ]]; then
        rm "$link_path"
      elif [[ -e "$link_path" ]]; then
        printf 'Error: %s exists and is not a symlink\n' "$link_path" >&2
        exit 1
      fi

      ln -s "$target" "$link_path"
      printf 'Linked %s -> %s\n' "$link_path" "$target"
    done
  done
