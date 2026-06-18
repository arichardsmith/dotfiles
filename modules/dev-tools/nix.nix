{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.devtools;
  enabled = cfg.nix.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    {
      programs.nh.enable = true;

      home.packages = with pkgs; [nixd alejandra];
    }

    (lib.mkIf config.programs.helix.enable {
      programs.helix.languages = {
        language-server.nixd.command = lib.getExe pkgs.nixd;
        language = [
          {
            name = "nix";
            formatter.command = lib.getExe pkgs.alejandra;
            language-servers = ["nixd"];
          }
        ];
      };
    })

    (lib.mkIf config.programs.neovim.enable {
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
