{
  lib,
  config,
  pkgs,
  ...
}: let
  isDevelopment = lib.elem "development" config.host.role;
  isServer = lib.elem "server" config.host.role;
in {
  config = lib.mkIf (isDevelopment || isServer) {
    home.packages = with pkgs; [
      docker
      docker-compose
    ];

    zsh.aliases = {
      dc = "docker compose";
    };
  };
}
