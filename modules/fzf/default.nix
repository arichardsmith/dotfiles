{config, ...}: {
  config = {
    programs.fzf = {
      enableZshIntegration = config.programs.zsh.enable;
      defaultCommand = "fd --type f";
    };
  };
}
