{
  config,
  helpers,
  pkgs,
  ...
}:
helpers.mkProgram {inherit config pkgs;} "forgejoCli" {
  setup = {pkgs, ...}: {
    home.packages = [pkgs.forgejo-cli];
  };
}
