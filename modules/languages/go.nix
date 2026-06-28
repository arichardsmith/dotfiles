{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.languages;
  enabled = cfg.go.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.extraPackages = with pkgs; [gopls];

      programs.neovim.conform = {
        formatters_by_ft.go = ["gofmt"];
      };

      programs.neovim.initLua = ''
        vim.lsp.config("gopls", {
          cmd = { "${lib.getExe pkgs.gopls}" },
          settings = {
            gopls = {
              staticcheck = true;
            },
          },
        })
        vim.lsp.enable("gopls")
      '';
    })

    (lib.mkIf config.my.programs.opencode.enable {
      my.programs.opencode.lsp.gopls = lib.mkDefault {
        command = [(lib.getExe pkgs.gopls)];
      };
    })
  ]);
}