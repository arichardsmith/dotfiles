{pkgs, ...}: {
  packages = with pkgs; [
    bun
    deno
    nodejs_22 # Pinning to v22 as that's what work requires and I haven't got time to set up a custom flake
    nodePackages.pnpm
  ];

  scripts = {
    ijs = ./scripts/ijs.sh;
    pkq = ./scripts/pkq.sh;
  };

  # Add globally installed bun packages to the PATH
  shellHook = ''
    export PATH="$HOME/.bun/bin:$PATH"
  '';
}
