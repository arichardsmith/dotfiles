{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.languages;
  enabled = cfg.svelte.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.extraPackages = with pkgs; [svelte-language-server];

      programs.neovim.initLua = ''
        lsp_enable("svelte", { "svelte-language-server", "--stdio" })
      '';
    })
  ]);
}
