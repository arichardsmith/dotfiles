{...}: {
  imports = [
    ./toolchains/python.nix
    ./toolchains/markdown.nix
    ./toolchains/just.nix
    ./toolchains/toml.nix
    ./toolchains/yaml.nix
    ./toolchains/json.nix
    ./toolchains/js.nix
    ./toolchains/nix.nix
    ./toolchains/rust.nix
    ./toolchains/go.nix
  ];

  config.programs.helix = {
    settings = {
      theme = "catppuccin_macchiato";
      keys = {
        normal = {
          "$" = "goto_line_end";
          "^" = "goto_line_start";
          "C-r" = ":reload";

          space = {
            d = ":cd %sh{dirname '%{buffer_name}'}";
            D = '':cd %sh{jj root 2>/dev/null || git rev-parse --show-toplevel}'';
          };
        };
        insert = {
          # Enable home-row movements in insert mode
          "C-h" = "move_char_left";
          "C-l" = "move_char_right";
          "C-j" = "move_visual_line_down";
          "C-k" = "move_visual_line_up";
          "C-o" = "open_below";
        };
        select = {
          "$" = "goto_line_end";
          "^" = "goto_line_start";
        };
      };
    };
  };
}
