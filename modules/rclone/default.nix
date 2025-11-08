{
  config,
  lib,
  ...
}: {
  options.rclone.remotes = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          config = lib.mkOption {
            type = with lib.types; attrsOf (nullOr (oneOf [bool int float str]));
            default = {};
          };

          secrets = lib.mkOption {
            type = with lib.types; attrsOf str;
            default = {};
          };

          mounts = lib.mkOption {
            type = with lib.types;
              attrsOf (submodule {
                options = {
                  enable = lib.mkEnableOption "this mount";
                  mountPoint = lib.mkOption {type = str;};
                  options = lib.mkOption {
                    type = attrsOf (nullOr (oneOf [bool int float str]));
                    default = {};
                  };
                  # add logLevel if needed
                };
              });
            default = {};
          };
        };
      }
    );
    default = {};
  };

  config.programs.rclone = {
    enable = true;
    remotes = config.rclone.remotes;
  };
}
