{
  helpers,
  machine,
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
      tmux.enable = true;
      neovim.enable = true;
      helix = {
        enable = true;
      };
    };

    my.languages = {
      python.enable = true;
      markdown.enable = true;
      just.enable = true;
      toml.enable = true;
      yaml.enable = true;
      json.enable = true;
    };

    my.programs = {
      docker.enable = true;

      erdtree = {
        enable = true;
        settings = {
          overrideLs = true;
        };
      };

      ghosttyTermInfo.enable = true;

      sanoid = {
        enable = true;
        settings.configFilePath = ./sanoid.conf;
      };
    };

    my.ai = {
      context.chunks = [
        ''
          You have access to `rg` for searching with `ripgrep` and `fd` as an alternative to `find`.
        ''
      ];
    };

    my.opsScripts = {
      rebuild = true;
      rollback = true;
    };

    services = {
      syncthing = {
        enable = true;
        guiAddress = "${machine.host.tailscale.ipv4}:8384";
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
      uv # Python package/script runner
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
      (helpers.scriptToPackage {
        name = "edit";
        file = ../../scripts/edit.sh;
      })
      (helpers.scriptToPackage {
        name = "copy";
        file = ../../scripts/copy.sh;
      })
      (helpers.scriptToPackage {
        name = "pasta";
        file = ../../scripts/pasta.sh;
      })
      (helpers.scriptToPackage {
        name = "now";
        file = ../../scripts/now.sh;
      })
      (helpers.scriptToPackage {
        name = "today";
        file = ../../scripts/today.sh;
      })
      (helpers.scriptToPackage {
        name = "plist";
        file = ../../scripts/plist.sh;
      })
    ];
  };
}
