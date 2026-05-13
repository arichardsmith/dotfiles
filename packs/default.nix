{lib, ...}: {
  options.packs = {
    shell.enable = lib.mkEnableOption "shell pack (terminal utilities, zsh, starship, bat)";
    system.enable = lib.mkEnableOption "system monitoring pack (btop etc)";
    server.enable = lib.mkEnableOption "server pack (shpool, docker etc)";
  };

  imports = [
    ./shell
    ./system
    ./server
  ];
}
