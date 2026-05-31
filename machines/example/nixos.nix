{
  pkgs,
  ...
}: {
  config = {
    # Placeholder boot settings so the example evaluates as a complete NixOS host.
    # Replace these with the target machine's real disk layout and boot device.
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    boot.loader.grub = {
      enable = true;
      devices = ["/dev/vda"];
    };

    users.users = {
      # Primary login user. Home Manager for this user is wired in by lib/configurations.nix.
      richard = {
        isNormalUser = true;
        extraGroups = ["wheel"];
      };

      # Dedicated remote deployment user for `nixos-rebuild --use-remote-sudo`.
      deploy = {
        isNormalUser = true;
        extraGroups = ["wheel"];
        openssh.authorizedKeys.keys = [
          "replace-with-deploy-public-key"
        ];
      };
    };

    # The deploy user is intentionally root-equivalent for remote system switches.
    # Keep its SSH key dedicated to deployment and restrict SSH exposure separately.
    security.sudo.extraRules = [
      {
        users = ["deploy"];
        commands = [
          {
            command = "ALL";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];

    # Only allow key-based SSH and do not allow direct root login.
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    # Trusted users can perform remote Nix builds without hitting daemon restrictions.
    nix.settings.trusted-users = [
      "root"
      "deploy"
    ];

    environment.systemPackages = with pkgs; [
      git
    ];

    system.stateVersion = "26.05";
  };
}
