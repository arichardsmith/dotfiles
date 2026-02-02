{
  config,
  pkgs,
  lib,
  ...
}:
lib.helpers.mkProgram {inherit config pkgs;} "erdtree" {
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

    # Add shell aliases and functions
    shell.aliases =
      lib.optionalAttrs cfg.settings.overrideLs
      {
        lsa = "erd --config ls --hidden --no-ignore";
        lt = "erd --config ls --level 2";
        lta = "erd --config ls --level 2 --hidden --no-ignore";
        ls = "erd --config ls";
        ols = "/bin/ls"; # Add an alias for normal ls incase we need it
      };

    programs.claude-code.memory.chunks = [
      ''
        This machine has `erdtree` aliases to `ls`. This means flags like `ls -la` __WONT WORK__.
        `erd --long --hidden` lists hidden files along with details about them. `erd --hidden --level 2` lets you peak into subdirectories.
        If you _have_ to use the original `ls` binary, it is aliased to `ols`.
      ''
    ];
  };
}
