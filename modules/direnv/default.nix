{
  lib,
  config,
  ...
}: {
  config = {
    programs.direnv = {
      nix-direnv.enable = true;
      config = {
        hide_env_diff = true;
      };
    };

    # Manually add the zsh integration in a way that supports disabling
    programs.zsh = lib.mkIf config.programs.direnv.enable {
      initContent = ''
        _direnv_hook() {
          trap -- ''' SIGINT
          eval "$("/opt/homebrew/bin/direnv" export zsh)"
          trap - SIGINT
        }

        direnv-disable() {
          typeset -ag precmd_functions
          if (( ''${precmd_functions[(I)_direnv_hook]} )); then
            precmd_functions=(''${precmd_functions:#_direnv_hook})
          fi
          typeset -ag chpwd_functions
          if (( ''${chpwd_functions[(I)_direnv_hook]} )); then
            chpwd_functions=(''${chpwd_functions#_direnv_hook})
          fi

          echo "Disabled direnv globally"
        }

        direnv-enable() {
          typeset -ag precmd_functions
          if (( ! ''${precmd_functions[(I)_direnv_hook]} )); then
            precmd_functions=(_direnv_hook $precmd_functions)
          fi
          typeset -ag chpwd_functions
          if (( ! ''${chpwd_functions[(I)_direnv_hook]} )); then
            chpwd_functions=(_direnv_hook $chpwd_functions)
          fi
        }

        direnv-toggle() {
          typeset -ag precmd_functions
          if (( ''${precmd_functions[(I)_direnv_hook]} )); then
            direnv-disable
          else
            direnv-enable
          fi
        }

        qcd() {
            direnv-disable
            cd "$@"
        }

        direnv-enable
      '';
    };
  };
}
