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
  };

  outputs = {
    nixpkgs,
    js-pkgs,
    home-manager,
    starship-jj,
    snitch,
    mise,
    ...
  }: let
    configurations = import ./lib/configurations.nix {
      inherit nixpkgs js-pkgs home-manager starship-jj snitch mise;
    };
  in {
    homeConfigurations = configurations.mkHomeConfigs {
      mba = ./machines/mba;
      mininas = ./machines/mininas;
    };

    nixosConfigurations = configurations.mkNixosConfigs {
      example = ./machines/example;
    };
  };
}
