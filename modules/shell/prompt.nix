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

        palette = "catppuccin_mocha";

        palettes.catppuccin_mocha = {
          rosewater = "#f5e0dc";
          flamingo = "#f2cdcd";
          pink = "#f5c2e7";
          mauve = "#cba6f7";
          red = "#f38ba8";
          maroon = "#eba0ac";
          peach = "#fab387";
          yellow = "#f9e2af";
          green = "#a6e3a1";
          teal = "#94e2d5";
          sky = "#89dceb";
          sapphire = "#74c7ec";
          blue = "#89b4fa";
          lavender = "#b4befe";
          text = "#cdd6f4";
          subtext1 = "#bac2de";
          subtext0 = "#a6adc8";
          overlay2 = "#9399b2";
          overlay1 = "#7f849c";
          overlay0 = "#6c7086";
          surface2 = "#585b70";
          surface1 = "#45475a";
          surface0 = "#313244";
          base = "#1e1e2e";
          mantle = "#181825";
          crust = "#11111b";
        };

        directory = {
          format = "[$path]($style)";
          style = "bold blue";
          repo_root_style = "bold blue";
          before_repo_root_style = "text";
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
          style_user = "text";
        };

        hostname = {
          format = "[$hostname]($style)";
          style = "text";
          ssh_only = false;
        };

        cmd_duration = {
          format = "[$duration](overlay0)";
        };
      } // lib.optionalAttrs jjEnabled {
        custom.jj = {
          command = "starship-jj --ignore-working-copy starship prompt";
          format = " [jj:$output](overlay1)";
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