{config, ...}: {
  config = {
    # Install and configure jujutsu
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          name = config.user.fullName;
          email = config.user.email;
        };

        ui = {
          editor = "nvim";
          default-command = ["status" "--no-pager"];
          # Many tools expect git style conflict markers
          conflict-marker-style = "git";
        };

        aliases = {
          # Move the nearest bookmark to the latest commit
          tug = [
            "bookmark"
            "move"
            "--from"
            "closest_bookmark(@)"
            "--to"
            "closest_nonempty(@)"
          ];

          # Remove all empty revisions
          cleanup = ["abandon" "-r 'empty() ~ root()"];

          # Start a new revision based on the dev branch, falling back to main
          fresh = ["new" "-r 'coalesce(present(dev), main)'"];
        };

        revset-aliases = {
          "closest_bookmark(to)" = "heads(::to & bookmarks())";
          "closest_nonempty(to)" = "heads(::to ~ (description(exact:\"\") | empty()))";
        };

        templates = {
          draft_commit_description = ''
            concat(
              coalesce(description, default_commit_description, "\n"),
              surround(
                "\nJJ: This commit contains the following changes:\n", "",
                indent("JJ:     ", diff.stat(72)),
              ),
              "\nJJ: ignore-rest\n",
              diff.git(),
            )
          '';
        };
      };
    };

    # Enable JJ integration in starship
    shell.starship.enableJJ = true;

    # Add shell aliases and functions
    zsh.aliases = {
      jjs = "jj split";
      jja = "jj squash"; # Append current revision into previous
      jjl = "jj log -r 'latest(present(@) | ancestors(immutable_heads().., 2) | present(trunk()), 5)' --no-pager";
    };

    zsh.functions = [
      ''
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
      ''
      ''
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
      ''
    ];
  };
}
