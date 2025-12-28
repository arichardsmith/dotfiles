{
  description = "Home manager flake for my machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    starship-jj = {
      url = "gitlab:lanastara_foss/starship-jj";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snitch.url = "github:karol-broda/snitch";
  };

  outputs = {
    nixpkgs,
    home-manager,
    starship-jj,
    snitch,
    ...
  }: let
    # Helper function to create home-manager configurations
    mkHomeConfig = system: hostFile: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg:
          builtins.elem (lib.getName pkg) [
            "claude-code"
          ];
      };

      lib = pkgs.lib.extend (final: prev: {
        helpers = import ./lib {
          lib = final;
          inherit pkgs;
        };
      });
    in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs lib;

        modules = [
          {
            nixpkgs.overlays = [
              (final: prev: {
                starship-jj = starship-jj.packages.${system}.default;
                snitch = snitch.packages.${system}.default;
              })
            ];
          }
          ./home.nix
          hostFile
        ];
      };
  in {
    # Standalone Home Manager configurations (macOS)
    homeConfigurations = {
      laptop = mkHomeConfig "aarch64-darwin" ./machines/laptop;
      mininas = mkHomeConfig "x86_64-linux" ./machines/mininas;
    };
  };
}
