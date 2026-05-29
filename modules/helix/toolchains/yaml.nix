{
  lib,
  pkgs,
  config,
  ...
}: {
  options.programs.helix.toolchains.yaml.enable = lib.mkEnableOption "yaml toolchain";

  config = lib.mkIf (config.programs.helix.toolchains.yaml.enable && config.programs.helix.enable) {
    home.packages = with pkgs; [yaml-language-server yamlfmt];

    programs.helix.languages = {
      language-server.yaml-language-server.command = lib.getExe pkgs.yaml-language-server;

      language = [
        {
          name = "yaml";
          auto-format = true;
          language-servers = ["yaml-language-server"];
          formatter.command = lib.getExe pkgs.yamlfmt;
        }
      ];
    };
  };
}
