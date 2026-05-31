{
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

  homeModules = [
    ./home.nix
  ];
}
