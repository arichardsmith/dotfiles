{...}: {
  config = {
    # The ghostty package is currently broken, so we'll track the config manually
    # programs.ghostty = {
    #   enable = true;

    #   settings = {
    #     # Cursor configuration
    #     cursor-style = "block";

    #     # Window padding
    #     window-padding-x = 8;
    #     window-padding-y = 6;

    #     # Font configuration
    #     font-family = "MesloLGS NF";

    #     # Color configuration
    #     background = "24273a";
    #     foreground = "cad3f5";
    #     theme = "catppuccin-mocha";

    #     # Keybindings
    #     keybind = "shift+enter=text:\\n";
    #   };
    # };

    home.file = {
      ".config/ghostty/config".source = ./config;
      ".config/ghostty/themes/catppuccin-mocha".source = ./catppuccin-mocha.conf;
    };
  };
}
