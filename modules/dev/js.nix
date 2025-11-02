{pkgs, ...}: {
  packages = with pkgs; [
    bun
    deno
    nodejs
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
