{lib, pkgs, config, ...}: {
  options.programs.neovim.toolchains.rust.enable = lib.mkEnableOption "rust toolchain";

  config = lib.mkIf (config.programs.neovim.toolchains.rust.enable && config.programs.neovim.enable) {
    home.packages = with pkgs; [rustup bacon];

    home.sessionVariables = {
      RUSTUP_HOME = "$HOME/.rustup";
      CARGO_HOME = "$HOME/.cargo";
    };

    home.sessionPath = ["$HOME/.cargo/bin"];

    programs.neovim.initLua = ''
      vim.lsp.config("rust_analyzer", {
        cmd = { "${lib.getExe pkgs.rust-analyzer}" },
        settings = { ["rust-analyzer"] = { check = { command = "clippy" } } },
      })
      vim.lsp.enable("rust_analyzer")
    '';
  };
}
