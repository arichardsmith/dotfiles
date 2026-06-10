{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.devtools;
  enabled = cfg.just.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    {
      home.packages = with pkgs; [just just-lsp];
    }

    (lib.mkIf config.programs.helix.enable {
      programs.helix.languages = {
        language-server.just-lsp.command = lib.getExe pkgs.just-lsp;
        language = [
          {
            name = "just";
            language-servers = ["just-lsp"];
          }
        ];
      };
    })

    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.initLua = ''
        vim.lsp.config("just", {
          cmd = { "${lib.getExe pkgs.just-lsp}" },
        })
        vim.lsp.enable("just")
      '';
    })
  ]);
}
