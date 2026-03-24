{
  config,
  lib,
  ...
}: let
  cfg = config.programs.fd;
in {
  config = lib.mkIf cfg.enable {
    shell.functions = [
      ''
        # A short cut for finding files and folders at the given depth from the cwd
        fdd() {
          fd . -d "''${1:-1}"
        }
      ''
    ];
  };
}
