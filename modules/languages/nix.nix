{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.languages;
  enabled = cfg.nix.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.extraPackages = with pkgs; [nixd alejandra];

      programs.neovim.conform = {
        formatters_by_ft.nix = ["alejandra"];
      };

      programs.neovim.initLua = ''
        vim.lsp.config("nixd", {
          cmd = { "${lib.getExe pkgs.nixd}" },
        })
        vim.lsp.enable("nixd")
      '';
    })

    (lib.mkIf config.my.programs.opencode.enable {
      my.programs.opencode.lsp.nixd = lib.mkDefault {
        command = [(lib.getExe pkgs.nixd)];
      };
    })
  ]);
}