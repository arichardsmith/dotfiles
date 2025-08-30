# Modules

This directory contains modular configurations for different tools and applications. Each module encapsulates the configuration for a specific piece of software or related group of tools.

## Architecture Principles

### Host Agnostic Design
Modules should be **host agnostic** wherever possible. Instead of hardcoding host-specific values, modules should:
- Use options to make configuration customizable
- Allow hosts to override settings through configuration
- Avoid assumptions about the target system (macOS vs Linux, development vs production)

### Self-Contained Configuration
Each module should:
- Contain all configuration files needed for its tool
- Include any themes, templates, or custom configurations in its directory
- Be independently importable without dependencies on other modules (except where explicitly needed)

### Clear Structure
Most modules follow this pattern:
```
module-name/
├── default.nix          # Main module configuration
├── config-file.conf     # Tool-specific configuration files
└── other-assets/        # Additional resources (themes, templates, etc.)
```

## Module Categories

### Terminal & Shell
- `bat/` - Syntax highlighting for file viewing with Catppuccin theme
- `erdtree/` - Modern tree command replacement with custom configuration
- `ghostty/` - Terminal emulator configuration
- `shell/` - ZSH configuration, starship prompt, and shell utilities

### Development Tools
- `dev_tools/` - Meta-module that imports development-specific tools
- `bun/` - JavaScript/TypeScript runtime and package manager
- `colima/` - Container runtime for macOS
- `docker/` - Docker configuration

### Version Control
- `git/` - Git configuration and aliases
- `jujutsu/` - Modern version control system
- `gh/` - GitHub CLI configuration

## Usage Patterns

### Simple Module Example
```nix
{pkgs, ...}: {
  config = {
    programs.bat = {
      enable = true;
      config = {
        theme = "Catppuccin Macchiato";
      };
    };
  };
}
```

### Module with Options
```nix
{lib, config, pkgs, ...}: {
  options = {
    myTool.theme = lib.mkOption {
      type = lib.types.str;
      default = "dark";
      description = "Theme for myTool";
    };
  };
  
  config = {
    programs.myTool = {
      enable = true;
      theme = config.myTool.theme;
    };
  };
}
```

### Meta-Module (Grouping Related Modules)
```nix
{...}: {
  imports = [
    ./tool1.nix
    ./tool2.nix
    ./tool3.nix
  ];
}
```

## Adding New Modules

1. **Create the module directory**: `mkdir modules/new-tool`
2. **Add default.nix**: Main configuration file
3. **Include config files**: Add any tool-specific configuration files
4. **Import in host**: Add the module to the appropriate host configuration
5. **Test**: Ensure the module works independently and doesn't conflict with others

## Host Integration

Modules are imported by hosts in their configuration files. The explicit import pattern makes it clear which modules are available on each host, even though this creates some duplication across host files.