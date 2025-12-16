{
  lib,
  config,
  ...
}: let
  # Combine all functions from shell-agnostic and zsh-specific sources
  additionalFunctions = lib.concatStringsSep "\n\n" (config.shell.functions ++ config.zsh.functions);
  initContent = lib.concatStringsSep "\n\n" (config.shell.initContent ++ config.zsh.initContent);
in {
  options.zsh = {
    functions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "ZSH-specific functions (prefer shell.functions for portability)";
    };
    initContent = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "ZSH-specific initialization content";
    };
  };

  config = {
    programs.zsh = {
      # Core configuration for all systems
      enableCompletion = true;
      autosuggestion.enable = true;

      # Include shell-agnostic aliases
      shellAliases = config.shell.aliases;

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
