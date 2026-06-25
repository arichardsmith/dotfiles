{
  description = "External js packages";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    forAllSystems = nixpkgs.lib.genAttrs ["aarch64-darwin" "x86_64-linux"];
  in {
    packages = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      oxfmt = pkgs.callPackage ./oxfmt.nix {};
      claude-code = pkgs.callPackage ./claude-code.nix {};
      opencode = pkgs.callPackage ./opencode.nix {};
      nub = pkgs.callPackage ./nub.nix {};
    });

    lib = let
      system = "aarch64-darwin";
      pkgSet = self.packages.${system};
    in {
      toolMeta = {
        oxfmt = pkgSet.oxfmt.passthru.pkgMeta;
        "claude-code" = pkgSet.claude-code.passthru.pkgMeta;
        opencode = pkgSet.opencode.passthru.pkgMeta;
        nub = pkgSet.nub.passthru.pkgMeta;
      };
    };
  };
}
