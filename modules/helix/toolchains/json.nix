{
  lib,
  pkgs,
  config,
  ...
}: {
  options.programs.helix.toolchains.json.enable = lib.mkEnableOption "json toolchain";

  config = lib.mkIf (config.programs.helix.toolchains.json.enable && config.programs.helix.enable) {
    home.packages = with pkgs; [vscode-langservers-extracted jq];

    programs.helix.languages = {
      language-server.vscode-json-language-server = {
        command = lib.getExe' pkgs.vscode-langservers-extracted "vscode-json-language-server";
        args = ["--stdio"];
      };

      language = [
        {
          name = "json";
          language-servers = ["vscode-json-language-server"];
          formatter = {
            command = lib.getExe pkgs.jq;
            args = ["."];
          };
        }
      ];
    };
  };
}
