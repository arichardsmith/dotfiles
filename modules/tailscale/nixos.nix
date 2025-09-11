# Note: This is only for NixOS. Tailscale is managed outside of Nix on my Mac to avoid version issues
{pkgs, ...}: {
  config = {
    environment.systemPackages = with pkgs; [tailscale];

    services.tailscale.enable = true;
  };
}
