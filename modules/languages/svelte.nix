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

      programs.neovim.conform.formatters_by_ft = {
        svelte = {
          formatters = ["oxfmt" "prettier"];
          stop_after_first = true;
        };
      };

      programs.neovim.initLua = ''
        lsp_enable("svelte", { "svelteserver", "--stdio" })
      '';
    })
  ]);
}
