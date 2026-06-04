# Proposal: Nix-Managed Ops Scripts Framework

## Problem & Goal

Operational scripts (system updates, Home Manager rebuilds, backups, cleanup
tasks) need a home that is:

- Declaratively managed via Nix / Home Manager — scripts and their dependencies
  are pinned and reproducible.
- Easy to discover and run manually — a single well-known directory (`~/ops`)
  makes them findable without being on `PATH`.
- Isolated from ambient system state — dependencies come from Nix packages, not
  whatever happens to be installed.

The goal is a lightweight framework: a Home Manager option namespace
(`my.opsScripts.*`) that lets individual scripts declare typed options, specify
their Nix-package dependencies, and be installed into `~/ops` as store symlinks.

## Scope

**In scope**

- A `my.opsScripts` Home Manager option namespace.
- A `modules/ops_scripts/` module tree containing option declarations and
  installation logic.
- Reusable packaging helpers in `lib/` for shell scripts and Python uv-scripts
  (both already exist; no new helpers needed unless gaps are found during
  implementation).
- Installation of enabled scripts into `~/ops` via `home.file` symlinks.

**Out of scope**

- Adding any ops scripts to `PATH` or `home.packages`.
- Providing a library of pre-written scripts — this change establishes the
  framework only; individual scripts come later.
- A generic `settings` attrset on scripts — each script exposes typed options
  directly.

## Solution Outline

1. Add a `modules/ops_scripts/` module directory and import it from
   `modules/default.nix`.
2. Declare a `my.opsScripts` option namespace. Each script sub-module follows
   the `programs.*` style: an `enable` option plus typed per-script options.
3. When a script is enabled, package it using the existing `scriptToPackage` or
   `uvScriptToPackage` helpers from `lib/`, then install it into `~/ops/<name>`
   via `home.file`.
4. Script source files live alongside their module (e.g.
   `modules/ops_scripts/update/script.sh`).
5. No `PATH` entries — `home.file` creates symlinks in `~/ops`, which is not
   added to `PATH`.
