{
  nixpkgs,
  js-pkgs,
  home-manager,
  starship-jj,
  snitch,
  mise,
}: let
  mkNix = system: let
    # Flake inputs may not publish packages for every system.
    jsPkgs = js-pkgs.packages.${system} or {};
    starshipJjPkgs = starship-jj.packages.${system} or {};
    snitchPkgs = snitch.packages.${system} or {};
    misePkgs = mise.packages.${system} or {};

    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        (final: prev: {
          oxfmt = jsPkgs.oxfmt or null;
          claude-code = jsPkgs.claude-code or null;
          opencode = jsPkgs.opencode or prev.opencode;
          nub = jsPkgs.nub or null;
          viteplus = jsPkgs.viteplus or null;
          starship-jj = starshipJjPkgs.default or prev."starship-jj";
          snitch = snitchPkgs.default or prev.snitch;
          mise = misePkgs.default or prev.mise;
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

  mkHomeManager = machine: {pkgs, ...}: {
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
in {
  inherit mkNix mkHomeManager;
}
