{lib, ...}: {
  mkProgram = name: {
    settings ? {},
    setup,
  }: {
    config,
    pkgs,
    ...
  }: let
    cfg = config.custom.programs.${name};
  in {
    options.custom.programs.${name} = {
      enable = lib.mkEnableOption name;
      settings = lib.mkOption {
        type = lib.types.submodule {
          options = settings;
        };
        default = {};
      };
    };

    config = lib.mkIf cfg.enable (setup {inherit config pkgs cfg;});
  };
}
