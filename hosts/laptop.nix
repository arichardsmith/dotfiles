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
    };

    zsh.aliases = {
      tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
    };

    programs.starship.settings = {
      hostname = {
        aliases = {
          "Richards-MacBook-Air" = "mac";
        };
      };
    };
  };
}
