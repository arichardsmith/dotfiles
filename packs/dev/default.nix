{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.packs.dev;
in {
  imports = [
    ./js.nix
    ./nix.nix
  ];

  config = lib.mkIf cfg.enable {
    programs = {
      # Version control
      git.enable = true;
      jujutsu.enable = true;
      gh.enable = true;
    };

    customPrograms = {
      astGrep.enable = true;
      docker.enable = true;
    };

    home.packages = with pkgs; [
      just
      just-lsp
    ];
  };
}
