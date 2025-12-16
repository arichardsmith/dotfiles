{
  lib,
  config,
  pkgs,
  ...
}: let
  scriptToPackage = import ../../lib/script_to_package.nix {inherit pkgs;};

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
  };

  config = {
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
    home.packages = [
      (scriptToPackage "copy" ./scripts/copy.sh)
      (scriptToPackage "now" ./scripts/now.sh)
      (scriptToPackage "pasta" ./scripts/pasta.sh)
      (scriptToPackage "plist" ./scripts/plist.sh)
      (scriptToPackage "today" ./scripts/today.sh)
    ];
  };
}
