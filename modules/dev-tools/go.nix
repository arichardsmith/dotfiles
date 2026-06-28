{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.devtools;
  enabled = cfg.go.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    {
      home.packages = with pkgs; [gopls golangci-lint air];
    }

    (lib.mkIf config.programs.helix.enable {
      programs.helix.languages = {
        language-server.gopls = {
          command = lib.getExe pkgs.gopls;
          config = {
            "ui.diagnostic.staticcheck" = true;
          };
        };
        language = [
          {
            name = "go";
            formatter = {
              command = lib.getExe' pkgs.go "gofmt";
            };
            language-servers = ["gopls"];
          }
        ];
      };
    })

    (lib.mkIf config.programs.neovim.enable {
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
