{
  lib,
  config,
  machine,
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
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      programs.nushell = {
        settings = {
          show_banner = false;
        };

        extraConfig = extraConfig;
      };

      programs.carapace.enableNushellIntegration = true;
    }
    (lib.mkIf (machine.nixDarwin or false) {
      # nix-darwin installs Home Manager packages into its per-user profile.
      programs.nushell.extraEnv = ''
        $env.PATH = (
          $env.PATH
          | prepend '/etc/profiles/per-user/${config.home.username}/bin'
        )
      '';
    })
  ]);
}
