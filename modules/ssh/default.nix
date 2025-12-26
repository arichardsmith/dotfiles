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
      description = "List of public key files to include in authorized_keys";
    };
  };

  setup = {cfg, ...}: {
    home.file = lib.mkIf (cfg.authorizedKeys != []) {
      ".ssh/authorized_keys".text = lib.concatStringsSep "\n" cfg.authorizedKeys;
    };
  };
}
