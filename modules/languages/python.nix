{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.languages;
  enabled = cfg.python.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.extraPackages = with pkgs; [ruff basedpyright];

      programs.neovim.conform = {
        formatters_by_ft.python = ["ruff_format"];
      };

      programs.neovim.initLua = ''
        lsp_enable("basedpyright", { "basedpyright", "-" })
        lsp_enable("ruff", { "ruff", "server" })
      '';
    })

    (lib.mkIf config.my.programs.opencode.enable {
      my.programs.opencode.lsp.pyright = lib.mkDefault {
        command = [(lib.getExe pkgs.basedpyright) "-"];
      };
    })
  ]);
}
