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
    authorizedKeysFile = pkgs.writeText "authorized_keys" (lib.concatStringsSep "\n" allKeys);
  in {
    home.activation = lib.mkIf (allKeys != []) {
      copyAuthorizedKeys = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p $HOME/.ssh
        $DRY_RUN_CMD chmod 700 $HOME/.ssh
        $DRY_RUN_CMD cp ${authorizedKeysFile} $HOME/.ssh/authorized_keys
        $DRY_RUN_CMD chmod 600 $HOME/.ssh/authorized_keys
      '';
    };
  };
}
