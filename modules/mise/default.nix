{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.programs.mise;

  tomlFormat = pkgs.formats.toml {};

  miseBin = lib.getExe pkgs.mise;
in {
  options.my.programs.mise = {
    enable = lib.mkEnableOption "mise";

    settings = lib.mkOption {
      type = tomlFormat.type;
      default = {};
      description = "Contents of mise global config.toml, specified as Nix attrs.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.mise];

    home.file.".config/mise/config.toml".source =
      tomlFormat.generate "mise-config" cfg.settings;

    programs.zsh.initContent = lib.mkIf config.programs.zsh.enable ''
      eval "$(${miseBin} activate zsh)"
    '';

    programs.nushell.extraConfig =
      lib.mkIf config.programs.nushell.enable
      (let
        activateScript = pkgs.runCommand "mise-activate.nu" {} ''
          ${miseBin} activate nu > $out
        '';
      in ''
        source ${activateScript}
      '');
  };
}
