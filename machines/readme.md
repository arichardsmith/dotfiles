# Machines

Each directory in `machines/` describes one machine. The top-level flake imports the machine file directly and uses the concrete flake output it returns.

## Layout

```text
machines/<name>/
  default.nix   # Machine facts and direct output
  nixos.nix     # Machine-specific NixOS config, when applicable
```

`default.nix` is the flake entrypoint for that machine. It defines machine facts and returns a `homeManagerConfiguration` or `nixosSystem`.

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

  # returns homeManagerConfiguration
}
```

A NixOS machine returns a `nixosSystem` and lists its modules directly:

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

  # returns nixosSystem
}
```

## Flake Outputs

Machines are registered in `flake.nix` by path:

```nix
homeConfigurations.mba = import ./machines/mba { inherit inputs common; };
homeConfigurations.mininas = import ./machines/mininas { inherit inputs common; };
nixosConfigurations.example = import ./machines/example { inherit inputs common; };
```

The same selector style is used for both output types:

```sh
home-manager switch --flake .#mininas
nixos-rebuild switch --flake .#example
```

`home-manager` reads `homeConfigurations.<name>` and `nixos-rebuild` reads `nixosConfigurations.<name>`.

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

1. Create `machines/<name>/default.nix` with `system`, `user`, `host`, and a direct `homeManagerConfiguration` return.
3. Add the path to `homeConfigurations.<name> = import ./machines/<name> { inherit inputs common; };`.

For a NixOS machine:

1. Create `machines/<name>/default.nix` with `system`, `user`, `host`, and a direct `nixosSystem` return.
3. Create `machines/<name>/nixos.nix` for system config.
4. Add the path to `nixosConfigurations.<name> = import ./machines/<name> { inherit inputs common; };`.

## Verification

Evaluate outputs from the working tree with:

```sh
nix eval 'path:.#homeConfigurations.<name>.activationPackage.drvPath'
nix eval 'path:.#nixosConfigurations.<name>.config.system.build.toplevel.drvPath'
```
