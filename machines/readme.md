# Machines

Each directory in `machines/` describes one machine. The top-level flake decides whether a machine path is exposed as a standalone Home Manager configuration or as a NixOS configuration with integrated Home Manager.

## Layout

```text
machines/<name>/
  default.nix   # Machine metadata and module lists
  home.nix      # Machine-specific Home Manager config
  nixos.nix     # Machine-specific NixOS config, when applicable
```

`default.nix` is data, not a module. It is imported by `lib/configurations.nix`.

## Metadata

A standalone Home Manager machine looks like this:

```nix
{
  system = "x86_64-linux";

  user = {
    username = "richard";
    email = "richard@example.com";
    fullName = "Richard Smith";
  };

  host = {
    name = "mininas";
    tailscale.ipv4 = "100.111.24.65";
  };

  homeModules = [
    ./home.nix
  ];
}
```

A NixOS machine adds `nixosModules`:

```nix
{
  system = "x86_64-linux";

  user = {
    username = "richard";
    email = "richard@example.com";
    fullName = "Richard Smith";
  };

  host = {
    name = "example";
  };

  homeModules = [
    ./home.nix
  ];

  nixosModules = [
    ./nixos.nix
  ];
}
```

## Flake Outputs

Machines are registered in `flake.nix` by path:

```nix
homeConfigurations = configurations.mkHomeConfigs {
  mba = ./machines/mba;
  mininas = ./machines/mininas;
};

nixosConfigurations = configurations.mkNixosConfigs {
  example = ./machines/example;
};
```

The same selector style is used for both output types:

```sh
home-manager switch --flake .#mininas
nixos-rebuild switch --flake .#example
```

`home-manager` reads `homeConfigurations.<name>`. `nixos-rebuild` reads `nixosConfigurations.<name>`.

## Module Arguments

Home Manager and NixOS modules receive machine metadata through the `machine` argument:

```nix
{machine, ...}: {
  programs.git.settings.user = {
    name = machine.user.fullName;
    email = machine.user.email;
  };
}
```

Custom helpers are passed through the `helpers` argument:

```nix
{helpers, ...}: {
  home.packages = [
    (helpers.scriptToPackage {
      name = "my-script";
      file = ./scripts/my-script.sh;
    })
  ];
}
```

Do not add new `user.*` or `host.*` Home Manager options. Put machine facts in `machines/<name>/default.nix` and read them from `machine`.

## NixOS Machines

NixOS machines use integrated Home Manager. Their Home Manager modules are applied by `nixos-rebuild`, so do not run a separate `home-manager switch` for those machines.

Remote deployment should use a dedicated deploy user:

```sh
nixos-rebuild switch \
  --flake .#example \
  --target-host deploy@example \
  --build-host deploy@example \
  --use-remote-sudo
```

Standalone Home Manager machines can be deployed directly as the target user:

```sh
home-manager switch \
  --flake .#mininas \
  --target-host richard@mininas \
  --build-host richard@mininas
```

## Adding A Machine

For a standalone Home Manager machine:

1. Create `machines/<name>/default.nix` with `system`, `user`, `host`, and `homeModules`.
2. Create `machines/<name>/home.nix` for machine-specific Home Manager config.
3. Add the path to `homeConfigurations = configurations.mkHomeConfigs { ... };`.

For a NixOS machine:

1. Create `machines/<name>/default.nix` with `system`, `user`, `host`, `homeModules`, and `nixosModules`.
2. Create `machines/<name>/home.nix` for integrated Home Manager config.
3. Create `machines/<name>/nixos.nix` for system config.
4. Add the path to `nixosConfigurations = configurations.mkNixosConfigs { ... };`.

## Verification

Evaluate outputs from the working tree with:

```sh
nix eval 'path:.#homeConfigurations.<name>.activationPackage.drvPath'
nix eval 'path:.#nixosConfigurations.<name>.config.system.build.toplevel.drvPath'
```
