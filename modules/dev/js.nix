{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [
      bun # Bun is my current global JS runtime of choice
      (writeShellScriptBin "ijs" ./scripts/ijs.sh)
      (writeShellScriptBin "pkq" ./scripts/pkq.sh)
    ];

    # Add globally installed bun packages to the PATH
    programs.zsh.initContent = ''
      export PATH="$HOME/.bun/bin:$PATH"
    '';
  };
}
