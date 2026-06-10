{lib}: {
  config,
  pkgs,
}: name: {
  settings ? {},
  service,
}: let
  cfg = config.my.services.${name};
  serviceConfig =
    {
      description = name;
      command = [];
      environment = {};
      workingDirectory = null;
      restart = true;
      logDirectory = "${config.home.homeDirectory}/.local/log";
      extraConfig = {};
    }
    // service {inherit config pkgs cfg;};
in {
  options.my.services.${name} = {
    enable = lib.mkEnableOption name;

    settings = lib.mkOption {
      type = lib.types.submodule {
        options = settings;
      };
      default = {};
      description = "Service-specific settings for ${name}.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      assertions = [
        {
          assertion = serviceConfig.command != [];
          message = "my.services.${name}: mkService requires a non-empty service.command.";
        }
      ];
    }

    serviceConfig.extraConfig

    (lib.mkIf pkgs.stdenv.isDarwin {
      home.activation."${name}LogDirectory" = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p ${lib.escapeShellArg serviceConfig.logDirectory}
      '';

      launchd.agents.${name} = {
        enable = true;
        config =
          {
            ProgramArguments = serviceConfig.command;
            RunAtLoad = true;
            KeepAlive = serviceConfig.restart;
            EnvironmentVariables = serviceConfig.environment;
            StandardOutPath = "${serviceConfig.logDirectory}/${name}.out.log";
            StandardErrorPath = "${serviceConfig.logDirectory}/${name}.err.log";
          }
          // lib.optionalAttrs (serviceConfig.workingDirectory != null) {
            WorkingDirectory = serviceConfig.workingDirectory;
          };
      };
    })

    (lib.mkIf pkgs.stdenv.isLinux {
      systemd.user.services.${name} = {
        Unit = {
          Description = serviceConfig.description;
        };

        Service =
          {
            ExecStart = lib.escapeShellArgs serviceConfig.command;
            Environment =
              lib.mapAttrsToList
              (environmentName: value: "${environmentName}=${value}")
              serviceConfig.environment;
            Restart =
              if serviceConfig.restart
              then "always"
              else "no";
          }
          // lib.optionalAttrs (serviceConfig.workingDirectory != null) {
            WorkingDirectory = serviceConfig.workingDirectory;
          };

        Install = {
          WantedBy = ["default.target"];
        };
      };
    })
  ]);
}
