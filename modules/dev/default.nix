{pkgs, ...}: let
  # Import all language modules
  languages = [
    (import ./js.nix {inherit pkgs;})
    (import ./rust.nix {inherit pkgs;})
    (import ./go.nix {inherit pkgs;})
  ];

  # Helper to safely extract attribute with default
  getAttr = attr: default: module:
    if builtins.hasAttr attr module
    then module.${attr}
    else default;

  # Collect all packages and shellHooks
  allPackages = builtins.concatLists (map (getAttr "packages" []) languages);
  allShellHooks = builtins.concatStringsSep "\n" (map (getAttr "shellHook" "") languages);
in {
  default = {
    packages = allPackages;
    shellHook = allShellHooks;
  };
}
