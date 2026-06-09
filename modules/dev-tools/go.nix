{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.customPrograms.devTools;
  enabled = cfg.enable && cfg.settings.go.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    {
      home.packages = with pkgs; [go gopls golangci-lint air];
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
      programs.neovim.formatters.go = {
        name = "gofmt";
        package = pkgs.go;
        exeName = "gofmt";
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
  ]);
}
