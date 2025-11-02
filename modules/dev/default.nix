{pkgs, ...}: let
  # Import all language modules
  languages = [
    (import ./js.nix {inherit pkgs;})
    (import ./rust.nix {inherit pkgs;})
    (import ./go.nix {inherit pkgs;})
    (import ./nix.nix {inherit pkgs;})
    (import ./tools.nix {inherit pkgs;})
  ];

  # Helper to safely extract attribute with default
  getAttr = attr: default: module:
    if builtins.hasAttr attr module
    then module.${attr}
    else default;

  # Convert scripts to packages
  scriptsToPackages = scripts:
    builtins.attrValues (builtins.mapAttrs
      (name: path: pkgs.writeShellScriptBin name (builtins.readFile path))
      scripts);

  # Collect all packages and shellHooks
  allPackages = builtins.concatLists (map (getAttr "packages" []) languages);
  allScripts = builtins.concatLists (map (lang: scriptsToPackages (getAttr "scripts" {} lang)) languages);
  allShellHooks = builtins.concatStringsSep "\n" (map (getAttr "shellHook" "") languages);
in {
  default = {
    packages = allPackages ++ allScripts;
    shellHook = allShellHooks;
  };
}
