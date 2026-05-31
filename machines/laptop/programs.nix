{
  helpers,
  pkgs,
  ...
}: {
  config = {
    programs = {
      home-manager.enable = true;
      zsh.enable = true;
      btop.enable = true;
      starship.enable = true;
      bat.enable = true;
      ripgrep.enable = true;
      fzf.enable = true;
      zoxide.enable = true;
      direnv.enable = true;
      tmux.enable = true;
      rclone.enable = true;
      rbw.enable = true;
      broot.enable = true; # A nicer tree view

      helix = {
        enable = true;
        toolchains = {
          python.enable = true;
          markdown.enable = true;
          just.enable = true;
          toml.enable = true;
          yaml.enable = true;
          json.enable = true;
          js.enable = true;
          nix.enable = true;
          rust.enable = true;
          go.enable = true;
        };
      };

      git = {
        enable = true;
        settings = {
          # Allow nas://<repo> paths when working with repos stored on NAS
          url."ssh://mininas.local/tank/git/" = {
            insteadOf = "nas://";
          };
        };
      };

      jujutsu.enable = true;
      gh.enable = true;
      claude-code.enable = true;
      codex.enable = true;
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

      astGrep.enable = true;
      docker.enable = true;

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

    services = {
      syncthing = {
        enable = true;

        guiAddress = "127.0.0.1:8384";
      };
    };

    customServices = {
      caddy = {
        enable = true;
        settings.caddyfile = ./Caddyfile;
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

      curlie

      # Custom scripts
      (helpers.scriptToPackage {
        name = "edit";
        file = ../../scripts/edit.sh;
      })

      cyme # List system USB buses and devices. A modern cross-platform lsusb
      ffmpeg

      # Fonts
      maple-mono.truetype
      maple-mono.NF-unhinted

      (helpers.scriptToPackage {
        name = "unlock-drive";
        file = ./scripts/unlock-drive.sh;
      })
      (helpers.scriptToPackage {
        name = "unlock-ssh";
        file = ./scripts/unlock-ssh.sh;
      })
    ];
  };
}
