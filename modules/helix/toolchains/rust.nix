{
  lib,
  pkgs,
  config,
  ...
}: {
  options.programs.helix.toolchains.rust.enable = lib.mkEnableOption "rust toolchain";

  config = lib.mkIf (config.programs.helix.toolchains.rust.enable && config.programs.helix.enable) {
    home.packages = with pkgs; [rustup bacon];

    home.sessionVariables = {
      RUSTUP_HOME = "$HOME/.rustup";
      CARGO_HOME = "$HOME/.cargo";
    };

    home.sessionPath = ["$HOME/.cargo/bin"];

    programs.helix.languages = {
      language-server.rust-analyzer.command = lib.getExe pkgs.rust-analyzer;

      language = [
        {
          name = "rust";
          auto-format = true;
          language-servers = ["rust-analyzer"];
        }
      ];
    };
  };
}
