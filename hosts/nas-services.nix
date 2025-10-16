{...}: {
  # NixOS system configuration
  system.stateVersion = "24.05";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nas-services";
  networking.networkmanager.enable = true;

  # Enable nix flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Docker setup
  virtualisation.docker.enable = true;

  # Create /etc/services directory for docker-compose stacks
  systemd.tmpfiles.rules = [
    "d /etc/services 0755 root root -"
  ];

  # QEMU Guest Agent (for Proxmox VM integration)
  services.qemu-guest-agent.enable = true;

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true; # Allow password initially, disable after SSH key setup
    };
  };

  # Define your user
  users.users.richardsmith = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "docker"];
    initialPassword = "changeme"; # Change this after first login
  };

  # Home Manager configuration
  home-manager.users.richardsmith = {
    imports = [
      ../home.nix
      # Terminal
      ../modules/shell
      ../modules/erdtree
      ../modules/bat
      ../modules/zoxide

      # Version control
      ../modules/git
      ../modules/gh

      # Development tools
      ../modules/neovim
      ../modules/nix

      # System management
      ../modules/btop

      (import ../modules/docker {includeLazyDocker = true;})
    ];

    config = {
      user.username = "richardsmith";
      user.email = "richardmcsmith@gmail.com";
      user.fullName = "Richard Smith";
      host.name = "nas-services";

      home.sessionVariables = {
        EDITOR = "nvim";
      };

      zsh.initContent = [];
    };
  };
}
