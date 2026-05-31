{
  config,
  pkgs,
  lib,
  ...
}:
lib.helpers.mkService {inherit config pkgs;} "caddy" {
  settings = {
    caddyfile = lib.mkOption {
      type = lib.types.either lib.types.path lib.types.lines;
      description = "Caddyfile content or a path to a Caddyfile.";
    };
  };

  service = {
    config,
    pkgs,
    cfg,
    ...
  }: let
    caddyfile =
      if builtins.isPath cfg.settings.caddyfile
      then cfg.settings.caddyfile
      else pkgs.writeText "Caddyfile" cfg.settings.caddyfile;
  in {
    description = "Caddy web server";
    command = [
      "${pkgs.caddy}/bin/caddy"
      "run"
      "--config"
      "${caddyfile}"
      "--adapter"
      "caddyfile"
    ];
    environment = {};
    workingDirectory = config.home.homeDirectory;
    restart = true;
    logDirectory = "${config.home.homeDirectory}/.local/log";
    extraConfig = {
      home.packages = [pkgs.caddy];
    };
  };
}
