# Home Manager Repository

## Structure

```
├── flake.nix           # Flake definition with homeConfigurations
├── home.nix            # Core options (user.*, host.*)
├── machines/           # Machine-specific configs
│   └── laptop/
│       ├── default.nix    # User identity & machine settings
│       └── programs.nix   # Enabled packs & programs
├── packs/              # Program collections
│   ├── shell/          # Terminal tools
│   ├── system/         # System monitoring
│   └── dev/            # Development tools
├── modules/            # Individual program modules
│   └── <program>/default.nix
└── lib/                # Helpers (mkProgram, scriptToPackage)
```

## Option Paths

- `user.username`, `user.email`, `user.fullName`, `user.homeDirectory` - User identity
- `host.name` - Machine name
- `packs.<name>.enable` - Enable pack (collection of programs)
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

## Creating Packs

```nix
# packs/mypack/default.nix
{config, lib, pkgs, ...}: let
  cfg = config.packs.mypack;
in {
  config = lib.mkIf cfg.enable {
    programs.git.enable = true;
    customPrograms.myapp.enable = true;
    home.packages = [pkgs.sometool];
  };
}
```

Add option to `packs/default.nix`:
```nix
options.packs = {
  mypack.enable = lib.mkEnableOption "my pack description";
};
```

Add to imports in `packs/default.nix`.

## Machine Configuration

In `machines/<name>/programs.nix`:

```nix
{pkgs, lib, ...}: {
  config = {
    # Enable packs
    packs = {
      shell.enable = true;
      dev.enable = true;
    };

    # Enable/configure programs
    programs.neovim.enable = true;

    customPrograms = {
      ghostty.enable = true;
      colima = {
        enable = true;
        settings.cpu = 4;
      };
    };

    # Extra packages
    home.packages = [pkgs.ffmpeg];
  };
}
```

## Lib Helpers

**`lib.helpers.mkProgram`** - Creates a module with enable option and typed settings at `customPrograms.<name>`

**`lib.helpers.scriptToPackage`** - Wraps a shell script as a package for `home.packages`

## Common Tasks

**Add tool to dev pack:**
1. Create `modules/mytool/default.nix` (simple or with mkProgram)
2. Add to `modules/default.nix` imports
3. Add to `packs/dev/default.nix`: `customPrograms.mytool.enable = true;`

**Add new machine:**
1. Create `machines/<name>/default.nix` with user identity
2. Create `machines/<name>/programs.nix` with enabled packs/programs
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
