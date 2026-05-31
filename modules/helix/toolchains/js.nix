{
  helpers,
  lib,
  pkgs,
  config,
  ...
}: {
  options.programs.helix.toolchains.js.enable = lib.mkEnableOption "js/ts toolchain";

  config = lib.mkIf (config.programs.helix.toolchains.js.enable && config.programs.helix.enable) {
    home.packages = with pkgs; [
      bun
      typescript-language-server
      (helpers.scriptToPackage {
        name = "ijs";
        file = ../../../scripts/ijs.sh;
      })
      (helpers.scriptToPackage {
        name = "pkq";
        file = ../../../scripts/pkq.sh;
      })
    ];

    home.sessionPath = ["$HOME/.bun/bin"];

    programs.helix.languages = {
      language-server.typescript-language-server = {
        command = lib.getExe pkgs.typescript-language-server;
        args = ["--stdio"];
      };

      language = [
        {
          name = "javascript";
          language-servers = ["typescript-language-server"];
        }
        {
          name = "typescript";
          language-servers = ["typescript-language-server"];
        }
        {
          name = "jsx";
          language-servers = ["typescript-language-server"];
        }
        {
          name = "tsx";
          language-servers = ["typescript-language-server"];
        }
      ];
    };
  };
}
