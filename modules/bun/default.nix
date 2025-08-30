{
  lib,
  config,
  pkgs,
  ...
}: let
  # Combine all global packages from other modules
  allGlobalPackages = lib.unique config.bun.globalPackages;
  globalPackagesString = lib.concatStringsSep " " allGlobalPackages;
in {
  options.bun = {
    globalPackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Global packages to install with bun";
    };
  };

  config = {
    home.packages = with pkgs; [
      bun
    ];

    # Install global packages declaratively
    home.activation.bunGlobalPackages = lib.mkIf (allGlobalPackages != []) ''
      # Install or update global packages
      ${pkgs.bun}/bin/bun install -g ${globalPackagesString}
    '';

    # Allow globally installed bun packages to be run as commands
    home.sessionPath = [
      "$HOME/.bun/bin"
    ];
  };
}
