{
  lib,
  config,
  ...
}: let
  cfg = config.my.shell;

  commandType = lib.types.submodule {
    options = {
      zsh = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Zsh implementation of the command (full function definition).";
      };

      nushell = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Nushell implementation of the command (full `def` declaration).";
      };
    };
  };
in {
  options.my.shell = {
    setupHelpers = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Setup core aliases and commands.";
    };

    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Shell aliases (shell-agnostic).";
    };

    commands = lib.mkOption {
      type = lib.types.attrsOf commandType;
      default = {};
      description = "Custom commands with per-shell implementations.";
    };
  };

  config = lib.mkIf cfg.setupHelpers {
    my.shell.aliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
    };

    my.shell.commands = {
      mkcd = {
        zsh = ''
          mkcd () {
            \mkdir -p "$1"
            cd "$1"
          }
        '';

        nushell = ''
          def --env mkcd [dir: path] {
            mkdir $dir
            cd $dir
          }
        '';
      };

      tmpdir = {
        zsh = ''
          tmpdir () {
            cd "$(mktemp -d)"
            chmod 0700 .
            if [[ $# -eq 1 ]]; then
              \mkdir -p "$1"
              cd "$1"
            fi
          }
        '';

        nushell = ''
          def --env tmpdir [...sub] {
            cd (mktemp -d)
            chmod 0700 .
            if ($sub | is-not-empty) {
              mkdir $sub.0
              cd $sub.0
            }
          }
        '';
      };
    };
  };
}
