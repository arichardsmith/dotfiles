{
  lib,
  config,
  ...
}: {
  config = {
    programs.direnv = {
      enableZshIntegration = config.programs.zsh.enable;
      nix-direnv.enable = true;
      config = {
        hide_env_diff = true;
      };
    };

    # These are shortcuts for disabling and enabling direnv. There are times where I don't want it active, such as on a flight.
    shell.functions = lib.mkIf config.programs.direnv.enable [
      ''
        direnv-off() {
          eval "$(direnv hook zsh --disable)"
          echo "direnv disabled globally. Run direnv-on to re-enable it."
        }
      ''
      ''
        direnv-on() {
          eval "$(direnv hook zsh)"
          echo "direnv enabled"
        }
      ''
      ''
        direnv-flake-off() {
            local dir="$PWD"
            while [[ "$dir" != "/" && "$dir" != "$HOME" ]]; do
            if [[ -f "$dir/.envrc" ]]; then
                sed -i ''' 's/^use flake/#use flake/' "$dir/.envrc"
                echo "Flake disabled in $dir/.envrc"
                return 0
            fi
            dir="$(dirname "$dir")"
            done
            echo "No .envrc found in current or parent directories"
            return 1
        }
      ''
      ''
        direnv-flake-on() {
            local dir="$PWD"
            while [[ "$dir" != "/" && "$dir" != "$HOME" ]]; do
                if [[ -f "$dir/.envrc" ]]; then
                sed -i ''' 's/^#use flake/use flake/' "$dir/.envrc"
                echo "Flake enabled in $dir/.envrc"
                return 0
                fi
                dir="$(dirname "$dir")"
            done
            echo "No .envrc found in current or parent directories"
            return 1
        }
      ''
      ''
        direnv-load() {
            eval "$(direnv export zsh)"
        }
      ''
    ];
  };
}
