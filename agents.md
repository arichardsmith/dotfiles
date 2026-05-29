# Home Manager Repository

## Structure

```
├── flake.nix           # Flake definition with homeConfigurations
├── home.nix            # Core options (user.*, host.*)
├── machines/           # Machine-specific configs
│   └── laptop/
│       ├── default.nix    # User identity & machine settings
│       └── programs.nix   # Enabled programs
├── modules/            # Individual program modules
│   └── <program>/default.nix
├── scripts/            # Shared shell scripts
└── lib/                # Helpers (mkProgram, scriptToPackage)
```

## Option Paths

- `user.username`, `user.email`, `user.fullName`, `user.homeDirectory` - User identity
- `host.name` - Machine name
- `programs.<name>.*` - Built-in home-manager programs (git, neovim, etc)
- `customPrograms.<name>.enable` - Custom program modules using mkProgram
- `customPrograms.<name>.settings.*` - Program-specific settings

## Adding Programs

### Simple program (package only)

```nix
# modules/myapp/default.nix
{pkgs, ...}: {
  config = {
    home.packages = [pkgs.myapp];
  };
}
```

Then add to `modules/default.nix` imports.

### Program with settings (using mkProgram)

```nix
# modules/myapp/default.nix
{config, pkgs, lib, ...}:
lib.helpers.mkProgram {inherit config pkgs;} "myapp" {
  settings = {
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
    };
  };

  setup = {pkgs, cfg, ...}: {
    home.packages = [pkgs.myapp];
    xdg.configFile."myapp/config.toml".text = ''
      port = ${toString cfg.settings.port}
    '';
  };
}
```

Then add to `modules/default.nix` imports.

**Usage in machine config:**
```nix
customPrograms.myapp = {
  enable = true;
  settings.port = 9000;
};
```

### Built-in home-manager programs

Configure directly without creating a module:

```nix
# modules/git/default.nix - just sets defaults
{config, ...}: {
  config = {
    programs.git = {
      settings = {
        user.name = config.user.fullName;
        init.defaultBranch = "main";
        # ... more settings
      };
    };
  };
}
```

## Machine Configuration

In `machines/<name>/programs.nix`:

```nix
{pkgs, lib, ...}: {
  config = {
    programs = {
      zsh.enable = true;
      neovim.enable = true;
    };

    customPrograms = {
      ghostty.enable = true;
      colima = {
        enable = true;
        settings.cpu = 4;
      };
    };

    home.packages = [pkgs.ffmpeg];
  };
}
```

## Lib Helpers

**`lib.helpers.mkProgram`** - Creates a module with enable option and typed settings at `customPrograms.<name>`

**`lib.helpers.scriptToPackage`** - Wraps a shell script as a package for `home.packages`

## Common Tasks

**Add a program to a machine:**
1. Create `modules/mytool/default.nix` (simple or with mkProgram)
2. Add to `modules/default.nix` imports
3. Enable in `machines/<name>/programs.nix`

**Add new machine:**
1. Create `machines/<name>/default.nix` with user identity
2. Create `machines/<name>/programs.nix` with enabled programs
3. Add to `flake.nix` homeConfigurations

**Override program settings per machine:**
```nix
# In machines/laptop/programs.nix
customPrograms.colima.settings.cpu = 8;
programs.git.userName = "Different Name";
```

## Testing

```bash
# Switch to configuration
home-manager switch --flake .#laptop

# Check flake
nix flake check
```
