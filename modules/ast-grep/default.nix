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

    programs.claude-code.memory.chunks = [
      ''
        You have access to `ast-grep` for AST-based code search and refactoring (more precise than regex for structural code patterns).
      ''
    ];
  };
}
