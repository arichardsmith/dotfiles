{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.packs.dev;
in {
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      python312
      uv
    ];

    home.sessionVariables = {
      UV_PYTHON = "${pkgs.python312}/bin/python";
    };
  };
}
