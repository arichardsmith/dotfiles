{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [
      ast-grep
      (writeShellScriptBin "sg" ''
        exec ${ast-grep}/bin/ast-grep "$@"
      '')
    ];
  };
}
