{...}: {
  config = {
    # Enable packs
    packs = {
      shell.enable = true;
      system.enable = true;
      server.enable = true;
    };

    programs = {
      neovim.enable = true;
    };

    # SSH authorized keys
    customPrograms.sshKeys = {
      enable = true;
      settings.authorizedKeyPaths = [
        ../../ssh_keys/laptop.pub
      ];
    };

    customPrograms.ghosttyTermInfo.enable = true;

    customPrograms.sanoid = {
      enable = true;
      settings.configFilePath = ./sanoid.conf;
    };

    home.packages = [
    ];
  };
}
