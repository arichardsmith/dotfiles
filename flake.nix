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
    mkHomeConfig = system: hostFile:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          overlays = [starship-jj.overlays.default];
        };
        modules = [
          ./home.nix
          hostFile
        ];
      };

    # Helper to create devShells for each system
    mkDevShells = system: let
      pkgs = import nixpkgs {
        inherit system;
      };
      devEnv = import ./modules/dev {inherit pkgs;};
    in {
      default = pkgs.mkShell {
        packages = devEnv.default.packages;
        shellHook = devEnv.default.shellHook;
      };
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

    # Dev environments
    devShells = {
      x86_64-linux = mkDevShells "x86_64-linux";
      aarch64-darwin = mkDevShells "aarch64-darwin";
    };
  };
}
