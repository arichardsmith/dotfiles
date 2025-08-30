{
  description = "Bun CLI development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {nixpkgs}: let
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        just
        bun
        typescript
      ];

      shellHook = ''
        if [ -f package.json ] && [ ! -d node_modules ]; then
          echo "Installing dependencies..."
          bun install
        fi
      '';
    };
  };
}
