{
  config,
  helpers,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.devtools;
  enabled = cfg.js.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    {
      home.packages = with pkgs; [
        bun
        typescript-language-server
        oxfmt
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
      # Conform prefers the project-local node_modules/.bin/oxfmt, but that bin
      # still uses /usr/bin/env node; force the Nix-wrapped binary so Neovim
      # does not need Node on PATH, while still resolving repo-local config.
      programs.neovim.conform.formatters.oxfmt = {
        "inherit" = true;
        command = lib.getExe' pkgs.oxfmt "oxfmt";
        cwd = lib.generators.mkLuaInline ''
          require("conform.util").root_file({
            ".oxfmtrc.json",
            ".oxfmtrc.jsonc",
            "oxfmt.config.ts",
            "package.json",
          })
        '';
      };

      programs.neovim.conform.formatters_by_ft = {
        javascript = {
          formatters = ["prettier" "oxfmt"];
          stop_after_first = true;
        };
        javascriptreact = {
          formatters = ["prettier" "oxfmt"];
          stop_after_first = true;
        };
        typescript = {
          formatters = ["prettier" "oxfmt"];
          stop_after_first = true;
        };
        typescriptreact = {
          formatters = ["prettier" "oxfmt"];
          stop_after_first = true;
        };
      };

      programs.neovim.initLua = ''
        vim.lsp.config("ts_ls", {
          cmd = { "${lib.getExe pkgs.typescript-language-server}", "--stdio" },
        })
        vim.lsp.enable("ts_ls")
      '';
    })

    (lib.mkIf config.my.programs.opencode.enable {
      my.programs.opencode.lsp.typescript = lib.mkDefault {
        command = [ (lib.getExe pkgs.typescript-language-server) "--stdio" ];
      };
    })
  ]);
}
