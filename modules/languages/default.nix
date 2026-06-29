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
    ./css.nix
    ./svelte.nix
  ];

  options.my.languages = {
    python.enable = lib.mkEnableOption "python language tooling";
    markdown.enable = lib.mkEnableOption "markdown language tooling";
    just.enable = lib.mkEnableOption "just language tooling";
    toml.enable = lib.mkEnableOption "toml language tooling";
    yaml.enable = lib.mkEnableOption "yaml language tooling";
    json.enable = lib.mkEnableOption "json language tooling";
    js.enable = lib.mkEnableOption "js/ts language tooling";
    nix.enable = lib.mkEnableOption "nix language tooling";
    rust.enable = lib.mkEnableOption "rust language tooling";
    go.enable = lib.mkEnableOption "go language tooling";
    lua.enable = lib.mkEnableOption "lua language tooling";
    css.enable = lib.mkEnableOption "css language tooling";
    svelte.enable = lib.mkEnableOption "svelte language tooling";
  };
}
