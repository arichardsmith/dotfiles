{pkgs, ...}: let
  packagePacks = import ../modules/packages.nix {inherit pkgs;};
  zsh_config = import ../config/zsh/zsh.nix {};
  starship_config = import ../config/starship/starship.nix {};
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

  programs.starship = lib.mkMerge [
    starship_config.base
    {
      settings = lib.mkMerge [
        starship_config.settings.base
        starship_config.settings.dev
        {
          # Host-specific overrides can go here
        }
      ];
    }
  ];
}
