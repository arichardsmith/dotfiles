{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.languages;
  enabled = cfg.toml.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.extraPackages = with pkgs; [tombi];

      programs.neovim.conform = {
        formatters_by_ft.toml = ["tombi"];
      };

      programs.neovim.initLua = ''
        vim.lsp.config("tombi", {
          cmd = { "${lib.getExe pkgs.tombi}" },
        })
        vim.lsp.enable("tombi")
      '';
    })
  ]);
}