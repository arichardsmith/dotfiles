{config, lib, pkgs, ...}: let
  cfg = config.customPrograms.devTools;
  enabled = cfg.enable && cfg.settings.lua.enable;
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
      programs.neovim.formatters.lua = {
        name = "stylua";
        package = pkgs.stylua;
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
  ]);
}
