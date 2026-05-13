{
  lib,
  pkgs,
  ...
}: let
  toolchains = {
    js = {
      packages = with pkgs; [
        bun
        typescript-language-server

        (lib.helpers.scriptToPackage {
          name = "ijs";
          file = ../../scripts/ijs.sh;
        })
        (lib.helpers.scriptToPackage {
          name = "pkq";
          file = ../../scripts/pkq.sh;
        })
      ];

      programs.helix.languages = {
        language-server.typescript-language-server = {
          command = lib.getExe pkgs.typescript-language-server;
          args = ["--stdio"];
        };

        language = [
          {
            name = "javascript";
            language-servers = ["typescript-language-server"];
          }
          {
            name = "typescript";
            language-servers = ["typescript-language-server"];
          }
          {
            name = "jsx";
            language-servers = ["typescript-language-server"];
          }
          {
            name = "tsx";
            language-servers = ["typescript-language-server"];
          }
        ];
      };

      home.sessionPath = [
        "$HOME/.bun/bin"
      ];
    };

    nix = {
      programs.nh.enable = true;

      packages = with pkgs; [
        nixd
        alejandra
      ];

      programs.helix.languages = {
        language-server.nixd = {
          command = lib.getExe pkgs.nixd;
        };

        language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = lib.getExe pkgs.alejandra;
            language-servers = ["nixd"];
          }
        ];
      };
    };

    python = {
      packages = with pkgs; [
        uv
        ruff
        basedpyright
      ];

      programs.helix.languages = {
        language-server = {
          basedpyright = {
            command = lib.getExe pkgs.basedpyright;
            args = ["--stdio"];
          };
          ruff = {
            command = lib.getExe pkgs.ruff;
            args = ["server"];
          };
        };

        language = [
          {
            name = "python";
            auto-format = true;
            formatter = {
              command = lib.getExe pkgs.ruff;
              args = ["format" "-"];
            };
            language-servers = ["basedpyright" "ruff"];
          }
        ];
      };
    };

    markdown = {
      packages = with pkgs; [
        marksman
        markdown-oxide
      ];

      programs.helix.languages = {
        language-server = {
          marksman.command = lib.getExe pkgs.marksman;
          markdown-oxide.command = lib.getExe pkgs.markdown-oxide;
        };

        language = [
          {
            name = "markdown";
            language-servers = ["marksman" "markdown-oxide"];
          }
        ];
      };
    };

    just = {
      packages = with pkgs; [
        just
        just-lsp
      ];

      programs.helix.languages = {
        language-server.just-lsp.command = lib.getExe pkgs.just-lsp;

        language = [
          {
            name = "just";
            language-servers = ["just-lsp"];
          }
        ];
      };
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
      ];
    };
  };
in {
  config = lib.helpers.applyDevToolchains toolchains;
}
