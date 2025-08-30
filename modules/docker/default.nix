{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [
      docker
      docker-compose
    ];

    zsh.aliases = {
      dc = "docker compose";
    };
  };
}
