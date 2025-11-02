{pkgs, ...}: {
  imports = [
    # Import the hardware configuration generated during NixOS installation
    # This file defines filesystems, boot settings, etc.
    # Generate it with: nixos-generate-config --show-hardware-config > hardware-configuration.nix
    ./hardware-configuration.nix

    # Ensure terminfo is available at the OS level
    ../../modules/ghostty/terminfo.nix

    ../../modules/avahi
  ];

  # NixOS system configuration
  system.stateVersion = "24.05";

  # Bootloader
  boot.loader = {
    systemd-boot.enable = false;
    grub = {
      enable = true;
      device = "/dev/sda";
    };
  };

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
  services.qemuGuest.enable = true;

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true; # Allow password initially, disable after SSH key setup
    };
  };

  # Enable zsh at the OS level
  programs.zsh.enable = true;

  # Define your user
  users.users.richardsmith = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "docker" "admin"];
    initialPassword = "changeme"; # Change this after first login

    openssh.authorizedKeys.keys = [
      (builtins.readFile ../../ssh_keys/daily_key.pub)
    ];
  };

  # Home Manager configuration
  home-manager.users.richardsmith = {
    imports = [
      ../../home.nix
      # Terminal
      ../../modules/shell
      ../../modules/erdtree
      ../../modules/bat
      ../../modules/zoxide

      # Version control
      ../../modules/git
      ../../modules/gh

      # Development tools
      ../../modules/neovim
      ../../modules/nix

      # System management
      ../../modules/btop

      ../../modules/docker
    ];

    config = {
      user.username = "richardsmith";
      user.email = "richardmcsmith@gmail.com";
      user.fullName = "Richard Smith";
      host.name = "nas-services";

      home.sessionVariables = {
        EDITOR = "nvim";
      };

      docker.lazyDocker.enable = true;

      zsh.initContent = [];
    };
  };
}
