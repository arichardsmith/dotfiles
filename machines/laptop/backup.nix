{
  config,
  pkgs,
  lib,
  ...
}: let
  home = config.home.homeDirectory;
  backupDev = lib.helpers.scriptToPackage {
    name = "backup-dev";
    file = ./scripts/backup-dev.sh;
    runtimeInputs = [pkgs.restic];
    excludeShellChecks = ["SC2034"];
  };
  backupVault = lib.helpers.scriptToPackage {
    name = "backup-vault";
    file = ./scripts/backup-vault.sh;
    runtimeInputs = [pkgs.restic];
    excludeShellChecks = ["SC2034"];
  };

  # launchd has no interval-based scheduling; hours must be listed explicitly.
  # Unlike systemd's Persistent=true, missed runs are not caught up after sleep.
  onHours = hours:
    map (h: {
      Hour = h;
      Minute = 0;
    })
    hours;
in {
  home.packages = [pkgs.restic backupDev backupVault];

  launchd.agents = {
    restic-dev = {
      enable = true;
      config = {
        Label = "org.home.restic-dev";
        # Use the store path directly — avoids symlink indirection via ~/.nix-profile
        ProgramArguments = ["${backupDev}/bin/backup-dev"];
        StartCalendarInterval = onHours [12 16 20];
        StandardOutPath = "${home}/.local/log/restic-dev.log";
        StandardErrorPath = "${home}/.local/log/restic-dev-error.log";
      };
    };
    restic-vault = {
      enable = true;
      config = {
        Label = "org.home.restic-vault";
        ProgramArguments = ["${backupVault}/bin/backup-vault"];
        StartCalendarInterval = onHours [8 12 16 20];
        StandardOutPath = "${home}/.local/log/restic-vault.log";
        StandardErrorPath = "${home}/.local/log/restic-vault-error.log";
      };
    };
  };
}
