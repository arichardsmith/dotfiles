{
  config,
  pkgs,
  lib,
  ...
}:
lib.helpers.mkProgram {inherit config pkgs;} "colima" {
  settings = {
    cpu = lib.mkOption {
      type = lib.types.ints.positive;
      default = 2;
      description = "Number of CPUs to be allocated to the virtual machine";
    };

    memory = lib.mkOption {
      type = lib.types.ints.positive;
      default = 2;
      description = "Size of the memory in GiB to be allocated to the virtual machine";
    };

    disk = lib.mkOption {
      type = lib.types.ints.positive;
      default = 100;
      description = "Size of the disk in GiB to be allocated to the virtual machine";
    };

    arch = lib.mkOption {
      type = lib.types.enum ["x86_64" "aarch64" "host"];
      default = "aarch64";
      description = "Architecture of the virtual machine";
    };
  };

  setup = {
    pkgs,
    cfg,
    ...
  }: let
    colimaConfig = pkgs.writeText "colima.yaml" ''
      # Number of CPUs to be allocated to the virtual machine.
      # Default: 2
      cpu: ${toString cfg.settings.cpu}

      # Size of the disk in GiB to be allocated to the virtual machine.
      # NOTE: value can only be increased after virtual machine has been created.
      #
      # Default: 100
      disk: ${toString cfg.settings.disk}

      # Size of the memory in GiB to be allocated to the virtual machine.
      # Default: 2
      memory: ${toString cfg.settings.memory}

      # Architecture of the virtual machine (x86_64, aarch64, host).
      #
      # NOTE: value cannot be changed after virtual machine is created.
      # Default: host
      arch: ${cfg.settings.arch}

      # Container runtime to be used (docker, containerd).
      #
      # NOTE: value cannot be changed after virtual machine is created.
      # Default: docker
      runtime: docker

      # Set custom hostname for the virtual machine.
      # Default: colima
      #          colima-profile_name for other profiles
      hostname: colima

      # Auto-activate on the Host for client access.
      # Setting to true does the following on startup
      #  - sets as active Docker context (for Docker runtime).
      #  - sets as active Kubernetes context (if Kubernetes is enabled).
      # Default: true
      autoActivate: true

      # ===================================================================== #
      # ADVANCED CONFIGURATION
      # ===================================================================== #

      # Virtual Machine type (qemu, vz)
      # NOTE: this is macOS 13 only. For Linux and macOS <13.0, qemu is always used.
      #
      # vz is macOS virtualization framework and requires macOS 13
      #
      # NOTE: value cannot be changed after virtual machine is created.
      # Default: qemu
      vmType: vz

      # Utilise rosetta for amd64 emulation (requires m1 mac and vmType `vz`)
      # Default: false
      rosetta: false

      # Enable nested virtualization for the virtual machine (requires m3 mac and vmType `vz`)
      # Default: false
      nestedVirtualization: false

      # Volume mount driver for the virtual machine (virtiofs, 9p, sshfs).
      #
      # virtiofs is limited to macOS and vmType `vz`. It is the fastest of the options.
      #
      # 9p is the recommended and the most stable option for vmType `qemu`.
      #
      # sshfs is faster than 9p but the least reliable of the options (when there are lots
      # of concurrent reads or writes).
      #
      # NOTE: value cannot be changed after virtual machine is created.
      # Default: virtiofs (for vz), sshfs (for qemu)
      mountType: sshfs

      # Propagate inotify file events to the VM.
      # NOTE: this is experimental.
      mountInotify: false

      # The CPU type for the virtual machine (requires vmType `qemu`).
      # Options available for host emulation can be checked with: `qemu-system-$(arch) -cpu help`.
      # Instructions are also supported by appending to the cpu type e.g. "qemu64,+ssse3".
      # Default: host
      cpuType: ""

      # Environment variables for the virtual machine.
      #
      # EXAMPLE
      # env:
      #   KEY: value
      #   ANOTHER_KEY: another value
      #
      # Default: {}
      env: {}
    '';
  in {
    home.packages = [pkgs.colima];

    # Copy the config instead of symlinking it
    # Colima updates the config file itself, so isn't compatible with read only symlinks
    home.activation.colimaConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -f ~/.colima/default/colima.yaml ]; then
        mkdir -p ~/.colima/default
        cp ${colimaConfig} ~/.colima/default/colima.yaml
        chmod 644 ~/.colima/default/colima.yaml
      fi
    '';
  };
}
