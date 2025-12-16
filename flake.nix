{
  description = "Home Manager flake for testing";

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
  };

  outputs = {
    nixpkgs,
    home-manager,
    starship-jj,
    ...
  }: let
    # Helper function to create home-manager configurations
    mkHomeConfig = system: hostFile: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib.extend (final: prev: {
        helpers = import ./lib {lib = final; inherit pkgs;};
      });
    in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs lib;

        modules = [
          {
            nixpkgs.overlays = [
              (final: prev: {
                starship-jj = starship-jj.packages.${system}.default;
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
      laptop = mkHomeConfig "aarch64-darwin" ./hosts/laptop;
    };

    # NixOS system configurations
    nixosConfigurations = {
      nas-services = nixpkgs.lib.nixosSystem {
        modules = [
          {nixpkgs.hostPlatform = "x86_64-linux";}
          # Include Home Manager as a NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Add overlays for home-manager
            nixpkgs.overlays = [starship-jj.overlays.default];
          }
          ./hosts/nas-services
        ];
      };
    };
  };
}
