{lib, pkgs, config, ...}: {
  options.programs.neovim.toolchains.json.enable = lib.mkEnableOption "json toolchain";

  config = lib.mkIf (config.programs.neovim.toolchains.json.enable && config.programs.neovim.enable) {
    home.packages = with pkgs; [vscode-langservers-extracted jq];

    programs.neovim.formatters.json = {
      name = "jq";
      package = pkgs.jq;
      args = ["."];
    };

    programs.neovim.initLua = ''
      vim.lsp.config("jsonls", {
        cmd = { "${lib.getExe' pkgs.vscode-langservers-extracted "vscode-json-language-server"}", "--stdio" },
      })
      vim.lsp.enable("jsonls")
    '';
  };
}
