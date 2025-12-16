{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.starship;

  defaultFormat =
    "[╭─](overlay0) $username$hostname[/](overlay0)$directory$line_break"
    + "[$character ](overlay0)";
in {
  config = {
    programs.starship = {
      settings = lib.mkIf cfg.enable {
        format = lib.mkDefault defaultFormat;

        right_format = "[$cmd_duration](overlay0)";

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
          format = "[$path ]($style)";
          style = "bold teal";
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
          style_user = "subtext0";
        };

        hostname = {
          format = "[$hostname]($style)";
          style = "subtext0";
          ssh_only = false;
          aliases = {
            "Richards-MacBook-Air" = "mac";
          };
        };

        cmd_duration = {
          format = "$duration";
        };

        env_var.DEV_ENV = {
          variable = "DEV_ENV_ACTIVE";
          format = "[dev]($style) ";
          style = "bold yellow";
        };

        env_var.DIRENV_DIR = {
          variable = "DIRENV_DIR";
          format = "[dev]($style) ";
          style = "bold yellow";
        };

        custom.jj = lib.mkIf config.programs.jujutsu.enable {
          command = "starship-jj --ignore-working-copy starship prompt";
          format = "[$output](overlay1)";
          ignore_timeout = true;
          # Only show if we are in a jj repo
          when = "jj --ignore-working-copy root";
        };
      };
    };

    home.packages = lib.optional config.programs.jujutsu.enable pkgs.starship-jj;

    # Ensure starship-jj config is copied across
    home.file.".config/starship-jj/starship-jj.toml" = lib.mkIf config.programs.jujutsu.enable {
      source = ./starship-jj.toml;
    };
  };
}
