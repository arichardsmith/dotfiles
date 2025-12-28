{...}: {
  config = {
    # Enable packs
    packs = {
      shell.enable = true;
      system.enable = true;
      server.enable = true;
    };

    # SSH authorized keys
    customPrograms.sshKeys = {
      enable = true;
      settings.authorizedKeyPaths = [
        ../../ssh_keys/laptop.pub
      ];
    };

    home.packages = [
    ];
  };
}
