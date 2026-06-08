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
      editor = {
        "auto-save" = {
          "focus-lost" = true;
          "after-delay" = {
            enable = true;
            timeout = 20000;
          };
        };
        "soft-wrap" = {
          enable = true;
        };
      };
      keys = {
        normal = {
          "$" = "goto_line_end";
          "^" = "goto_line_start";
          "C-r" = ":reload";

          space = {
            d = ":cd %sh{dirname '%{buffer_name}'}";
            D = '':cd %sh{jj root 2>/dev/null || git rev-parse --show-toplevel}'';
            n = "jump_forward";
            N = "jump_backward";
            m = "jump_backward";
          };

          # Treat backslash as an alternative to not being able to define custom commands
          "\\" = {
            d = ":sh rm %{buffer_name}";
            D = [":sh rm %{buffer_name}" ":buffer-close"];
            f = ":format";
            w = ":toggle-option soft-wrap.enable";
          };
        };

        insert = {
          # Skip past an auto-inserted closing delimiter.
          "C-;" = "move_char_right";
        };

        select = {
          "$" = "goto_line_end";
          "^" = "goto_line_start";
        };
      };
    };
  };
}
