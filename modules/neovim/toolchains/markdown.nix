{lib, pkgs, config, ...}: {
  options.programs.neovim.toolchains.markdown.enable = lib.mkEnableOption "markdown toolchain";

  config = lib.mkIf (config.programs.neovim.toolchains.markdown.enable && config.programs.neovim.enable) {
    home.packages = with pkgs; [marksman markdown-oxide];

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
  };
}
