{
  lib,
  pkgs,
  config,
  ...
}: {
  options.programs.helix.toolchains.markdown.enable = lib.mkEnableOption "markdown toolchain";

  config = lib.mkIf (config.programs.helix.toolchains.markdown.enable && config.programs.helix.enable) {
    home.packages = with pkgs; [marksman markdown-oxide];

    programs.helix.languages = {
      language-server = {
        marksman.command = lib.getExe pkgs.marksman;
        markdown-oxide.command = lib.getExe pkgs.markdown-oxide;
      };

      language = [
        {
          name = "markdown";
          language-servers = ["marksman" "markdown-oxide"];
        }
      ];
    };
  };
}
