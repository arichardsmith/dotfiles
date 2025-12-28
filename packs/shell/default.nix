# Shell Pack
# Terminal utilities, shell configuration, and CLI tools for interactive use.
# Includes: zsh, starship, bat, ripgrep, fzf, zoxide, fd, sd, network utilities.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.packs.shell;
in {
  config = lib.mkIf cfg.enable {
    programs = {
      zsh.enable = true;
      starship.enable = true;

      bat.enable = true;
      ripgrep.enable = true;
      fzf.enable = true;
      zoxide.enable = true;
    };

    customPrograms = {
      erdtree = {
        enable = true;
        settings = {
          overrideLs = true;
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

      # Compression
      unzip
      gzip

      # Encryption
      age
    ];
  };
}
