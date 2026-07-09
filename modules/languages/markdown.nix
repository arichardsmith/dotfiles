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
        lsp_enable("marksman", { "marksman" })
        lsp_enable("markdown_oxide", { "markdown-oxide" })
      '';
    })
  ]);
}
