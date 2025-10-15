{pkgs, ...}: {
  imports = [
    # Terminal
    ../modules/ghostty
    ../modules/shell
    ../modules/erdtree
    ../modules/bat
    ../modules/zoxide

    # Version control
    ../modules/git
    ../modules/jujutsu
    ../modules/gh

    # Development tools
    ../modules/direnv
    ../modules/neovim
    ../modules/nix

    # System management
    ../modules/btop

    # App runtimes
    ../modules/colima
    (import ../modules/docker {includeLazyDocker = true;})
    ../modules/bun
  ];

  config = {
    user.username = "richardsmith";
    user.email = "richardmcsmith@gmail.com";
    user.fullName = "Richard Smith";

    home.packages = with pkgs; [
      cyme
    ];

    home.sessionPath = [
      "$HOME/.local/bin"
    ];

    home.sessionVariables = {
      # DOCKER_HOST = "unix://$HOME/.colima/docker.sock"; # Colima should manage this with contexts
      EDITOR = "nvim";
      EDITOR_UI = "zed"; # Preferred IDE / UI based editor
    };

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

    # Install custom scripts to PATH
    zsh.scripts = {
      unlock-drive = true;
    };

    shell.prompt.format =
      "[╭─ ](overlay0)$username$hostname$line_break"
      + "[├╌ ](overlay0)$directory$\{custom.jj\}$line_break"
      + "[$character ](overlay0)";

    bun.globalPackages = [
      "@anthropic-ai/claude-code"
    ];
  };
}
