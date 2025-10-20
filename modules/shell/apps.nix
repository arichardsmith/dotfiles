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
      just # Better make

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
