{config, lib, pkgs, ...}: let
  cfg = config.customPrograms.devTools;
  enabled = cfg.enable && cfg.settings.json.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    {
      home.packages = with pkgs; [vscode-langservers-extracted jq];
    }

    (lib.mkIf config.programs.helix.enable {
      programs.helix.languages = {
        language-server.vscode-json-language-server = {
          command = lib.getExe' pkgs.vscode-langservers-extracted "vscode-json-language-server";
          args = ["--stdio"];
        };
        language = [
          {
            name = "json";
            language-servers = ["vscode-json-language-server"];
            formatter = {
              command = lib.getExe pkgs.jq;
              args = ["."];
            };
          }
        ];
      };
    })

    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.formatters.json = {
        name = "jq";
        package = pkgs.jq;
        args = ["."];
      };

      programs.neovim.initLua = ''
        vim.lsp.config("jsonls", {
          cmd = { "${lib.getExe' pkgs.vscode-langservers-extracted "vscode-json-language-server"}", "--stdio" },
        })
        vim.lsp.enable("jsonls")
      '';
    })
  ]);
}
