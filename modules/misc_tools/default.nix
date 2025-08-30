{
  lib,
  config,
  pkgs,
  ...
}: let
  isDevelopment = lib.elem "development" config.host.role;
  isServer = lib.elem "server" config.host.role;

  coreTools = with pkgs; [
    curl
    wget

    ripgrep # Better grep
    fd # Better find

    # Compression
    unzip
    gzip
  ];

  networkingTools = lib.optionals (isDevelopment || isServer) (with pkgs; [
    dig
    nmap
    rsync
  ]);

  dockerTools = lib.optionals (isDevelopment || isServer) (with pkgs; [
    docker
    docker-compose
  ]);

  systemMonitoring = lib.optionals isServer (with pkgs; [
    htop
    iotop
    ncdu # Disk usage analyzer
  ]);
in {
  config = {
    home.packages = coreTools ++ networkingTools ++ dockerTools ++ systemMonitoring;
  };
}
