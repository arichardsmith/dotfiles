{helpers, lib, pkgs, config, ...}: {
  options.programs.neovim.toolchains.js.enable = lib.mkEnableOption "js/ts toolchain";

  config = lib.mkIf (config.programs.neovim.toolchains.js.enable && config.programs.neovim.enable) {
    home.packages = with pkgs; [
      bun
      typescript-language-server
      (helpers.scriptToPackage {
        name = "ijs";
        file = ../../../scripts/ijs.sh;
      })
      (helpers.scriptToPackage {
        name = "pkq";
        file = ../../../scripts/pkq.sh;
      })
    ];

    programs.neovim.formatters.javascript = {
      name = "prettier";
      package = pkgs.prettier;
    };

    programs.neovim.formatters.javascriptreact = {
      name = "prettier";
      package = pkgs.prettier;
    };

    programs.neovim.formatters.typescript = {
      name = "prettier";
      package = pkgs.prettier;
    };

    programs.neovim.formatters.typescriptreact = {
      name = "prettier";
      package = pkgs.prettier;
    };

    programs.neovim.initLua = ''
      vim.lsp.config("ts_ls", {
        cmd = { "${lib.getExe pkgs.typescript-language-server}", "--stdio" },
      })
      vim.lsp.enable("ts_ls")
    '';
  };
}
