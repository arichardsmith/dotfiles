{pkgs, ...}: {
  config = {
    # Include the package
    home.packages = [
      pkgs.erdtree
    ];

    # Include our config
    home.file = {
      ".config/erdtree/.erdtree.toml".source = ./erdtree.toml;
    };

    # Add shell aliases and functions
    zsh.aliases = {
      ls = "erd --config ls";
      lsa = "erd --config ls --hidden";
      ols = "/bin/ls"; # Add an alias for normal ls incase we need it
    };
  };
}
