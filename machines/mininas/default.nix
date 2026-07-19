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
      name = "mininas";
      tailscale.ipv4 = "100.111.24.65";
    };

    allowedSshKeys = [
      ../mba/ssh_key.pub
      ../ipad/ssh_key.pub
    ];
  };

  nix = common.mkNix machine.system;

  homeManager.config = {
    home.sessionPath = [];

    home.sessionVariables = {
      EDITOR = "nvim";
    };
  };
in
  inputs.home-manager.lib.homeManagerConfiguration {
    inherit (nix) pkgs lib;

    extraSpecialArgs = {
      inherit machine;
      helpers = nix.helpers;
    };

    modules = [
      (common.mkHomeManager machine)
      ({
        pkgs,
        lib,
        ...
      }:
        lib.mkIf (machine.allowedSshKeys != []) {
          home.activation.copyAuthorizedKeys = lib.hm.dag.entryAfter ["writeBoundary"] (let
            authorizedKeysFile = pkgs.writeText "authorized_keys" (lib.concatStringsSep "\n" (map builtins.readFile machine.allowedSshKeys));
          in ''
            $DRY_RUN_CMD mkdir -p $HOME/.ssh
            $DRY_RUN_CMD chmod 700 $HOME/.ssh
            $DRY_RUN_CMD cp ${authorizedKeysFile} $HOME/.ssh/authorized_keys
            $DRY_RUN_CMD chmod 600 $HOME/.ssh/authorized_keys
          '');
        })
      homeManager
      ./programs.nix
    ];
  }
