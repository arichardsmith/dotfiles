# modules/aliases.nix
{...}: {
  base = {
    enableCompletion = true;
    autosuggestion.enable = true;
  };

  init = {
    base = ''
      # Enable vim keybindings
      bindkey -v
    '';
  };

  aliases = {
    core = {
      # Basic file operations
      ls = "erd --config ls";
      lsa = "erd --config ls --hidden";
      ".." = "cd ..";
      "..." = "cd ../..";
    };

    # Development aliases
    dev = {
      # Jujutsu shortcuts
      jjs = "jj split";
      jja = "jj squash"; # Append current revision into previous
      jjl = "jj log -r 'latest(present(@) | ancestors(immutable_heads().., 2) | present(trunk()), 5)' --no-pager";
    };
  };

  functions = {
    # Shell functions (these need to be added as initExtra)
    dev = ''
      # A "smart" jj new that only creates a new revision if the current one isn't empty or already described.
      jjn() {
        # Check if there are file changes. An empty output means no changes.
        local has_changes
        has_changes=$(jj diff --summary)

        # Check if the current commit has a description, making sure to disable graph output.
        local has_description
        has_description=$(jj log -r @ -T description --no-graph)

        # If there are no file changes AND no description, reuse the current revision.
        # Otherwise, create a new one.
        if [[ -z "$has_changes" && -z "$has_description" ]]; then
          # Show status if we are reusing current revision
          jj status --no-pager
        else
          # Pass all arguments (like -m "message") to the real `jj new` command.
          jj new "$@"
        fi
      }

      # Allow passing a message to jj describe without using the `-m` flag because I'm lazy...
      jjd() {
          if [[ $# -eq 0 ]]; then
              jj describe
          elif [[ $1 == -* ]]; then
              # First arg is a flag → just forward everything
              jj describe "$@"
          else
              # First arg is not a flag → treat as message
              jj describe -m "$1" "''${@:2}"
          fi
      }
    '';
  };
}
