{...}: {
  config = {
    # Install and configure the github cli
    programs.gh = {
      enable = true;
    };
  };
}
