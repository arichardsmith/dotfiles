{
  nixpkgs,
  home-manager,
  starship-jj,
  snitch,
  opencode,
}: let
  lib = nixpkgs.lib;

  mkNix = system: let
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfreePredicate = pkg:
        builtins.elem (nixpkgs.lib.getName pkg) [
          "claude-code"
        ];
      overlays = [
        (final: prev: {
          starship-jj = starship-jj.packages.${system}.default;
          snitch = snitch.packages.${system}.default;
          opencode = opencode.packages.${system}.default;
        })
      ];
    };

    hmLib =
      pkgs.lib
      // {
        hm = home-manager.lib.hm;
      };

    helpers = import ../lib {
      lib = hmLib;
      inherit pkgs;
    };
  in {
    inherit pkgs;
    lib = hmLib;
    inherit helpers;
  };

  mkBaseHomeModule = machine: {pkgs, ...}: {
    imports = [
      ../modules
    ];

    config = {
      home.username = machine.user.username;
      home.homeDirectory =
        machine.user.homeDirectory
        or (
          if pkgs.stdenv.isDarwin
          then "/Users/${machine.user.username}"
          else "/home/${machine.user.username}"
        );
      home.stateVersion = machine.stateVersion or "26.05";
    };
  };

  mkHomeConfigs = machines:
    lib.mapAttrs (_name: path: let
      machine = import (path + "/default.nix");
      nix = mkNix machine.system;
    in
      home-manager.lib.homeManagerConfiguration {
        inherit (nix) pkgs lib;

        extraSpecialArgs = {
          inherit machine;
          helpers = nix.helpers;
        };

        modules =
          [
            (mkBaseHomeModule machine)
          ]
          ++ machine.homeModules;
      })
    machines;

  mkNixosConfigs = machines:
    lib.mapAttrs (_name: path: let
      machine = import (path + "/default.nix");
      nix = mkNix machine.system;
    in
      nixpkgs.lib.nixosSystem {
        system = machine.system;
        specialArgs = {
          inherit machine;
          helpers = nix.helpers;
        };

        modules =
          [
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
                users.${machine.user.username}.imports =
                  [
                    (mkBaseHomeModule machine)
                  ]
                  ++ machine.homeModules;
              };
            })
            home-manager.nixosModules.home-manager
          ]
          ++ (machine.nixosModules or []);
      })
    machines;
in {
  inherit mkHomeConfigs mkNixosConfigs;
}
