{
  config,
  pkgs,
  lib,
  ...
}:
lib.helpers.mkProgram {inherit config pkgs;} "sanoid" {
  settings = {
    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "String value to use to write the /etc/sanoid/sanoid.conf file";
    };

    configFilePath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a file to copy to /etc/sanoid/sanoid.conf";
    };
  };

  setup = {
    pkgs,
    cfg,
    ...
  }: {
    home.packages = [pkgs.sanoid];

    xdg.configFile."sanoid/sanoid.conf" =
      if cfg.settings.configFile != null
      then {
        text = cfg.settings.configFile;
      }
      else if cfg.settings.configFilePath != null
      then {
        source = cfg.settings.configFilePath;
      }
      else {};

    xdg.configFile."sanoid/systemd/sanoid.timer".text = ''
      [Unit]
      Description=Run Sanoid Every 15 Minutes
      Requires=sanoid.service

      [Timer]
      OnCalendar=*:0/15
      Persistent=true

      [Install]
      WantedBy=timers.target
    '';

    xdg.configFile."sanoid/systemd/sanoid.service".text = ''
      [Unit]
      Description=Snapshot ZFS Pool
      Requires=zfs.target
      After=zfs.target
      Wants=sanoid-prune.service
      Before=sanoid-prune.service
      ConditionFileNotEmpty=/etc/sanoid/sanoid.conf

      [Service]
      Environment=TZ=UTC
      Type=oneshot
      ExecStart=${pkgs.sanoid}/bin/sanoid --take-snapshots --verbose
    '';

    xdg.configFile."sanoid/systemd/sanoid-prune.service".text = ''
      [Unit]
      Description=Cleanup ZFS Pool
      Requires=zfs.target
      After=zfs.target sanoid.service
      ConditionFileNotEmpty=/etc/sanoid/sanoid.conf

      [Service]
      Environment=TZ=UTC
      Type=oneshot
      ExecStart=${pkgs.sanoid}/bin/sanoid --prune-snapshots --verbose

      [Install]
      WantedBy=sanoid.service
    '';

    xdg.configFile."sanoid/install.sh" = {
      executable = true;
      source = ./install.sh;
    };
  };
}
