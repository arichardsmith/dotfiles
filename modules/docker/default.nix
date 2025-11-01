{
  config,
  lib,
  pkgs,
  ...
}: {
  options.docker.lazyDocker.enable = lib.mkEnableOption "lazy docker";

  config = {
    home.packages = with pkgs; [
      docker
      docker-compose
    ];

    zsh.aliases = {
      dc = "docker compose";
    };

    programs.lazydocker = {
      enable = config.docker.lazyDocker.enable;
    };
  };
}
