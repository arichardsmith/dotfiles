{pkgs}:
# Convert a Python uv inline script to a package. Pass either `file` or `text`, not both.
# The script body should NOT include a shebang — one pointing to the nix-managed uv is prepended.
# Usage: uvScriptToPackage { name = "script-name"; file = ./path/to/script.py; }
#        uvScriptToPackage { name = "script-name"; text = "import sys\nprint(sys.version)"; }
{
  name,
  file ? null,
  text ? null,
}:
let
  body =
    if file != null && text == null
    then builtins.readFile file
    else if text != null && file == null
    then text
    else throw "uvScriptToPackage: exactly one of `file` or `text` must be provided";
in
  pkgs.writeScriptBin name ''
    #!${pkgs.uv}/bin/uv run --script
    ${body}
  ''
