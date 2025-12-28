# Server Pack
# Tools that are useful on remote servers.
# Includes: shpool for detaching shell sessions
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.packs.server;

  linuxOnlyPackages = with pkgs;
    lib.optionals (lib.elem pkgs.system ["aarch64-linux" "i686-linux" "x86_64-linux"]) [
      shpool # A more light weight tmux
    ];
in {
  config = lib.mkIf cfg.enable {
    customPrograms = {
      docker.enable = true;
    };

    home.packages =
      [
      ]
      ++ linuxOnlyPackages;
  };
}
