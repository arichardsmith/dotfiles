{pkgs, ...}: {
  config = {
    # We have the nas periodically fetch this repo and build it,
    # so when we do come to updating, it's not as long a process.
    systemd.user.services.hm-prebuild = {
      Unit.Description = "Pre-build Home Manager generation";
      Service = {
        Type = "oneshot";
        ExecStart = toString (pkgs.writeShellScript "hm-prebuild" ''
          cd /home/richard/env
          ${pkgs.git}/bin/git remote set-url origin https://git.mininas.sanroku.dev/richard/env.git
          ${pkgs.git}/bin/git pull --ff-only
          ${pkgs.nix}/bin/nix build .#homeConfigurations.mininas.activationPackage --no-link
        '');
      };
    };

    systemd.user.timers.hm-prebuild = {
      Unit.Description = "Periodically pre-build Home Manager";
      Timer = {
        OnCalendar = "daily";
        Persistent = true;
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
