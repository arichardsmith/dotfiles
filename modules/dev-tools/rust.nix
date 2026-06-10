{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.devtools;
  enabled = cfg.rust.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    {
      home.packages = with pkgs; [rustup bacon];

      home.sessionVariables = {
        RUSTUP_HOME = "$HOME/.rustup";
        CARGO_HOME = "$HOME/.cargo";
      };

      home.sessionPath = ["$HOME/.cargo/bin"];
    }

    (lib.mkIf config.programs.helix.enable {
      programs.helix.languages = {
        language-server.rust-analyzer.command = lib.getExe pkgs.rust-analyzer;
        language = [
          {
            name = "rust";
            language-servers = ["rust-analyzer"];
          }
        ];
      };
    })

    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.initLua = ''
        vim.lsp.config("rust_analyzer", {
          cmd = { "${lib.getExe pkgs.rust-analyzer}" },
          settings = { ["rust-analyzer"] = { check = { command = "clippy" } } },
        })
        vim.lsp.enable("rust_analyzer")
      '';
    })
  ]);
}
