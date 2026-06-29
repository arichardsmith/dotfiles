{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.languages;
  enabled = cfg.css.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.extraPackages = with pkgs; [vscode-langservers-extracted];

      programs.neovim.initLua = ''
        vim.lsp.config("cssls", {
          cmd = { "${lib.getExe' pkgs.vscode-langservers-extracted "vscode-css-language-server"}", "--stdio" },
        })
        vim.lsp.enable("cssls")
      '';
    })
  ]);
}
