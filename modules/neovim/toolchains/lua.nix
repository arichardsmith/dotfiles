{lib, pkgs, config, ...}: {
  options.programs.neovim.toolchains.lua.enable = lib.mkEnableOption "lua toolchain";

  config = lib.mkIf (config.programs.neovim.toolchains.lua.enable && config.programs.neovim.enable) {
    home.packages = with pkgs; [lua-language-server stylua];

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
  };
}
