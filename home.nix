# home.nix - Main home configuration
{
  lib,
  config,
  pkgs,
  ...
}: {
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
    name = lib.mkOption {
      type = lib.types.str;
      description = "The name for this host";
    };
  };

  config = {
    home.username = config.user.username;
    home.homeDirectory = config.user.homeDirectory;
    home.stateVersion = "24.05";

    programs.home-manager.enable = true;
  };
}
