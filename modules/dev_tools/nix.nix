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
      nixd
    ];
  };
}
