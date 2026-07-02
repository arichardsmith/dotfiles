{
  config,
  helpers,
  pkgs,
  lib,
  ...
}:
helpers.mkProgram {inherit config pkgs;} "erdtree" {
  settings = {
    overrideLs = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Replace standard ls command with erdtree";
    };

    config = lib.mkOption {
      type = lib.types.attrs;
      default = {
        human = true;
        layout = "inverted";
        level = 1;

        ls = {
          icons = true;
          human = true;
          level = 1;
          layout = "inverted";
          sort = "name";
          suppress-size = true;
        };
      };
      description = "Erdtree configuration";
    };
  };

  setup = {
    pkgs,
    cfg,
    ...
  }: let
    tomlFormat = pkgs.formats.toml {};
  in {
    # Include the package
    home.packages = [pkgs.erdtree];

    # Generate config file
    home.file = {
      ".config/erdtree/.erdtree.toml".source = tomlFormat.generate "erdtree.toml" cfg.settings.config;
    };
  };
}
