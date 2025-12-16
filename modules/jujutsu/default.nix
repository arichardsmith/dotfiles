{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.jujutsu;
in {
  config = lib.mkIf cfg.enable {
    # Install and configure jujutsu
    programs.jujutsu = {
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
            "closest_pushable(@)"
          ];

          # Remove all empty revisions
          cleanup = ["abandon" "-r 'empty() ~ root()"];

          # Start a new revision based on the dev branch, falling back to main
          fresh = ["new" "-r 'coalesce(present(dev), main)'"];
        };

        revset-aliases = {
          "wip()" = "description(glob-i:\"wip:*\")";
          "closest_bookmark(to)" = "heads(::to & bookmarks())";
          "closest_pushable(to)" = "heads(::to ~ (description(exact:\"\") | empty() | descendants(wip())))";
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

    home.packages = [
      pkgs.jjui
    ];

    # Add shell aliases and functions
    shell.aliases = {
      jjs = "jj split";
      jja = "jj squash"; # Append current revision into previous
      jjl = "jj log -r 'main@origin:: | bookmarks() ~ ::trunk()' --no-pager";
      jjc = "jj commit";
    };

    shell.functions = [
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
  }; # end mkIf cfg.enable
}
