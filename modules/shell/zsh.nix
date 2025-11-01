{
  lib,
  config,
  pkgs,
  ...
}: let
  # Core aliases that should be available on all systems
  coreAliases = {
    # Basic file operations
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
  };

  # zsh functions available on all systems
  # These __must__ be portable between Darwin and Linux
  coreFunctions = [
    ''
      mkcd () {
      	\mkdir -p "$1"
       	cd "$1"
      }
    ''
    ''
      tmpdir () {
      	cd "$(mktemp -d)"
      	chmod 0700 .
      	if [[ $# -eq 1 ]]; then
      		\mkdir -p "$1"
      		cd "$1"
      	fi
      }
    ''
  ];

  # Combine all functions from other modules
  additionalFunctions = lib.concatStringsSep "\n\n" (coreFunctions ++ config.zsh.functions);
  initContent = lib.concatStringsSep "\n\n" config.zsh.initContent;
in {
  options.zsh = {
    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Additional shell aliases to define";
    };
    functions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional shell functions to define";
    };
    initContent = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional shell initialization content";
    };
    scripts = lib.mkOption {
      type = lib.types.attrsOf lib.types.bool;
      default = {};
      description = ''
        Scripts to install as executable commands from modules/shell/scripts/.
        Attribute names become the command names and should match the script filename (without .sh).
        Set to `true` to enable a script, `false` to disable it.
      '';
      example = lib.literalExpression ''
        {
          unlock-drive = true;  # Installs unlock-drive command from scripts/unlock-drive.sh
          backup-system = true; # Installs backup-system command from scripts/backup-system.sh
          old-script = false;   # Disabled
        }
      '';
    };
  };

  config = {
    # Set default scripts - can be overridden by user config
    zsh.scripts.copy = lib.mkDefault true;
    zsh.scripts.ijs = lib.mkDefault true;
    zsh.scripts.now = lib.mkDefault true;
    zsh.scripts.pasta = lib.mkDefault true;
    zsh.scripts.plist = lib.mkDefault true;
    zsh.scripts.today = lib.mkDefault true;
    zsh.scripts.unlock-drive = lib.mkDefault false;

    programs.zsh = {
      enable = true;

      # Core configuration for all systems
      enableCompletion = true;
      autosuggestion.enable = true;

      # Combine core and additional aliases
      shellAliases = coreAliases // config.zsh.aliases;

      # Base initialization plus additional functions
      initContent = ''
        # Enable vim keybindings
        bindkey -v

        ${initContent}

        ${additionalFunctions}
      '';
    };

    # Add selected scripts to the user's PATH
    home.packages = lib.mapAttrsToList (
      name: _:
        pkgs.writeScriptBin name (builtins.readFile (./scripts + "/${name}.sh"))
    ) (lib.filterAttrs (_name: enabled: enabled) config.zsh.scripts);
  };
}
