{
  # Nix system used for both the NixOS system and integrated Home Manager config.
  system = "x86_64-linux";

  # Machine metadata is passed to modules as the `machine` argument.
  user = {
    username = "richard";
    email = "richardmcsmith@gmail.com";
    fullName = "Richard Smith";
  };

  host = {
    name = "example";
  };

  # Home Manager modules imported for this machine's primary user.
  homeModules = [
    ./home.nix
  ];

  # NixOS modules imported for the system configuration.
  nixosModules = [
    ./nixos.nix
  ];
}
