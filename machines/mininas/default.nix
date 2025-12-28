{...}: {
  imports = [
    ./programs.nix
  ];

  config = {
    user.username = "richard";
    user.email = "richardmcsmith@gmail.com";
    user.fullName = "Richard Smith";

    home.sessionPath = [
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
    };

    programs.starship.settings.format =
      "[╭─ ](overlay0)$username$hostname $env_var$line_break"
      + "[├╌ ](overlay0)$directory$\{custom.jj\}$line_break"
      + "[$character ](overlay0)";
  };
}
