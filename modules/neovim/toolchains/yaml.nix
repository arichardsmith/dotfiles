{lib, pkgs, config, ...}: {
  options.programs.neovim.toolchains.yaml.enable = lib.mkEnableOption "yaml toolchain";

  config = lib.mkIf (config.programs.neovim.toolchains.yaml.enable && config.programs.neovim.enable) {
    home.packages = with pkgs; [yaml-language-server yamlfmt];

    programs.neovim.formatters.yaml = {
      name = "yamlfmt";
      package = pkgs.yamlfmt;
    };

    programs.neovim.initLua = ''
      vim.lsp.config("yamlls", {
        cmd = { "${lib.getExe pkgs.yaml-language-server}", "--stdio" },
      })
      vim.lsp.enable("yamlls")
    '';
  };
}
