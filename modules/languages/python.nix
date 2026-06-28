{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.languages;
  enabled = cfg.python.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.extraPackages = with pkgs; [ruff basedpyright];

      programs.neovim.conform = {
        formatters_by_ft.python = ["ruff_format"];
      };

      programs.neovim.initLua = ''
        vim.lsp.config("basedpyright", {
          cmd = { "${lib.getExe pkgs.basedpyright}", "-" },
        })
        vim.lsp.config("ruff", {
          cmd = { "${lib.getExe pkgs.ruff}", "server" },
        })
        vim.lsp.enable("basedpyright")
        vim.lsp.enable("ruff")
      '';
    })

    (lib.mkIf config.my.programs.opencode.enable {
      my.programs.opencode.lsp.pyright = lib.mkDefault {
        command = [(lib.getExe pkgs.basedpyright) "-"];
      };
    })
  ]);
}