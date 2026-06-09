{lib, pkgs, config, ...}: {
  options.programs.neovim.toolchains.python.enable = lib.mkEnableOption "python toolchain";

  config = lib.mkIf (config.programs.neovim.toolchains.python.enable && config.programs.neovim.enable) {
    home.packages = with pkgs; [uv ruff basedpyright];

    programs.neovim.formatters.python = {
      name = "ruff_format";
      package = pkgs.ruff;
    };

    programs.neovim.initLua = ''
      vim.lsp.config("basedpyright", {
        cmd = { "${lib.getExe pkgs.basedpyright}", "--stdio" },
      })
      vim.lsp.config("ruff", {
        cmd = { "${lib.getExe pkgs.ruff}", "server" },
      })
      vim.lsp.enable("basedpyright")
      vim.lsp.enable("ruff")
    '';
  };
}
