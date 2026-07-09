{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.languages;
  enabled = cfg.json.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    {
      home.packages = with pkgs; [jq];
    }

    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.extraPackages = with pkgs; [vscode-langservers-extracted];

      programs.neovim.conform = {
        formatters_by_ft.json = ["jq"];
      };

      programs.neovim.initLua = ''
        lsp_enable("jsonls", { "vscode-json-language-server", "--stdio" })
      '';
    })
  ]);
}
