{...}: {
  config = {
    # This file is the Home Manager portion of the integrated NixOS config.
    # It is applied by `nixos-rebuild`, not by a separate `home-manager switch`.
    home.sessionVariables = {
      EDITOR = "hx";
    };

    # Keep the example small: enable a shell, VCS defaults, and prompt.
    programs.zsh.enable = true;
    programs.git.enable = true;
    programs.jujutsu.enable = true;
    programs.starship.enable = true;
  };
}
