{
  inputs,
  common,
}: let
  machine = {
    system = "aarch64-darwin";

    user = {
      username = "richardsmith";
      email = "richardmcsmith@gmail.com";
      fullName = "Richard Smith";
    };

    host = {
      name = "mba";
    };
  };

  nix = common.mkNix machine.system;
in
  inputs.home-manager.lib.homeManagerConfiguration {
    inherit (nix) pkgs lib;

    extraSpecialArgs = {
      inherit machine;
      helpers = nix.helpers;
    };

    modules = [
      (common.mkHomeManager machine)
      ./home.nix
      ./programs.nix
      ./backup.nix
    ];
  }
