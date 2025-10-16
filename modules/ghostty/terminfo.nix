# This ensures NixOS has ghostty's terminfo available.
# It doesn't configure or run ghostty on the device.
{pkgs, ...}: {
  environment.systemPackages = [pkgs.ghostty];
}
