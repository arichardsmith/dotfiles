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
      # nix language server
      nixd
    ];

    # Install the `nh` cli globally to help manage nix
    programs.nh = {
      enable = true;
    };
  };
}
