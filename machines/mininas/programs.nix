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

    customPrograms = {
      devTools = {
        enable = true;
        settings = {
          python.enable = true;
          markdown.enable = true;
          just.enable = true;
          toml.enable = true;
          yaml.enable = true;
          json.enable = true;
        };
      };

      docker.enable = true;

      erdtree = {
        enable = true;
        settings = {
          overrideLs = true;
        };
      };

      ai-agent.settings.context.chunks = [
        ''
          You have access to `rg` for searching with `ripgrep` and `fd` as an alternative to `find`.
        ''
      ];

      ghosttyTermInfo.enable = true;

      sanoid = {
        enable = true;
        settings.configFilePath = ./sanoid.conf;
      };
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
    ];
  };
}
