{
  config,
  pkgs,
  lib,
  ...
}:
lib.helpers.mkProgram {inherit config pkgs;} "astGrep" {
  setup = {pkgs, ...}: {
    home.packages = with pkgs; [
      ast-grep
      (writeShellScriptBin "sg" ''
        exec ${ast-grep}/bin/ast-grep "$@"
      '')
    ];
  };
}
