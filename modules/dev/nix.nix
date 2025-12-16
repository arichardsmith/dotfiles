{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [
      # nix language server
      nixd
    ];

    # Install the `nh` cli globally to help manage nix
    programs.nh = {
      enable = true;
    };
  };
}
