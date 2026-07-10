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
  inputs.nix-darwin.lib.darwinSystem {
    pkgs = nix.pkgs;

    specialArgs = {
      inherit machine;
      helpers = nix.helpers;
    };

    modules = [
      ({...}: {
        nixpkgs.hostPlatform = machine.system;
        networking.hostName = machine.host.name;

        users.users.${machine.user.username}.home = "/Users/${machine.user.username}";

        nix.settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          trusted-users = [
            "root"
            machine.user.username
          ];
        };

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
            ./programs.nix
            ./backup.nix
          ];
        };
      })
      inputs.home-manager.darwinModules.home-manager
      ./darwin.nix
    ];
  }
