{...}: {
  imports = [
    ./programs.nix
    ./backup.nix
  ];

  config = {
    home.sessionPath = ["$HOME/.local/bin"];

    home.sessionVariables = {
      DOTFILE_MACHINE = "laptop";
      EDITOR = "hx";
      EDITOR_UI = "zed"; # Preferred IDE / UI based editor
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

    programs.starship.settings.format =
      "[╭─ ](overlay0)$username$hostname $env_var$line_break"
      + "[├╌ ](overlay0)$directory$\{custom.jj\}$line_break"
      + "[$character ](overlay0)";
  };
}
