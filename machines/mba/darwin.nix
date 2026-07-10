{machine, ...}: {
  system.stateVersion = 6;
  system.primaryUser = machine.user.username;

  # Build the Linux development image locally on Apple Silicon.
  nix.linux-builder.enable = true;
}
