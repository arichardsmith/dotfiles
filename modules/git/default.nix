{config, ...}: {
  config = {
    programs.git = {
      settings = {
        user = {
          name = config.user.fullName;
          email = config.user.email;
        };

        init = {
          defaultBranch = "main";
        };

        core = {
          editor = "nvim";
        };

        filter.lfs = {
          required = true;
          clean = "git-lfs clean -- %f";
          smudge = "git-lfs smudge -- %f";
          process = "git-lfs filter-process";
        };

        format = {
          pretty = "oneline";
        };

        log = {
          abbrevCommit = true;
        };

        alias = {
          bs = "!git switch $(git branch | fzf); #";
          rb = "!git rebase --interactive --autosquash $1; #";
          actions = "!gh run watch";
          append = "!git commit --amend --no-edit; #";
          wip = "!git add . && git commit -m WIP; #";
          root = "rev-parse --show-toplevel";
          hist = "log --graph --abbrev-commit --decorate --date=short --format=format:'%C(bold cyan)%h%C(reset) %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(bold yellow)%d%C(reset)' --branches --remotes --tags";
        };

        credential."https://github.com" = {
          useHttpPath = true;
          helper = [
            "" # Clear existing helpers
            "!/opt/homebrew/bin/gh auth git-credential"
          ];
        };

        credential."https://gist.github.com" = {
          helper = [
            "" # Clear existing helpers
            "!/opt/homebrew/bin/gh auth git-credential"
          ];
        };
      };
    };
  };
}
