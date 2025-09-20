{...}: {
  config = {
    programs.btop = {
      enable = true;
      themes = {
        catppuccin = ./btop.theme;
      };
    };
  };
}
