{pkgs, ...}: {
  packages = with pkgs; [
    rustc
    cargo
  ];
}
