{
  lib,
  pkgs,
}: {
  mkProgram = import ./program.nix {inherit lib;};
  scriptToPackage = import ./script_to_package.nix {inherit pkgs;};
  applyDevToolchains = import ./apply_dev_toolchains.nix {inherit lib;};
}
