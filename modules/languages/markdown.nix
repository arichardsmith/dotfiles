{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.languages;
  enabled = cfg.markdown.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.extraPackages = with pkgs; [marksman markdown-oxide];

      programs.neovim.initLua = ''
        vim.lsp.config("marksman", {
          cmd = { "${lib.getExe pkgs.marksman}" },
        })
        vim.lsp.config("markdown_oxide", {
          cmd = { "${lib.getExe pkgs.markdown-oxide}" },
        })
        vim.lsp.enable("marksman")
        vim.lsp.enable("markdown_oxide")
      '';
    })
  ]);
}