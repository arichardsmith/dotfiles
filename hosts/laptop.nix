{
  config,
  pkgs,
  ...
}: let
  packagePacks = import ../modules/packages.nix {inherit pkgs;};
in {
  home.username = "richardsmith";
  home.homeDirectory = "/Users/richardsmith";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  home.packages =
    packagePacks.core
    ++ packagePacks.dev_base # Note: using dev_base here
    ++ [
      # Laptop-specific packages
    ];

  # Dotfiles
  home.file.".config/starship-jj/starship-jj.toml".source = ../config/starship/starship-jj.toml;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      format =
        "$username"
        + "$hostname"
        + "[:](bright-black)$directory"
        + "$\{custom.jj\}"
        + "$git_branch"
        + "$line_break"
        + "$character";

      right_format = "$cmd_duration";

      directory = {
        format = "[$path](bold)";
        truncation_length = 3;
        truncation_symbol = "…/";
      };

      character = {
        success_symbol = "[\\$](bold green)";
        error_symbol = "[✗](bold red)";
      };

      username = {
        format = "[$user]($style)";
        style_user = "grey";
        show_always = true;
      };

      hostname = {
        format = "[@$hostname]($style)";
        style = "grey";
        aliases = {
          "Richards-MacBook-Air" = "mac";
        };
        ssh_only = true;
      };

      git_branch = {
        format = " [g:$branch](bright-black)";
      };

      cmd_duration = {
        format = "[$duration](black)";
      };

      custom.jj = {
        command = "prompt";
        format = " [jj:](bright-black)$output";
        ignore_timeout = true;
        shell = ["starship-jj" "--ignore-working-copy" "starship"];
        use_stdin = false;
        when = true;
      };
    };
  };
}
