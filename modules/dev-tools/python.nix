{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.devtools;
  enabled = cfg.python.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    {
      home.packages = with pkgs; [uv ruff basedpyright];
    }

    (lib.mkIf config.programs.helix.enable {
      programs.helix.languages = {
        language-server.basedpyright = {
          command = lib.getExe pkgs.basedpyright;
          args = ["-"];
        };
        language-server.ruff = {
          command = lib.getExe pkgs.ruff;
          args = ["server"];
        };
        language = [
          {
            name = "python";
            formatter = {
              command = lib.getExe pkgs.ruff;
              args = ["format" "-"];
            };
            language-servers = ["basedpyright" "ruff"];
          }
        ];
      };
    })

    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.conform = {
        formatters_by_ft.python = ["ruff_format"];
      };

      programs.neovim.initLua = ''
        vim.lsp.config("basedpyright", {
          cmd = { "${lib.getExe pkgs.basedpyright}", "-" },
        })
        vim.lsp.config("ruff", {
          cmd = { "${lib.getExe pkgs.ruff}", "server" },
        })
        vim.lsp.enable("basedpyright")
        vim.lsp.enable("ruff")
      '';
    })

    (lib.mkIf config.my.programs.opencode.enable {
      my.programs.opencode.lsp.pyright = lib.mkDefault {
        command = [ (lib.getExe pkgs.basedpyright) "-" ];
      };
    })
  ]);
}
