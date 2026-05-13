{
  lib,
  pkgs,
  ...
}: let
  toolchains = {
    js = {
      packages = with pkgs; [
        bun
        (lib.helpers.scriptToPackage {
          name = "ijs";
          file = ../../scripts/ijs.sh;
        })
        (lib.helpers.scriptToPackage {
          name = "pkq";
          file = ../../scripts/pkq.sh;
        })
      ];

      home.sessionPath = [
        "$HOME/.bun/bin"
      ];
    };

    nix = {
      programs.nh.enable = true;

      packages = with pkgs; [
        nixd
      ];
    };

    python = {
      packages = with pkgs; [
        uv
      ];
    };

    markdown = {
      packages = with pkgs; [
        marksman
        markdown-oxide
      ];
    };

    other = {
      programs = {
        git.enable = true;
        jujutsu.enable = true;
        gh.enable = true;
        claude-code.enable = true;
      };

      customPrograms = {
        astGrep.enable = true;
        docker.enable = true;
      };

      packages = with pkgs; [
        curlie
        just
        just-lsp
      ];
    };
  };
in {
  config = lib.helpers.applyDevToolchains toolchains;
}
