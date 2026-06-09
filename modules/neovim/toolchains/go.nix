{lib, pkgs, config, ...}: {
  options.programs.neovim.toolchains.go.enable = lib.mkEnableOption "go toolchain";

  config = lib.mkIf (config.programs.neovim.toolchains.go.enable && config.programs.neovim.enable) {
    home.packages = with pkgs; [go gopls golangci-lint air];

    programs.neovim.initLua = ''
      vim.lsp.config("gopls", {
        cmd = { "${lib.getExe pkgs.gopls}" },
        settings = {
          gopls = {
            staticcheck = true;
          },
        },
      })
      vim.lsp.enable("gopls")
    '';
  };
}
