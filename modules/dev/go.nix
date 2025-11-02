{pkgs, ...}: {
  packages = with pkgs; [
    go
    gopls # Language server
    gotools # goimports, godoc, etc
    go-tools # staticcheck and other tools
  ];
}
