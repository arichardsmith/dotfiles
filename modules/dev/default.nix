{pkgs, ...}: let
  scriptToPackage = import ../../lib/script_to_package.nix {inherit pkgs;};
in {
  imports = [
    ./nix.nix
    ./ast-grep.nix
    ./just.nix
    ./js.nix
  ];

  config = {
    home.packages = [
      (scriptToPackage "dev-env" ./scripts/dev-env.sh)
    ];
  };
}
