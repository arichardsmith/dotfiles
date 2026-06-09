{lib, pkgs, config, ...}: {
  options.programs.neovim.toolchains.just.enable = lib.mkEnableOption "just toolchain";

  config = lib.mkIf (config.programs.neovim.toolchains.just.enable && config.programs.neovim.enable) {
    home.packages = with pkgs; [just just-lsp];

    programs.neovim.initLua = ''
      vim.lsp.config("just", {
        cmd = { "${lib.getExe pkgs.just-lsp}" },
      })
      vim.lsp.enable("just")
    '';
  };
}
