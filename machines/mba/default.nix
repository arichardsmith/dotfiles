{
  system = "aarch64-darwin";

  user = {
    username = "richardsmith";
    email = "richardmcsmith@gmail.com";
    fullName = "Richard Smith";
  };

  host = {
    name = "mba";
  };

  homeModules = [
    ./home.nix
    ./programs.nix
    ./backup.nix
  ];
}
