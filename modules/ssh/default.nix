{
  config,
  pkgs,
  lib,
  ...
}:
lib.helpers.mkProgram {inherit config pkgs;} "sshKeys" {
  settings = {
    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of public keys to include in authorized_keys";
    };

    authorizedKeyPaths = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [];
      description = "List of paths to public key files to include in authorized_keys";
    };
  };

  setup = {cfg, ...}: let
    keysFromPaths = map builtins.readFile cfg.settings.authorizedKeyPaths;
    allKeys = cfg.settings.authorizedKeys ++ keysFromPaths;
  in {
    home.file = lib.mkIf (allKeys != []) {
      ".ssh/authorized_keys".text = lib.concatStringsSep "\n" allKeys;
    };
  };
}
