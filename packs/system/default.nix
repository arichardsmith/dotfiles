{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.packs.system;
in {
  config = lib.mkIf cfg.enable {
    programs = {
      btop.enable = true;
    };

    customPrograms = {
    };

    home.packages = with pkgs; [
      ncdu # Disk usage analyzer
    ];
  };
}
