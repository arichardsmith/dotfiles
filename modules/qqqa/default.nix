{pkgs, ...}: {
  config = {
    home.packages = [
      (pkgs.callPackage ./qqqa_package.nix {})
    ];
  };
}
