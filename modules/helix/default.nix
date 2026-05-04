{...}: {
  config.programs.helix = {
    settings = {
      theme = "catppuccin_macchiato";
      keys = {
        normal = {
          "$" = "goto_line_end";
          "^" = "goto_line_start";
        };
        select = {
          "$" = "goto_line_end";
          "^" = "goto_line_start";
        };
      };
    };
  };
}
