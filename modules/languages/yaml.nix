{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.languages;
  enabled = cfg.yaml.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.extraPackages = with pkgs; [yaml-language-server yamlfmt];

      programs.neovim.conform = {
        formatters_by_ft.yaml = ["yamlfmt"];
      };

      programs.neovim.initLua = ''
        lsp_enable("yamlls", { "yaml-language-server", "--stdio" })
      '';
    })

    (lib.mkIf config.my.programs.opencode.enable {
      my.programs.opencode.lsp.yaml-ls = lib.mkDefault {
        command = [(lib.getExe pkgs.yaml-language-server) "--stdio"];
      };
    })
  ]);
}
