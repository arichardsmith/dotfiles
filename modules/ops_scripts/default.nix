{
  lib,
  config,
  helpers,
  ...
}: let
  scripts = {};

  mkPackage = name: {
    type,
    path,
  }:
    if type == "uv"
    then
      helpers.uvScriptToPackage {
        inherit name;
        file = path;
      }
    else
      helpers.scriptToPackage {
        inherit name;
        file = path;
        runtimeInputs = [];
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
