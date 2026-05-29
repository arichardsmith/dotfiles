{
  lib,
  pkgs,
  config,
  ...
}: {
  options.programs.helix.toolchains.just.enable = lib.mkEnableOption "just toolchain";

  config = lib.mkIf (config.programs.helix.toolchains.just.enable && config.programs.helix.enable) {
    home.packages = with pkgs; [just just-lsp];

    programs.helix.languages = {
      language-server.just-lsp.command = lib.getExe pkgs.just-lsp;

      language = [
        {
          name = "just";
          language-servers = ["just-lsp"];
        }
      ];
    };
  };
}
