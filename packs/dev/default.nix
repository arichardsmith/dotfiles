# Dev Pack
# Development tools and version control for software engineering.
# Includes: git, jujutsu, gh, docker, ast-grep, just, and language-specific tools.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.packs.dev;
in {
  imports = [
    ./js.nix
    ./nix.nix
    ./python.nix
  ];

  config = lib.mkIf cfg.enable {
    programs = {
      # Version control
      git.enable = true;
      jujutsu.enable = true;
      gh.enable = true;

      # AI Help
      claude-code.enable = true;
    };

    customPrograms = {
      astGrep.enable = true;
      docker.enable = true;
    };

    home.packages = with pkgs; [
      just
      just-lsp
    ];
  };
}
