{
  lib,
  pkgs,
}: {
  mkProgram = import ./program.nix {inherit lib;};
  mkService = import ./service.nix {inherit lib;};
  scriptToPackage = import ./script_to_package.nix {inherit pkgs;};
  uvScriptToPackage = import ./uv_script_to_package.nix {inherit pkgs;};
}
