{
  lib,
  config,
  pkgs,
  ...
}: let
  isDevelopment = lib.elem "development" config.host.role;
in {
  config = lib.mkIf isDevelopment {
    home.packages = with pkgs; [
      bun # Primary runtime
      pnpm # All projects are managed with pnpm
      nodejs # Keep Node.js for compatibility
    ];

    # Allow globally installed bun packages to be run as commands
    home.sessionPath = [
      "$HOME/.bun/bin"
    ];
  };
}
