{lib, pkgs, config, ...}: {
  options.programs.neovim.toolchains.nix.enable = lib.mkEnableOption "nix toolchain";

  config = lib.mkIf (config.programs.neovim.toolchains.nix.enable && config.programs.neovim.enable) {
    programs.nh.enable = true;

    home.packages = with pkgs; [nixd alejandra];

    programs.neovim.formatters.nix = {
      name = "alejandra";
      package = pkgs.alejandra;
    };

    programs.neovim.initLua = ''
      vim.lsp.config("nixd", {
        cmd = { "${lib.getExe pkgs.nixd}" },
      })
      vim.lsp.enable("nixd")
    '';
  };
}
