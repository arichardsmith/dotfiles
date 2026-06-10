{lib, ...}: {
  imports = [
    ./python.nix
    ./markdown.nix
    ./just.nix
    ./toml.nix
    ./yaml.nix
    ./json.nix
    ./js.nix
    ./nix.nix
    ./rust.nix
    ./go.nix
    ./lua.nix
  ];

  options.my.devtools = {
    python.enable = lib.mkEnableOption "python dev tools";
    markdown.enable = lib.mkEnableOption "markdown dev tools";
    just.enable = lib.mkEnableOption "just dev tools";
    toml.enable = lib.mkEnableOption "toml dev tools";
    yaml.enable = lib.mkEnableOption "yaml dev tools";
    json.enable = lib.mkEnableOption "json dev tools";
    js.enable = lib.mkEnableOption "js/ts dev tools";
    nix.enable = lib.mkEnableOption "nix dev tools";
    rust.enable = lib.mkEnableOption "rust dev tools";
    go.enable = lib.mkEnableOption "go dev tools";
    lua.enable = lib.mkEnableOption "lua dev tools";
  };
}
