{...}: {
  imports = [
    ./base.nix
  ];

  config = {
    user.username = "richardsmith";
    user.email = "richardmcsmith@gmail.com";
    user.fullName = "Richard Smith";
    host.role = ["development"];

    home.sessionVariables = {
      DOCKER_HOST = "unix://$HOME/.colima/docker.sock";
      EDITOR = "nvim";
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
