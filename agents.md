# Home Manager And NixOS Repository

This repository manages machine configuration with Nix flakes. It supports standalone Home Manager machines and NixOS machines with integrated Home Manager.

For user-facing setup and general usage, read [`readme.md`](./readme.md).

For machine metadata, machine layout, and remote deployment details, read [`machines/readme.md`](./machines/readme.md).

## Structure

```text
├── flake.nix              # Imports machine outputs directly
├── machines/              # Machine metadata and per-machine config
├── modules/               # Shared Home Manager modules
├── justfile               # Common project tasks
└── lib/                   # Shared helper functions
```

`flake.nix` imports each machine file directly and uses the output it returns:

```nix
darwinConfigurations.mba = import ./machines/mba { inherit inputs common; };
homeConfigurations.mininas = import ./machines/mininas { inherit inputs common; };
nixosConfigurations.example = import ./machines/example { inherit inputs common; };
```

## Working In This Repo

Use `jj`, not Git, for version-control mutations. Do not run `git add`, `git commit`, `git checkout`, or other mutating Git commands.

Forgejo is the canonical upstream and issue tracker for this repository. The `origin` remote points to Forgejo, while `gh` points to a GitHub mirror. Use the `fj` CLI with `-R origin` for issue management instead of GitHub tooling. Read [`.agents/skills/fj-issues/SKILL.md`](./.agents/skills/fj-issues/SKILL.md) for the issue workflow.

Use `path:.` when evaluating flakes from the working tree, especially after adding new files:

```bash
nix eval 'path:.#darwinConfigurations.mba.system'
nix eval 'path:.#homeConfigurations.mininas.activationPackage.drvPath'
nix eval 'path:.#nixosConfigurations.example.config.system.build.toplevel.drvPath'
```

Run `nix flake check` when broader verification is needed.

## Module Conventions

Machine metadata is passed to modules as the `machine` argument.

Use this:

```nix
{machine, ...}: {
  programs.git.settings.user.email = machine.user.email;
}
```

Do not use custom `config.user.*` or `config.host.*` options.

Shared helper functions are passed as the `helpers` argument.

Use this:

```nix
{config, helpers, pkgs, ...}:
helpers.mkProgram {inherit config pkgs;} "myapp" { ... }
```

Do not use `lib.helpers.*` in modules.

## Adding Things

When adding or changing machines, follow [`machines/readme.md`](./machines/readme.md).

When adding shared Home Manager modules, put them under `modules/<name>/default.nix`, import them from `modules/default.nix`, and enable them from a machine `home.nix`.

For NixOS machines, put system config in `machines/<name>/nixos.nix`. Do not run a separate `home-manager switch` for NixOS machines that use integrated Home Manager.
