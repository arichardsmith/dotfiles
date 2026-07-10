{
  inputs,
  common,
}: let
  machine = {
    system = "x86_64-linux";

    user = {
      username = "richard";
      email = "richardmcsmith@gmail.com";
      fullName = "Richard Smith";
    };

    host = {
      name = "example";
    };
  };

  nix = common.mkNix machine.system;
in
  inputs.nixpkgs.lib.nixosSystem {
    system = machine.system;

    specialArgs = {
      inherit machine;
      helpers = nix.helpers;
    };

    modules = [
      ({...}: {
        nixpkgs.pkgs = nix.pkgs;
        networking.hostName = machine.host.name;

        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit machine;
            helpers = nix.helpers;
          };
          users.${machine.user.username}.imports = [
            (common.mkHomeManager machine)
            ./home.nix
          ];
        };
      })
      inputs.home-manager.nixosModules.home-manager
      ./nixos.nix
    ];
  }
