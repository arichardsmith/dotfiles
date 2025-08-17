# modules/starship/default.nix
{
  lib,
  config,
  pkgs,
  ...
}: let
  isDevelopment = lib.elem "development" config.host.role;

  # Base starship configuration for all systems
  baseSettings = {
    format =
      "$username"
      + "$hostname"
      + "[:](bright-black)$directory"
      + "$line_break"
      + "$character";

    right_format = "$cmd_duration";

    directory = {
      format = "[$path]($style)";
      style = "bold bright-blue";
      repo_root_style = "bold bright-blue";
      before_repo_root_style = "white";
      truncation_length = 2;
      truncation_symbol = "…/";
      truncate_to_repo = false;
    };

    character = {
      success_symbol = "[\\$](bold green)";
      error_symbol = "[✗](bold red)";
    };

    username = {
      format = "[$user@]($style)";
      style_user = "white";
      # show_always = true;
    };

    hostname = {
      format = "[$hostname]($style)";
      style = "white";
      ssh_only = false;
    };

    cmd_duration = {
      format = "[$duration](black)";
    };
  };

  # Development-specific settings
  devSettings = lib.optionalAttrs isDevelopment {
    format =
      "$username"
      + "$hostname"
      + "[:](bright-black)$directory"
      + "$\{custom.jj\}"
      + "$line_break"
      + "$character";

    custom.jj = {
      command = "starship-jj --ignore-working-copy starship prompt";
      format = " [jj:$output](bright-black)";
      ignore_timeout = true;
      # Only show if we are in a jj repo
      when = "jj --ignore-working-copy root";
    };
  };
in {
  config = {
    programs.starship = {
      enable = true;
      settings = baseSettings // devSettings;
    };

    home.packages = lib.optionals isDevelopment [
      pkgs.starship-jj
    ];

    home.file = lib.optionalAttrs isDevelopment {
      ".config/starship-jj/starship-jj.toml".source = ./starship-jj.toml;
    };
  };
}
