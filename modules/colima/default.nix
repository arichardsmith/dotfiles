{
  pkgs,
  lib,
  ...
}: {
  config = {
    home.packages = with pkgs; [colima];

    # Copy the config instead of symlinking it
    # Colima updates the config file itself, so isn't compatible with read only symlinks
    home.activation.colimaConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -f ~/.colima/default/colima.yaml ]; then
        mkdir -p ~/.colima/default
        cp ${./colima.yaml} ~/.colima/default/colima.yaml
        chmod 644 ~/.colima/default/colima.yaml
      fi
    '';
  };
}
