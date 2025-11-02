# Dotfiles, tool config and code snippets

## Dev Env

This flake defines a general dev environment for working with javascript, rust, go and nix projects. It is not enabled by default on any machines.

To load the environment into the current shell, instead of switching to a new shell with `nix develop` you can run `source ./devenv`.

## Hosts

Host configurations are defined in `hosts/`, current hosts are:
- `laptop` - my macbook
- `nas-services` - the Nixos VM running on my NAS

## Modules

These are host independent config for various tools.
