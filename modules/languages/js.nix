{
  config,
  helpers,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.languages;
  enabled = cfg.js.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.extraPackages = with pkgs; [typescript-language-server oxfmt];

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
        command = [(lib.getExe pkgs.typescript-language-server) "--stdio"];
      };
    })
  ]);
}