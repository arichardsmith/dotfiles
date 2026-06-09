{config, lib, pkgs, ...}: let
  cfg = config.customPrograms.devTools;
  enabled = cfg.enable && cfg.settings.markdown.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    {
      home.packages = with pkgs; [marksman markdown-oxide];
    }

    (lib.mkIf config.programs.helix.enable {
      programs.helix.languages = {
        language-server.marksman.command = lib.getExe pkgs.marksman;
        language-server.markdown-oxide.command = lib.getExe pkgs.markdown-oxide;
        language = [
          {
            name = "markdown";
            language-servers = ["marksman" "markdown-oxide"];
          }
        ];
      };
    })

    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.initLua = ''
        vim.lsp.config("marksman", {
          cmd = { "${lib.getExe pkgs.marksman}" },
        })
        vim.lsp.config("markdown_oxide", {
          cmd = { "${lib.getExe pkgs.markdown-oxide}" },
        })
        vim.lsp.enable("marksman")
        vim.lsp.enable("markdown_oxide")
      '';
    })
  ]);
}
