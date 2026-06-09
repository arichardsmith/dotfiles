{config, helpers, lib, pkgs, ...}: let
  cfg = config.customPrograms.devTools;
  enabled = cfg.enable && cfg.settings.js.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    {
      home.packages = with pkgs; [
        bun
        typescript-language-server
        (helpers.scriptToPackage {
          name = "ijs";
          file = ../../scripts/ijs.sh;
        })
        (helpers.scriptToPackage {
          name = "pkq";
          file = ../../scripts/pkq.sh;
        })
      ];

      home.sessionPath = ["$HOME/.bun/bin"];
    }

    (lib.mkIf config.programs.helix.enable {
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
    })

    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.initLua = ''
        vim.lsp.config("ts_ls", {
          cmd = { "${lib.getExe pkgs.typescript-language-server}", "--stdio" },
        })
        vim.lsp.enable("ts_ls")
      '';
    })
  ]);
}
