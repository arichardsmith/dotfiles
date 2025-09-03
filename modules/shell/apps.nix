{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [
      # Network utilities
      curl
      dig
      nmap
      rsync

      # Utility Apps
      ripgrep # Better grep
      fd # Better find
      sd # Better sed

      # Compression
      unzip
      gzip

      # System monitoring
      htop
      ncdu # Disk usage analyzer
    ];
  };
}
