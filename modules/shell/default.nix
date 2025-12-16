{
  lib,
  config,
  ...
}: let
  cfg = config.shell;

  # Core aliases that should be available on all systems
  coreAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
  };

  # Core shell functions
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

  # Core scripts as packages
  coreScripts = [
    (lib.helpers.scriptToPackage "copy" ./scripts/copy.sh)
    (lib.helpers.scriptToPackage "now" ./scripts/now.sh)
    (lib.helpers.scriptToPackage "pasta" ./scripts/pasta.sh)
    (lib.helpers.scriptToPackage "plist" ./scripts/plist.sh)
    (lib.helpers.scriptToPackage "today" ./scripts/today.sh)
  ];
in {
  imports = [
    ./apps.nix
  ];

  options.shell = {
    setupHelpers = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Setup core aliases, functions, and scripts";
    };

    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Shell aliases (shell-agnostic)";
    };

    functions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Shell functions (shell-agnostic)";
    };

    initContent = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Shell initialization content (shell-agnostic)";
    };
  };

  config = lib.mkIf cfg.setupHelpers {
    # Add core aliases
    shell.aliases = coreAliases;

    # Add core functions
    shell.functions = coreFunctions;

    # Add core scripts to PATH
    home.packages = coreScripts;
  };
}
