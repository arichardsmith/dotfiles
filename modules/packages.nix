{pkgs, ...}: {
  # Core utilities that go everywhere
  core = with pkgs; [
    # Shell and terminal
    zsh
    starship
    erdtree # ls alternative

    # Essential tools
    git
    curl
    wget
    htop
    tree

    # Text processing
    ripgrep # Better grep
    fd # Better find
    bat # Better cat

    # Compression
    unzip
    gzip

    # Editors
    neovim

    # Networking Tools
    dig
    nmap
  ];

  # Language specific features will be defined in dev env flakes which inherit these packages.
  # As such, dev_base should be limited to universal development packages.
  dev_base = with pkgs; [
    # Docker
    docker
    docker-compose

    # Jujutsu version control
    jujutsu
    starship-jj
  ];

  # Server-specific tools
  server = with pkgs; [
    # Docker
    docker
    docker-compose

    # System monitoring
    iotop
    nethogs

    # Network services
    rsync

    # File system tools
    ncdu # Disk usage analyzer
  ];
}
