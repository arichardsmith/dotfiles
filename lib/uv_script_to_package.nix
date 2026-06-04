{pkgs}:
# Convert a Python uv inline script to a package. Pass either `file` or `text`, not both.
# The script body should NOT include a shebang — one pointing to the nix-managed uv is prepended.
# Usage: uvScriptToPackage { name = "script-name"; file = ./path/to/script.py; }
#        uvScriptToPackage { name = "script-name"; text = "import sys\nprint(sys.version)"; }
{
  name,
  file ? null,
  text ? null,
  runtimeInputs ? [],
}:
let
  # Match script_to_package.nix: callers can supply either a file or inline text,
  # but not both. The helper reads the script body and fails early on invalid input.
  body =
    if file != null && text == null
    then builtins.readFile file
    else if text != null && file == null
    then text
    else throw "uvScriptToPackage: exactly one of `file` or `text` must be provided";
  # writeScriptBin creates the executable, but unlike writeShellApplication it does
  # not add PATH setup or shell-specific wrappers. We inject a shebang that runs the
  # script through Nix-managed uv so inline script metadata and dependencies work.
  script = pkgs.writeScriptBin name ''
    #!${pkgs.uv}/bin/uv run --script
    ${body}
  '';
in
  # If the script needs extra runtime commands, wrap the generated binary so those
  # tools are on PATH when uv executes the script.
  if runtimeInputs == []
  then script
  else pkgs.symlinkJoin {
    inherit name;
    paths = [script];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/${name} \
        --prefix PATH : ${pkgs.lib.makeBinPath runtimeInputs}
    '';
  }
