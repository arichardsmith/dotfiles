{
  lib,
  config,
  ...
}: let
  # Core aliases that should be available on all systems
  coreAliases = {
    # Basic file operations
    ".." = "cd ..";
    "..." = "cd ../..";
  };

  # Combine all functions from other modules
  additionalFunctions = lib.concatStringsSep "\n\n" config.zsh.functions;
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
  };
}
