{
  lib,
  pkgs,
  config,
  ...
}: {
  options.programs.helix.toolchains.go.enable = lib.mkEnableOption "go toolchain";

  config = lib.mkIf (config.programs.helix.toolchains.go.enable && config.programs.helix.enable) {
    home.packages = with pkgs; [go gopls golangci-lint air];

    programs.helix.languages = {
      language-server.gopls = {
        command = lib.getExe pkgs.gopls;
        config = {
          "ui.diagnostic.staticcheck" = true;
        };
      };

      language = [
        {
          name = "go";
          auto-format = true;
          formatter.command = lib.getExe pkgs.go;
          formatter.args = ["fmt"];
          language-servers = ["gopls"];
        }
      ];
    };
  };
}
