{
  config,
  helpers,
  pkgs,
  lib,
  ...
}:
helpers.mkProgram {inherit config pkgs;} "docker" {
  settings = {
    compose = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  setup = {
    pkgs,
    cfg,
    ...
  }: {
    home.packages = [pkgs.docker] ++ lib.optional cfg.settings.compose pkgs.docker-compose;

    my.shell.aliases = lib.mkIf cfg.settings.compose {
      "dc" = "docker compose";
    };
  };
}
