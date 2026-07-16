{
  config,
  helpers,
  pkgs,
  ...
}:
helpers.mkProgram {inherit config pkgs;} "forgejoCli" {
  setup = {pkgs, ...}: {
    home.packages = [pkgs.forgejo-cli];

    my.shell.aliases = {
      # Jujutsu's detached Git HEAD prevents fj from finding the Forgejo remote when multiple remotes exist.
      # I only use fj with the instance on mininas, so hard coding the host will work around this.
      fj = "fj --host git.mininas.sanroku.dev";
    };
  };
}
