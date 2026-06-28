{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.languages;
  enabled = cfg.lua.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.extraPackages = with pkgs; [lua-language-server stylua];

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