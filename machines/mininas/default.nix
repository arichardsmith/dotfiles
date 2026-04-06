{mkHomeConfig}:
mkHomeConfig "x86_64-linux" ({pkgs, ...}: {
  imports = [./programs.nix];

  config = {
    user.username = "richard";
    user.email = "richardmcsmith@gmail.com";
    user.fullName = "Richard Smith";

    home.sessionPath = [];

    home.sessionVariables = {
      EDITOR = "nvim";
    };

    programs.starship.settings.format =
      "[╭─ ](overlay0)$username$hostname $env_var$line_break"
      + "[├╌ ](overlay0)$directory$\{custom.jj\}$line_break"
      + "[$character ](overlay0)";

    # We have the nas periodically fetch this repo and build it,
    # so when we do come to updating, it's not as long a process.

    systemd.user.services.hm-prebuild = {
      Unit.Description = "Pre-build Home Manager generation";
      Service = {
        Type = "oneshot";
        ExecStart = toString (pkgs.writeShellScript "hm-prebuild" ''
          cd /home/richard/env
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
})
