{...}: {
  config = {
    # Enable packs
    packs = {
      shell.enable = true;
      system.enable = true;
      serveri.enable = true;
    };

    home.packages = [
    ];
  };
}
