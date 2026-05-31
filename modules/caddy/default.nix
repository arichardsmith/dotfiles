{
  config,
  pkgs,
  lib,
  ...
}:
lib.helpers.mkProgram {inherit config pkgs;} "caddy" {
  settings = {
    caddyfile = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.path lib.types.lines);
      default = null;
      description = "Caddyfile content or a path to a Caddyfile.";
    };
  };

  setup = {
    pkgs,
    cfg,
    ...
  }: {
    # Include the package
    home.packages = [pkgs.caddy];

    xdg.configFile."caddy/Caddyfile" = lib.mkIf (cfg.settings.caddyfile != null) (
      if builtins.isPath cfg.settings.caddyfile
      then {
        source = cfg.settings.caddyfile;
      }
      else {
        text = cfg.settings.caddyfile;
      }
    );
  };
}
