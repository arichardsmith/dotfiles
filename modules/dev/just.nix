{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [
      just
      just-lsp
    ];
  };
}
