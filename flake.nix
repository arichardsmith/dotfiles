{
  description = "Home manager flake for my machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    js-pkgs = {
      url = "path:./pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    starship-jj = {
      url = "gitlab:lanastara_foss/starship-jj";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snitch = {
      url = "github:karol-broda/snitch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mise = {
      url = "github:jdx/mise";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    js-pkgs,
    home-manager,
    starship-jj,
    snitch,
    mise,
    ...
  }: let
    common = import ./lib/machine.nix {
      inherit nixpkgs js-pkgs home-manager starship-jj snitch mise;
    };
  in {
    homeConfigurations.mba = import ./machines/mba {
      inherit inputs common;
    };

    homeConfigurations.mininas = import ./machines/mininas {
      inherit inputs common;
    };

    nixosConfigurations.example = import ./machines/example {
      inherit inputs common;
    };

  };
}
