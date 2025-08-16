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
  }: {
    homeConfigurations = {
      laptop = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          overlays = [starship-jj.overlays.default];
        };
        modules = [./hosts/laptop.nix];
      };
    };
  };
}
