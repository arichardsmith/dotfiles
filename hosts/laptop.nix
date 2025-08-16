{pkgs, ...}: let
  packagePacks = import ../modules/packages.nix {inherit pkgs;};
  zsh_config = import ../config/zsh/zsh.nix {};
  lib = pkgs.lib;
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

  programs.zsh = lib.mkMerge [
    zsh_config.base
    {
      enable = true;
      shellAliases = lib.mkMerge [
        zsh_config.aliases.core
        zsh_config.aliases.dev
        {
          tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
        }
      ];

      initContent = lib.concatStringsSep "\n" [
        zsh_config.init.base
        zsh_config.functions.dev
        ''
          # Ensure docker can find the vm running in .colima
          export DOCKER_HOST="unix://$HOME/.colima/docker.sock"
        ''
      ];
    }
  ];

  programs.starship = {
    enable = true;
    settings = {
      format =
        "$username"
        + "$hostname"
        + "[:](bright-black)$directory"
        + "$\{custom.jj\}"
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
        aliases = {
          "Richards-MacBook-Air" = "mac";
        };
        ssh_only = false;
      };

      cmd_duration = {
        format = "[$duration](black)";
      };

      custom.jj = {
        command = ''starship-jj --ignore-working-copy starship prompt'';
        format = " [jj:$output](bright-black)";
        ignore_timeout = true;
        # Only show if we are in a jj repo
        when = "jj --ignore-working-copy root";
      };
    };
  };
}
