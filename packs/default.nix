{lib, ...}: {
  options.packs = {
    shell.enable = lib.mkEnableOption "shell pack (terminal utilities, zsh, starship, bat)";
    system.enable = lib.mkEnableOption "system monitoring pack (btop etc)";
    dev.enable = lib.mkEnableOption "dev pack (git, jujutsu, gh, docker)";
    server.enable = lib.mkEnableOption "server pack (shpool, docker etc)";
  };

  imports = [
    ./shell
    ./system
    ./dev
    ./server
  ];
}
