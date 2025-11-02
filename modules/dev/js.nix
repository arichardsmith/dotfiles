{pkgs, ...}: {
  packages = with pkgs; [
    bun
    nodejs
    nodePackages.pnpm
  ];

  # Add globally installed bun packages to the PATH
  shellHook = ''
    export PATH="$HOME/.bun/bin:$PATH"
  '';
}
