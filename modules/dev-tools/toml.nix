{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.devtools;
  enabled = cfg.toml.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    {
      home.packages = with pkgs; [tombi];
    }

    (lib.mkIf config.programs.helix.enable {
      programs.helix.languages = {
        language-server.tombi.command = lib.getExe pkgs.tombi;
        language = [
          {
            name = "toml";
            language-servers = ["tombi"];
            formatter = {
              command = lib.getExe pkgs.tombi;
              args = ["format"];
            };
          }
        ];
      };
    })

    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.formatters.toml = {
        name = "tombi";
        package = pkgs.tombi;
        args = ["format"];
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
