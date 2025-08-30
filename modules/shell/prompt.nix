# modules/shell/prompt.nix
{
  lib,
  config,
  pkgs,
  ...
}: let
  jjEnabled = config.shell.starship.enableJJ or false;
  
  baseFormat = 
    "$username"
    + "$hostname"
    + "[:](bright-black)$directory";
    
  formatWithJJ = baseFormat + "$\{custom.jj\}";
  
  finalFormat = (if jjEnabled then formatWithJJ else baseFormat) + "$line_break" + "$character";
in {
  options.shell.starship = {
    enableJJ = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable JJ (Jujutsu) integration in starship prompt";
    };
  };

  config = {
    programs.starship = {
      enable = true;
      settings = {
        format = finalFormat;

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
        };

        hostname = {
          format = "[$hostname]($style)";
          style = "white";
          ssh_only = false;
        };

        cmd_duration = {
          format = "[$duration](black)";
        };
      } // lib.optionalAttrs jjEnabled {
        custom.jj = {
          command = "starship-jj --ignore-working-copy starship prompt";
          format = " [jj:$output](bright-black)";
          ignore_timeout = true;
          # Only show if we are in a jj repo
          when = "jj --ignore-working-copy root";
        };
      };
    };

    # Install starship-jj package when JJ integration is enabled
    home.packages = lib.optionals jjEnabled [
      pkgs.starship-jj
    ];

    home.file = lib.optionalAttrs jjEnabled {
      ".config/starship-jj/starship-jj.toml".source = ./starship-jj.toml;
    };
  };
}