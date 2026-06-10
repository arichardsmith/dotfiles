# Home Manager Configuration

Nix flake for managing dotfiles and packages across machines using home-manager.

## Quick Start

```bash
just install
```

This will switch to the latest version of the config if the machine is configured in the `DOTFILE_MACHINE` environment variable.

To update the flake lock file before switching:

```bash
nix flake update && just install
```

Otherwise, a machines home-manager config can be installed with:

```bash
home-manager switch --flake .#<machine>
```

## Configuration

### Machine Configuration

Machine configs are in `machines/<name>/`. Each machine sets:

1. **User details** - username, email, full name
2. **Individual programs** - specific program settings
3. **Machine-specific packages** - additional packages for this machine

### Program Options

Programs can be configured with `settings`:

```nix
my.programs.colima.settings = {
  cpu = 4;
  memory = 3;
  disk = 60;
};
```

Built-in home-manager programs use their standard options:

```nix
programs.git.userName = "Your Name";
programs.starship.settings.format = "...";
```

## Structure

```
├── flake.nix           # Flake definition
├── home.nix            # Core user/host options
├── machines/           # Machine-specific configs
│   └── laptop/
│       ├── default.nix    # User info & base settings
│       └── programs.nix   # Enabled packs & programs
── modules/            # Individual program modules
└── lib/                # Helper functions
```

## Adding Machines

Create `machines/<name>/default.nix`:

```nix
{...}: {
  imports = [ ./programs.nix ];

  config = {
    user.username = "your-username";
    user.email = "you@example.com";
    user.fullName = "Your Name";
  };
}
```

Add to `flake.nix`:

```nix
homeConfigurations = {
  your-machine = mkHomeConfig "aarch64-darwin" ./machines/your-machine;
};
```
