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

    snitch = {
      url = "github:karol-broda/snitch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode = {
      url = "github:anomalyco/opencode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    starship-jj,
    snitch,
    opencode,
    ...
  }: let
    configurations = import ./lib/configurations.nix {
      inherit nixpkgs home-manager starship-jj snitch opencode;
    };
  in {
    homeConfigurations = configurations.mkHomeConfigs {
      laptop = ./machines/laptop;
      mininas = ./machines/mininas;
    };

    nixosConfigurations = configurations.mkNixosConfigs {
      example = ./machines/example;
    };
  };
}
