{
  system = "aarch64-darwin";

  user = {
    username = "richardsmith";
    email = "richardmcsmith@gmail.com";
    fullName = "Richard Smith";
  };

  host = {
    name = "laptop";
  };

  homeModules = [
    ./home.nix
    ./programs.nix
    ./backup.nix
  ];
}
