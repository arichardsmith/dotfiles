# Hosts

This directory contains host-specific configurations for different machines. Each host configuration defines what modules to import and sets host-specific options like user details, machine role, and system-specific overrides.

## Architecture

### Host Inheritance Pattern
All hosts should follow this pattern:
1. **Import required modules** - Explicitly list all needed modules from `../modules/`
2. **Set user configuration** - Username, email, full name
3. **Define host properties** - Machine name, role, capabilities
4. **Add host-specific overrides** - Environment variables, aliases, tool-specific settings

### Current Hosts

#### `laptop.nix`
Main development laptop configuration for macOS systems. Includes:
- Full terminal setup (ghostty, shell, erdtree, bat)
- Version control tools (git, jujutsu, gh) 
- Development runtime (colima, docker, bun)
- Development role with associated tooling

## Host Configuration Structure

### Required Sections

#### Module Imports
```nix
imports = [
  # Terminal
  ../modules/ghostty
  ../modules/shell
  
  # Version control  
  ../modules/git
  ../modules/jujutsu
  
  # Development tools
  ../modules/colima
  ../modules/docker
];
```

**Import Duplication is Intentional**: While this creates some duplication across host files, it makes the available modules immediately clear when reading each host configuration. This explicit approach is preferred over implicit inheritance.

#### User Configuration
```nix
user.username = "username";
user.email = "user@example.com";
user.fullName = "Full Name";
```

#### Host Properties
```nix
host.name = "machine-name";
host.role = ["development"]; # or ["server"], ["desktop"], etc.
```

#### Environment & Overrides
```nix
home.sessionVariables = {
  EDITOR = "nvim";
  CUSTOM_VAR = "value";
};

zsh.aliases = {
  custom-alias = "command";
};
```

### Host Roles

The `host.role` option enables conditional module behavior:

- **`development`** - Enables development-specific tools and configurations
- **`server`** - Server-focused minimal configuration
- **`desktop`** - Desktop environment tools and applications

Modules can check `host.role` to conditionally enable features:
```nix
config = lib.mkIf (builtins.elem "development" config.host.role) {
  # Development-only configuration
};
```

## Host-Specific Patterns

### macOS Hosts
- May need Nix daemon initialization in zsh
- Often include application-specific paths and aliases
- Use Colima for container runtime instead of native Docker

### Linux Hosts
- Direct Docker daemon access
- Different shell initialization patterns
- May need different display/window manager configurations

### Development Hosts  
- Import full development toolchain
- Enable language servers and development tools
- Include container runtime and build tools

### Server Hosts
- Minimal module imports
- Focus on system administration tools
- No GUI applications or themes

## Adding New Hosts

1. **Create host file**: `hosts/new-host.nix`
2. **Import needed modules**: Add all required module imports
3. **Set user configuration**: Username, email, full name
4. **Define host properties**: Name, role, specific settings
5. **Add to flake.nix**: Include in `homeConfigurations`

Example:
```nix
{...}: {
  imports = [
    ../modules/shell
    ../modules/git
  ];

  config = {
    user.username = "user";
    user.email = "user@example.com";
    user.fullName = "User Name";
    
    host.name = "new-host";
    host.role = ["server"];
  };
}
```

## Testing Host Configurations

Test a host configuration with:
```bash
home-manager switch --flake ./repo#hostname
```

## Design Philosophy

Host configurations should be:
- **Explicit** - Clear about what modules they import
- **Specific** - Tailored to the actual machine's use case  
- **Minimal** - Only import modules that are actually needed
- **Readable** - Easy to understand what's configured at a glance