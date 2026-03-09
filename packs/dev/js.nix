# Sets up a default JS runtime, currently bun
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
      bun # Bun is my current global JS runtime of choice
      (lib.helpers.scriptToPackage {name = "ijs"; file = ./scripts/ijs.sh;})
      (lib.helpers.scriptToPackage {name = "pkq"; file = ./scripts/pkq.sh;})
    ];

    # Add globally installed bun packages to the PATH
    home.sessionPath = [
      "$HOME/.bun/bin"
    ];
  };
}
