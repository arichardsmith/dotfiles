{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.devtools;
  enabled = cfg.yaml.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    {
      home.packages = with pkgs; [yaml-language-server yamlfmt];
    }

    (lib.mkIf config.programs.helix.enable {
      programs.helix.languages = {
        language-server.yaml-language-server.command = lib.getExe pkgs.yaml-language-server;
        language = [
          {
            name = "yaml";
            language-servers = ["yaml-language-server"];
            formatter.command = lib.getExe pkgs.yamlfmt;
          }
        ];
      };
    })

    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.formatters.yaml = {
        name = "yamlfmt";
        package = pkgs.yamlfmt;
      };

      programs.neovim.initLua = ''
        vim.lsp.config("yamlls", {
          cmd = { "${lib.getExe pkgs.yaml-language-server}", "--stdio" },
        })
        vim.lsp.enable("yamlls")
      '';
    })
  ]);
}
