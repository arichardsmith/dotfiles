{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.languages;
  enabled = cfg.just.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.extraPackages = with pkgs; [just-lsp];

      programs.neovim.initLua = ''
        vim.lsp.config("just", {
          cmd = { "${lib.getExe pkgs.just-lsp}" },
        })
        vim.lsp.enable("just")
      '';
    })
  ]);
}