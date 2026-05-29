{
  pkgs,
  lib,
  ...
}: {
  config = {
    programs = {
      zsh.enable = true;
      btop.enable = true;
      starship.enable = true;
      bat.enable = true;
      ripgrep.enable = true;
      fzf.enable = true;
      zoxide.enable = true;
      helix.enable = true;
      tmux.enable = true;
    };

    customPrograms = {
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

      sshKeys = {
        enable = true;
        settings.authorizedKeyPaths = [
          ../../ssh_keys/laptop.pub
        ];
      };

      ghosttyTermInfo.enable = true;

      sanoid = {
        enable = true;
        settings.configFilePath = ./sanoid.conf;
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

      shpool # Lightweight session persistence
    ];
  };
}
