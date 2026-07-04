{
  nixpkgs,
  js-pkgs,
  home-manager,
  starship-jj,
  snitch,
  mise,
}: let
  lib = nixpkgs.lib;

  mkNix = system: let
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        (final: prev: {
          inherit (js-pkgs.packages.${system}) oxfmt claude-code opencode nub viteplus;
          starship-jj = starship-jj.packages.${system}.default;
          snitch = snitch.packages.${system}.default;
          mise = mise.packages.${system}.default;
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
            ({
              pkgs,
              lib,
              ...
            }:
              lib.mkIf (machine.allowedSshKeys or [] != []) {
                home.activation.copyAuthorizedKeys = lib.hm.dag.entryAfter ["writeBoundary"] (let
                  authorizedKeysFile = pkgs.writeText "authorized_keys" (lib.concatStringsSep "\n" (map builtins.readFile machine.allowedSshKeys));
                in ''
                  $DRY_RUN_CMD mkdir -p $HOME/.ssh
                  $DRY_RUN_CMD chmod 700 $HOME/.ssh
                  $DRY_RUN_CMD cp ${authorizedKeysFile} $HOME/.ssh/authorized_keys
                  $DRY_RUN_CMD chmod 600 $HOME/.ssh/authorized_keys
                '');
              })
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

              users.users.${machine.user.username}.openssh.authorizedKeys.keys =
                map builtins.readFile (machine.allowedSshKeys or []);

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
