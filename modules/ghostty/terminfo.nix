# This adds ghostty's term info to remote machines.
# It doesn't configure or run ghostty on the device.
{
  lib,
  pkgs,
  config,
  ...
}:
lib.helpers.mkProgram {inherit config pkgs;} "ghosttyTermInfo" {
  setup = {...}: {
    home.packages = [pkgs.ghostty];

    home.sessionVariables = {
      TERMINFO = "${pkgs.ghostty}/share/terminfo";
    };
  };
}
