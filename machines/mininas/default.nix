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

  allowedSshKeys = [
    ../laptop/ssh_key.pub
    ../ipad/ssh_key.pub
  ];

  homeModules = [
    ./home.nix
  ];
}
