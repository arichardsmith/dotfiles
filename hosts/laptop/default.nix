{pkgs, ...}: let
  scriptToPackage = import ../../lib/script_to_package.nix {inherit pkgs;};
in {
  imports = [
    # Terminal
    ../../modules/ghostty
    ../../modules/shell
    ../../modules/erdtree
    ../../modules/bat
    ../../modules/zoxide

    # Version control
    ../../modules/git
    ../../modules/jujutsu
    ../../modules/gh

    # Development tools
    ../../modules/direnv
    ../../modules/neovim
    ../../modules/dev

    # System management
    ../../modules/btop

    # Apps
    ../../modules/rclone
    ../../modules/bitwarden
    ../../modules/qqqa

    # App runtimes
    ../../modules/colima
    ../../modules/docker
  ];

  config = {
    user.username = "richardsmith";
    user.email = "richardmcsmith@gmail.com";
    user.fullName = "Richard Smith";

    home.packages = with pkgs; [
      cyme # List system USB buses and devices. A modern cross-platform lsusb
      caddy # Used to handle .localhost domains
      ffmpeg
      monitorcontrol # Allows managing external monitor brightness
      devenv

      (scriptToPackage "unlock-drive" ./scripts/unlock-drive.sh)
      (scriptToPackage "unlock-ssh" ./scripts/unlock-ssh.sh)
    ];

    home.sessionPath = [
      "$HOME/.local/bin"
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
      EDITOR_UI = "zed"; # Preferred IDE / UI based editor
    };

    docker.lazyDocker.enable = true;

    zsh.aliases = {
    };

    # Updating macos can clobber the nix additions to /etc/zshrc, so make sure they are added
    # to the user .zshrc
    zsh.initContent = [
      ''
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
            . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
      ''
    ];

    shell.prompt.format =
      "[╭─ ](overlay0)$username$hostname $env_var$line_break"
      + "[├╌ ](overlay0)$directory$\{custom.jj\}$line_break"
      + "[$character ](overlay0)";
  };
}
