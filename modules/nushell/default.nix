{
  lib,
  config,
  ...
}: let
  cfg = config.programs.nushell;

  shellCfg = config.my.shell;

  aliasLines = lib.pipe shellCfg.aliases [
    (lib.mapAttrsToList (name: value: "alias ${name} = ${value}"))
  ];

  commandBodies = lib.pipe shellCfg.commands [
    (lib.filterAttrs (_name: cmd: cmd.nushell != null))
    (lib.mapAttrsToList (_name: cmd: cmd.nushell))
  ];

  extraConfig = lib.concatStringsSep "\n\n" (aliasLines ++ commandBodies);
in {
  config = lib.mkIf cfg.enable {
    programs.nushell = {
      settings = {
        show_banner = false;
      };

      extraConfig = extraConfig;
    };

    programs.carapace.enableNushellIntegration = true;
  };
}
