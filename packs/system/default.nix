# System Pack
# System monitoring and resource management tools.
# Includes: btop for process monitoring, ncdu for disk usage analysis.
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
