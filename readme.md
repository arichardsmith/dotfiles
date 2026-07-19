# Home Manager and nix-darwin Configuration

Nix flake for managing dotfiles and packages across machines using Home Manager, nix-darwin, and NixOS.

## Quick Start

```bash
just rebuild mba
just rebuild mininas
```

The installed `~/ops/rebuild` script defaults to the machine named by `DOTFILE_MACHINE`, which is set from each machine's configuration. Pass `--machine <name>` to override it.

Use `home-manager switch --flake .#mininas` for the standalone Home Manager machine and `sudo darwin-rebuild switch --flake .#mba` for MBA. On macOS, `~/ops/rebuild` and `~/ops/rollback` use nix-darwin; on other platforms they use Home Manager.

## Configuration

### Machine Configuration

Machine configs are in `machines/<name>/`. Each machine file returns a concrete flake output and defines facts in `machine`:

1. **User details** - username, email, full name
2. **Host details** - hostname and related machine facts
3. **Output type** - `darwinSystem`, `homeManagerConfiguration`, or `nixosSystem`

### Program Options

Programs can be configured with `settings`:

```nix
programs.colima.settings = {
  cpu = 4;
  memory = 3;
  disk = 60;
};
```

Built-in Home Manager programs use their standard options:

```nix
programs.git.userName = "Your Name";
programs.starship.settings.format = "...";
```

## Structure

```
├── flake.nix           # Flake definition
├── machines/           # Machine entrypoints and per-machine modules
├── modules/            # Shared Home Manager modules
└── lib/                # Helper functions
```

## Updating version-pinned tools

See [docs/updating-js-tools.md](docs/updating-js-tools.md).

## Adding Machines

Create `machines/<name>/default.nix` with the appropriate output type and machine facts:

```nix
{inputs, common}: let
  machine = {
    system = "aarch64-darwin";

    user = {
      username = "your-username";
      email = "you@example.com";
      fullName = "Your Name";
    };

    host.name = "your-machine";
  };

  nix = common.mkNix machine.system;
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit (nix) pkgs lib;

  extraSpecialArgs = {
    inherit machine;
    helpers = nix.helpers;
  };

  modules = [
    (common.mkHomeManager machine)
    ./home.nix
  ];
}
```

Add the machine directly in `flake.nix`:

```nix
homeConfigurations.your-machine = import ./machines/your-machine {
  inherit inputs common;
};
```
