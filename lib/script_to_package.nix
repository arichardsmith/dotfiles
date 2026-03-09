{pkgs}:
# Convert a shell script to a package. Pass either `file` or `text`, not both.
# Usage: scriptToPackage { name = "script-name"; file = ./path/to/script.sh; runtimeInputs = []; }
#        scriptToPackage { name = "script-name"; text = "#!/usr/bin/env bash\n..."; }
{
  name,
  file ? null,
  text ? null,
  runtimeInputs ? [],
  excludeShellChecks ? [],
}:
let
  scriptText =
    if file != null && text == null then builtins.readFile file
    else if text != null && file == null then text
    else throw "scriptToPackage: exactly one of `file` or `text` must be provided";
in
pkgs.writeShellApplication {
  inherit name runtimeInputs excludeShellChecks;
  text = scriptText;
}
