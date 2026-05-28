{
  lib,
  config,
  ...
}: {
  config = {
    programs.direnv = {
      nix-direnv.enable = true;
      config = {
        hide_env_diff = true;
      };
      enableZshIntegration = true;
    };
  };
}
