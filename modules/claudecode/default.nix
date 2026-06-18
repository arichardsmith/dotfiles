{
  config,
  lib,
  ...
}: {
  options.my.programs.claudeCode.enable = lib.mkEnableOption "Claude Code";

  config = lib.mkIf config.my.programs.claudeCode.enable {
    programs.claude-code.enable = true;
  };
}
