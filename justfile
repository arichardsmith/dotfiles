rebuild machine:
  #!/usr/bin/env bash
  set -euo pipefail
  case "{{machine}}" in
    mba)
      sudo darwin-rebuild switch --flake .#{{machine}}
      ;;
    mininas)
      home-manager switch --flake .#{{machine}}
      ;;
    example)
      sudo nixos-rebuild switch --flake .#{{machine}}
      ;;
    *)
      printf 'Unknown machine: %s\n' "{{machine}}" >&2
      exit 1
      ;;
  esac

push_it:
  jj git push --remote origin
  jj git push --remote gh

# Check for and apply version updates to pinned pkgs (npm and GitHub).
update_pkgs:
  uv run scripts/update-pkgs.py

# Symlink shared AI config files and skills into Claude and agent paths.
link_ai:
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

# Check that derivations evaluate for all machines.
[parallel]
check: check_mba check_mininas check_example

check_mba:
	nix eval 'path:.#darwinConfigurations.mba.system'

check_mininas:
	nix eval 'path:.#homeConfigurations.mininas.activationPackage.drvPath'

check_example:
	nix eval 'path:.#nixosConfigurations.example.config.system.build.toplevel.drvPath'

fmt:
	alejandra .
