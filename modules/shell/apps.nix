{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [
      # Network utilities
      curl
      curlie
      dig
      nmap
      rsync
      mtr # Trace route

      # Utility Apps
      ripgrep # Better grep
      fd # Better find
      sd # Better sed
      just # Better make
      duf # Better df
      fzf

      # Compression
      unzip
      gzip

      # Encryption
      age

      # System monitoring
      htop
      ncdu # Disk usage analyzer
    ];
  };
}
