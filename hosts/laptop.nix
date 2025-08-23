{...}: {
  imports = [
    ./base.nix
  ];

  config = {
    user.username = "richardsmith";
    user.email = "richardmcsmith@gmail.com";
    user.fullName = "Richard Smith";

    host.name = "laptop";
    host.role = ["development"];

    home.sessionVariables = {
      DOCKER_HOST = "unix://$HOME/.colima/docker.sock";
      EDITOR = "nvim";
      EDITOR_UI = "zed"; # Prefered IDE / UI based editor
    };

    zsh.aliases = {
      tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
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

    programs.starship.settings = {
      hostname = {
        aliases = {
          "Richards-MacBook-Air" = "mac";
        };
      };
    };
  };
}
