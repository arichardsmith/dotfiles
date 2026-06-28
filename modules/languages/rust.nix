{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.languages;
  enabled = cfg.rust.enable;
in {
  config = lib.mkIf enabled (lib.mkMerge [
    (lib.mkIf config.programs.neovim.enable {
      programs.neovim.extraPackages = with pkgs; [rust-analyzer];

      programs.neovim.initLua = ''
        vim.lsp.config("rust_analyzer", {
          cmd = { "${lib.getExe pkgs.rust-analyzer}" },
          settings = { ["rust-analyzer"] = { check = { command = "clippy" } } },
        })
        vim.lsp.enable("rust_analyzer")
      '';
    })

    (lib.mkIf config.my.programs.opencode.enable {
      my.programs.opencode.lsp.rust = lib.mkDefault {
        command = [(lib.getExe pkgs.rust-analyzer)];
      };
    })
  ]);
}