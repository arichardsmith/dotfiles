{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.devtools;
  enabled = cfg.lua.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    {
      home.packages = with pkgs; [lua-language-server stylua];
    }

    (lib.mkIf config.programs.helix.enable {
      programs.helix.languages = {
        language-server.lua-language-server.command = lib.getExe pkgs.lua-language-server;
        language = [
          {
            name = "lua";
            formatter.command = lib.getExe pkgs.stylua;
            language-servers = ["lua-language-server"];
          }
        ];
      };
    })

    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.conform = {
        formatters_by_ft.lua = ["stylua"];
      };

      programs.neovim.initLua = ''
        vim.lsp.config("lua_ls", {
          cmd = { "${lib.getExe pkgs.lua-language-server}" },
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = { enable = false },
            },
          },
        })
        vim.lsp.enable("lua_ls")
      '';
    })

    (lib.mkIf config.my.programs.opencode.enable {
      my.programs.opencode.lsp.lua-ls = lib.mkDefault {
        command = [(lib.getExe pkgs.lua-language-server)];
      };
    })
  ]);
}
