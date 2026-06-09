{lib, pkgs, config, ...}: {
  options.programs.neovim.toolchains.toml.enable = lib.mkEnableOption "toml toolchain";

  config = lib.mkIf (config.programs.neovim.toolchains.toml.enable && config.programs.neovim.enable) {
    home.packages = with pkgs; [tombi];

    programs.neovim.formatters.toml = {
      name = "tombi";
      package = pkgs.tombi;
      args = ["format"];
    };

    programs.neovim.initLua = ''
      vim.lsp.config("tombi", {
        cmd = { "${lib.getExe pkgs.tombi}" },
      })
      vim.lsp.enable("tombi")
    '';
  };
}
