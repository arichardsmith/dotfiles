{
  lib,
  pkgs,
  config,
  ...
}: {
  options.programs.helix.toolchains.python.enable = lib.mkEnableOption "python toolchain";

  config = lib.mkIf (config.programs.helix.toolchains.python.enable && config.programs.helix.enable) {
    home.packages = with pkgs; [uv ruff basedpyright];

    programs.helix.languages = {
      language-server = {
        basedpyright = {
          command = lib.getExe pkgs.basedpyright;
          args = ["--stdio"];
        };
        ruff = {
          command = lib.getExe pkgs.ruff;
          args = ["server"];
        };
      };

      language = [
        {
          name = "python";
          auto-format = true;
          formatter = {
            command = lib.getExe pkgs.ruff;
            args = ["format" "-"];
          };
          language-servers = ["basedpyright" "ruff"];
        }
      ];
    };
  };
}
