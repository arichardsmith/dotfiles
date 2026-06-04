# Design: Nix-Managed Ops Scripts Framework

## Overview

Introduce a `my.opsScripts` Home Manager option namespace backed by a single
`modules/ops_scripts/default.nix`. Enabled scripts are packaged using existing
`lib/` helpers and installed into `~/ops` via `home.file` symlinks. No PATH
changes are made.

The `my` prefix is a private namespace convention used throughout this repo to
distinguish custom options from upstream Home Manager / NixOS options.

## Architecture Changes

### Module layout

```
modules/
  ops_scripts/
    default.nix     # owns scripts attrset + auto-generates options & config
    scripts/
      update.sh     # shell script source
      rebuild.sh
      ...           # uv scripts would be .py
```

No per-script sub-module directories. `default.nix` is the single source of
truth: it declares which scripts exist, their types, and their source paths.
The `scripts/` folder holds source files only.

### Module shape

`modules/ops_scripts/default.nix`:

```nix
{lib, config, pkgs, helpers, ...}: let
  scripts = {
    update  = { type = "shell"; path = ./scripts/update.sh; };
    rebuild = { type = "shell"; path = ./scripts/rebuild.sh; };
    # backup = { type = "uv";    path = ./scripts/backup.py; };
  };

  mkPackage = name: {type, path}:
    if type == "shell"
    then helpers.scriptToPackage   {inherit name pkgs; file = path; runtimeInputs = [];}
    else helpers.uvScriptToPackage {inherit name pkgs; file = path;};
in {
  options.my.opsScripts = lib.mapAttrs (name: _: lib.mkEnableOption name) scripts;

  config = lib.mkMerge (lib.mapAttrsToList (name: script:
    lib.mkIf config.my.opsScripts.${name} {
      home.file."ops/${name}" = {
        source = "${mkPackage name script}/bin/${name}";
        executable = true;
      };
    }
  ) scripts);
}
```

Adding a new script is a one-liner in the `scripts` attrset; no new files or
directories are needed beyond the source script itself.

### Option shape

Each script exposes a single boolean enable option:

```nix
my.opsScripts.update  = true;
my.opsScripts.rebuild = true;
```

Per-script typed options (e.g. `flakePath`) are out of scope for the framework
itself — scripts read configuration from environment or dotfiles as needed.

### Packaging

`mkPackage` dispatches to the appropriate helper based on `type`:

- `"shell"` → `helpers.scriptToPackage` (`lib/script_to_package.nix`), which
  wraps `writeShellApplication` (runs shellcheck, rewrites shebang to Nix bash).
- `"uv"` → `helpers.uvScriptToPackage` (`lib/uv_script_to_package.nix`), which
  prepends a Nix-store uv shebang.

Both helpers are already present in `lib/`. The returned derivation exposes the
binary at `${drv}/bin/${name}`.

### Installation

Scripts are installed via `home.file`, not `home.packages`:

```nix
home.file."ops/${name}" = {
  source     = "${mkPackage name script}/bin/${name}";
  executable = true;
};
```

This places a symlink at `~/ops/<name>` pointing into the Nix store. `~/ops`
is not added to `PATH`.

### `my` namespace

No dedicated `modules/my/default.nix` is needed. The NixOS module system merges
`options.my.opsScripts` declared in `modules/ops_scripts/default.nix` with any
future `my.*` sub-namespaces declared in other modules automatically.

## Questions

### Open

_(none)_

### Resolved

- **`~/ops` vs `PATH`**: Scripts go in `~/ops`, not `home.packages`. Resolved in
  proposal.
- **Packaging helpers**: Both `scriptToPackage` and `uvScriptToPackage` already
  exist in `lib/`. No new helpers needed unless a third script type is required.
- **Per-script typed options**: Rejected. Scripts are enabled with a single
  boolean; configuration via environment or dotfiles as needed.
- **Namespace declaration**: No parent `my` module required — the module system
  merges sub-namespace declarations automatically.
- **Module structure**: Single `default.nix` with an internal `scripts` attrset
  rather than per-script sub-modules. Options and `home.file` entries are
  auto-generated via `lib.mapAttrs` / `lib.mkMerge`.
- **Script source location**: Sources live in `modules/ops_scripts/scripts/`.

## Notes

- `lib/uv_script_to_package.nix` prepends a Nix-store uv shebang, avoiding
  multi-argument shebang portability issues.
- `lib/script_to_package.nix` wraps `writeShellApplication`, which runs
  `shellcheck` and rewrites the shebang to a Nix-store bash.
- The `my` namespace prefix is a local convention; it does not conflict with
  upstream Home Manager or NixOS option trees.
