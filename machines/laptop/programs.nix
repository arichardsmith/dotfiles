{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./dev.nix
  ];

  config = {
    programs = {
      zsh.enable = true;
      btop.enable = true;
      starship.enable = true;
      bat.enable = true;
      ripgrep.enable = true;
      fzf.enable = true;
      zoxide.enable = true;
      direnv.enable = true;
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
      erdtree = {
        enable = true;
        settings = {
          overrideLs = true;
        };
      };

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

          context.chunks = [
            ''
              You have access to `rg` for searching with `ripgrep` and `fd` as an alternative to `find`.
            ''
          ];
        };
      };
    };

    home.packages = with pkgs; [
      # Network utilities
      curl
      dig
      nmap
      rsync
      mtr # Trace route

      # Utility Apps
      fd # Better find
      sd # Better sed
      just # Better make
      duf # Better df
      snitch # Better netstat
      procs # Better ps

      # Compression
      unzip
      gzip

      # Encryption
      age

      # System monitoring
      ncdu # Disk usage analyzer

      # Custom scripts
      (lib.helpers.scriptToPackage {
        name = "edit";
        file = ../../scripts/edit.sh;
      })

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
