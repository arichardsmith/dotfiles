{pkgs}:
# Convert a shell script file to a package
# Usage: scriptToPackage "script-name" ./path/to/script.sh
name: scriptPath:
pkgs.writeShellScriptBin name (builtins.readFile scriptPath)
