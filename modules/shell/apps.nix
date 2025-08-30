{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [
      # Network utilities
      curl
      dig
      nmap
      rsync

      # File utilities
      ripgrep # Better grep
      fd # Better find

      # Compression
      unzip
      gzip

      # System monitoring
      htop
      ncdu # Disk usage analyzer
    ];
  };
}
