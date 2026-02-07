{
  pkgs,
  lib,
  ...
}: {
  config = {
    # Enable packs
    packs = {
      shell.enable = true;
      system.enable = true;
      dev.enable = true;
    };

    programs = {
      direnv.enable = true;
      neovim.enable = true;
      rclone.enable = true;
      rbw.enable = true;

      git.settings = {
        # Allow nas://<repo> paths when working with repos stored on NAS
        url."ssh://mininas.local/tank/git/" = {
          insteadOf = "nas://";
        };
      };
    };

    customPrograms = {
      ghostty.enable = true;
      colima = {
        enable = true;
        settings = {
          cpu = 4;
          memory = 3;
          disk = 60;
          arch = "aarch64";
        };
      };
    };

    home.packages = with pkgs; [
      cyme # List system USB buses and devices. A modern cross-platform lsusb
      caddy # Used to handle .localhost domains
      ffmpeg

      # Fonts
      maple-mono.truetype
      maple-mono.NF-unhinted

      (lib.helpers.scriptToPackage "unlock-drive" ./scripts/unlock-drive.sh)
      (lib.helpers.scriptToPackage "unlock-ssh" ./scripts/unlock-ssh.sh)
    ];
  };
}
