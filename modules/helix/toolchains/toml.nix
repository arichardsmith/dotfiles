{
  lib,
  pkgs,
  config,
  ...
}: {
  options.programs.helix.toolchains.toml.enable = lib.mkEnableOption "toml toolchain";

  config = lib.mkIf (config.programs.helix.toolchains.toml.enable && config.programs.helix.enable) {
    home.packages = with pkgs; [tombi];

    programs.helix.languages = {
      language-server.tombi.command = lib.getExe pkgs.tombi;

      language = [
        {
          name = "toml";
          language-servers = ["tombi"];
          formatter = {
            command = lib.getExe pkgs.tombi;
            args = ["format"];
          };
        }
      ];
    };
  };
}
