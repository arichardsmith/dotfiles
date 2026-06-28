{
  lib,
  config,
  ...
}: let
  cfg = config.programs.nushell;
in {
  config = lib.mkIf cfg.enable {
    programs.nushell = {
      settings = {
        show_banner = false;
      };
    };

    programs.carapace.enableNushellIntegration = true;
  };
}
