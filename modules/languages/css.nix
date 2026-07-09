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
        lsp_enable("cssls", { "vscode-css-language-server", "--stdio" })
      '';
    })
  ]);
}
