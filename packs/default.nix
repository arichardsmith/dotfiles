{lib, ...}: {
  options.packs = {
    shell.enable = lib.mkEnableOption "shell pack (terminal utilities, zsh, starship, bat)";
    system.enable = lib.mkEnableOption "system monitoring pack (btop etc)";
    dev.enable = lib.mkEnableOption "dev pack (git, jujutsu, gh, docker)";
  };

  imports = [
    ./shell
    ./system
    ./dev
  ];
}
