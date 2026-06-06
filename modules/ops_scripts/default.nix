{
  lib,
  config,
  helpers,
  ...
}: let
  scripts = {
    rebuild = {
      type = "shell";
      path = ./scripts/rebuild.sh;
    };

    rollback = {
      type = "shell";
      path = ./scripts/rollback.sh;
    };
  };

  mkPackage = name: {
    type,
    path,
    runtimeInputs ? [],
  }:
    if type == "uv"
    then
      helpers.uvScriptToPackage {
        inherit name runtimeInputs;
        file = path;
      }
    else
      helpers.scriptToPackage {
        inherit name runtimeInputs;
        file = path;
      };
in {
  options.my.opsScripts = lib.mapAttrs (name: _: lib.mkEnableOption name) scripts;

  config = lib.mkMerge (lib.mapAttrsToList (
      name: script:
        lib.mkIf config.my.opsScripts.${name} {
          home.file."ops/${name}" = {
            source = "${mkPackage name script}/bin/${name}";
            executable = true;
          };
        }
    )
    scripts);
}
