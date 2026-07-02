{
  lib,
  config,
  ...
}: let
  cfg = config.programs.zsh;

  shellCfg = config.my.shell;

  commandBodies = lib.pipe shellCfg.commands [
    (lib.filterAttrs (_name: cmd: cmd.zsh != null))
    (lib.mapAttrsToList (_name: cmd: cmd.zsh))
  ];

  commandInit =
    if commandBodies == []
    then ""
    else "\n\n" + (lib.concatStringsSep "\n\n" commandBodies);
in {
  config = {
    programs.zsh = lib.mkIf cfg.enable {
      enableCompletion = true;
      autosuggestion.enable = true;

      shellAliases = shellCfg.aliases;

      initContent = ''
        # Enable vim keybindings
        bindkey -v
        ${commandInit}
      '';
    };

    programs.carapace.enableZshIntegration = true;
  };
}
