{includeLazyDocker ? false}: {
  pkgs,
  ...
}: {
  config = {
    home.packages = with pkgs; [
      docker
      docker-compose
    ];

    zsh.aliases = {
      dc = "docker compose";
    };

    programs.lazydocker = {
      enable = includeLazyDocker;
    };
  };
}
