{pkgs, ...}: {
  packages = with pkgs; [
    just
    ast-grep
    (writeShellScriptBin "sg" ''
      exec ${ast-grep}/bin/ast-grep "$@"
    '')
    # ngrok - unfree and unneeded?
  ];
}
