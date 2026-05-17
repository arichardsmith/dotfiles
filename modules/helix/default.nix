{...}: {
  config.programs.helix = {
    settings = {
      theme = "catppuccin_macchiato";
      keys = {
        normal = {
          "$" = "goto_line_end";
          "^" = "goto_line_start";
          "C-r" = ":reload";
        };
        insert = {
          # Enable home-row movements in insert mode
          "C-h" = "move_char_left";
          "C-l" = "move_char_right";
          "C-j" = "move_visual_line_down";
          "C-k" = "move_visual_line_up";
        };
        select = {
          "$" = "goto_line_end";
          "^" = "goto_line_start";
        };
      };
    };
  };
}
