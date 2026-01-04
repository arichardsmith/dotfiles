{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.packs.dev;
in {
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # We don't include python as we want uv to manage the python versions itself
      uv
    ];
  };
}
