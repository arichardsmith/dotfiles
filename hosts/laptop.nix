{...}: {
  imports = [
    # Terminal
    ../modules/ghostty
    ../modules/shell
    ../modules/erdtree
    ../modules/bat

    # Version control
    ../modules/git
    ../modules/jujutsu
    ../modules/gh

    # App runtimes
    ../modules/colima
    ../modules/docker
    ../modules/bun
  ];

  config = {
    user.username = "richardsmith";
    user.email = "richardmcsmith@gmail.com";
    user.fullName = "Richard Smith";

    host.name = "macbook-laptop";
    host.role = ["development"];

    home.sessionVariables = {
      # DOCKER_HOST = "unix://$HOME/.colima/docker.sock"; # Colima should manage this with contexts
      EDITOR = "nvim";
      EDITOR_UI = "zed"; # Preferred IDE / UI based editor
    };

    zsh.aliases = {
      tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
    };

    # A function to init project dev environments in their own shell
    zsh.functions = [
      ''
        function pdev() {
            if [[ ! -f flake.nix ]]; then
                echo "No flake.nix found in current directory"
                return 1
            fi

            zsh -c "eval \"\$(nix print-dev-env | grep -v LINENO)\"; exec zsh"
        }
      ''
    ];

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

    bun.globalPackages = [
      "@anthropic-ai/claude-code"
    ];
  };
}
