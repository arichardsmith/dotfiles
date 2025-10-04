{...}: {
  config = {
    # Install the `nh` cli globally to help manage nix
    programs.nh = {
      enable = true;
    };
  };
}
