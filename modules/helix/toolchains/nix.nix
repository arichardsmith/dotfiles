{
  lib,
  pkgs,
  config,
  ...
}: {
  options.programs.helix.toolchains.nix.enable = lib.mkEnableOption "nix toolchain";

  config = lib.mkIf (config.programs.helix.toolchains.nix.enable && config.programs.helix.enable) {
    programs.nh.enable = true;

    home.packages = with pkgs; [nixd alejandra];

    programs.helix.languages = {
      language-server.nixd.command = lib.getExe pkgs.nixd;

      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = lib.getExe pkgs.alejandra;
          language-servers = ["nixd"];
        }
      ];
    };
  };
}
