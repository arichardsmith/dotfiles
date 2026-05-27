{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./dev.nix
  ];

  config = {
    # Enable packs
    packs = {
      shell.enable = true;
      system.enable = true;
    };

    programs = {
      direnv.enable = true;
      neovim.enable = true;
      helix.enable = true;
      tmux.enable = true;
      rclone.enable = true;
      rbw.enable = true;
      broot.enable = true; # A nicer tree view

      git.settings = {
        # Allow nas://<repo> paths when working with repos stored on NAS
        url."ssh://mininas.local/tank/git/" = {
          insteadOf = "nas://";
        };
      };
    };

    customPrograms = {
      ghostty.enable = true;
      colima = {
        enable = true;
        settings = {
          cpu = 4;
          memory = 3;
          disk = 60;
          arch = "aarch64";
        };
      };
      ai-agent = {
        enable = true;
        settings = {
          claude-code.enable = true;
          opencode = {
            enable = true;
            model = "openai/gpt-5.5";
            autoupdate = "notify";
            theme = "system";

            agents = {
              plan.model = "openai/gpt-5.5";
              build.model = "openrouter/deepseek/deepseek-v4-flash";
            };
          };
        };
      };
    };

    home.packages = with pkgs; [
      cyme # List system USB buses and devices. A modern cross-platform lsusb
      caddy # Used to handle .localhost domains
      ffmpeg

      # Fonts
      maple-mono.truetype
      maple-mono.NF-unhinted

      (lib.helpers.scriptToPackage {
        name = "unlock-drive";
        file = ./scripts/unlock-drive.sh;
      })
      (lib.helpers.scriptToPackage {
        name = "unlock-ssh";
        file = ./scripts/unlock-ssh.sh;
      })
    ];
  };
}
