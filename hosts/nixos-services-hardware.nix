# Hardware configuration placeholder
# This file should be replaced with the actual hardware configuration from your NixOS installation
#
# On the NixOS VM, generate the real hardware config with:
#   sudo nixos-generate-config --show-hardware-config > ~/dotfiles/hosts/nixos-services-hardware.nix
#
# Then commit it to the repo
{...}: {
  imports = [];

  # Placeholder filesystem configuration
  # Replace this with actual configuration from your system
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [];
}
