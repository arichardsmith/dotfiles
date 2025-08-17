{
  lib,
  config,
  ...
}: let
  isDevelopment = lib.elem "development" config.host.role;
in {
  config = lib.mkIf isDevelopment {
    # Install and configure the github cli only in development
    programs.gh = {
      enable = true;
    };
  };
}
