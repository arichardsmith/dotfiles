# Home Manager Configuration

Nix flake for managing dotfiles and packages across machines using home-manager.

## Quick Start

```bash
home-manager switch --flake .#laptop
```

## Configuration

### Machine Configuration

Machine configs are in `machines/<name>/`. Each machine sets:

1. **User details** - username, email, full name
2. **Enabled packs** - groups of related programs
3. **Individual programs** - specific program settings
4. **Machine-specific packages** - additional packages for this machine

### Available Packs

Packs are collections of related programs:

- **`packs.shell`** - Terminal utilities (zsh, starship, bat, ripgrep, fzf, fd, etc)
- **`packs.system`** - System monitoring tools (btop, etc)
- **`packs.dev`** - Development tools (git, jujutsu, gh, docker tools)

### Program Options

Programs can be configured with `settings`:

```nix
customPrograms.colima.settings = {
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
├── packs/              # Program collections
│   ├── shell/          # Terminal tools pack
│   ├── system/         # System monitoring pack
│   └── dev/            # Development tools pack
├── modules/            # Individual program modules
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
