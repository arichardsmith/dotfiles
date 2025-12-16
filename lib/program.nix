{lib}:
# Create a home-manager module for a program with configurable settings.
#
# This helper creates modules with:
# - An enable option at custom.programs.<name>.enable
# - A settings submodule at custom.programs.<name>.settings
# - Automatic setup when enabled
#
# Usage in a module file (modules/myapp/default.nix):
#
#   {config, pkgs, lib, ...}:
#   lib.helpers.mkProgram {inherit config pkgs;} "myapp" {
#     settings = {
#       port = lib.mkOption {
#         type = lib.types.port;
#         default = 8080;
#       };
#     };
#
#     setup = {config, pkgs, cfg, ...}: {
#       home.packages = [pkgs.myapp];
#       xdg.configFile."myapp/config.toml".text = ''
#         port = ${toString cfg.settings.port}
#       '';
#     };
#   }
#
# Then in your configuration:
#   customPrograms.myapp = {
#     enable = true;
#     settings.port = 9000;
#   };
{
  config,
  pkgs,
}: name: {
  settings ? {},
  setup,
}: let
  # Reference to this module's config at custom.programs.<name>
  cfg = config.customPrograms.${name};
in {
  # Define the module's options
  options.customPrograms.${name} = {
    # Whether to enable this program
    enable = lib.mkEnableOption name;

    # Program-specific configuration options
    settings = lib.mkOption {
      type = lib.types.submodule {
        options = settings;
      };
      default = {};
    };
  };

  # Apply configuration when module is enabled
  config = lib.mkIf cfg.enable (setup {inherit config pkgs cfg;});
}
