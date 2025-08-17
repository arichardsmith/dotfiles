{
  lib,
  config,
  pkgs,
  ...
}: let
  user = config.user;
in {
  imports = [
    ../modules/zsh
    ../modules/jujutsu
    ../modules/starship
  ];

  options.user = {
    username = lib.mkOption {
      type = lib.types.str;
      description = "The username for this host";
    };
    homeDirectory = lib.mkOption {
      type = lib.types.str;
      default =
        if pkgs.stdenv.isDarwin
        then "/Users/${config.user.username}"
        else "/home/${config.user.username}";
      description = "The home directory for this user";
    };
    email = lib.mkOption {
      type = lib.types.str;
      description = "The email address for this user. Will be used by git and jujutsu";
    };
    fullName = lib.mkOption {
      type = lib.types.str;
      description = "The full name for this user";
    };
  };

  options.host = {
    role = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [
        "development"
        "server"
      ]);
      default = [];
      description = "Roles this host performs. This will be used to configure packages and programs.";
    };
  };

  config = {
    home.username = user.username;
    home.homeDirectory = user.homeDirectory;
    home.stateVersion = "24.05";

    programs.home-manager.enable = true;
  };
}
