# Updating version-pinned tools

oxfmt, Claude Code, and OpenCode are installed from prebuilt npm binaries pinned by hash
in `pkgs/oxfmt.nix`, `pkgs/claude-code.nix`, and `pkgs/opencode.nix`.

## Check current versions

```bash
curl -s https://registry.npmjs.org/oxfmt/latest | jq -r '.version'
curl -s https://registry.npmjs.org/@anthropic-ai/claude-code/latest | jq -r '.version'
curl -s https://registry.npmjs.org/opencode-ai/latest | jq -r '.version'
```

## Update a tool (example: oxfmt 0.54.0 → 0.55.0)

1. Compute the new hashes for both platform tarballs:

```bash
nix store prefetch-file --hash-type sha256 \
  https://registry.npmjs.org/oxfmt/-/oxfmt-0.55.0.tgz

nix store prefetch-file --hash-type sha256 \
  https://registry.npmjs.org/@oxfmt/binding-darwin-arm64/-/binding-darwin-arm64-0.55.0.tgz

nix store prefetch-file --hash-type sha256 \
  https://registry.npmjs.org/@oxfmt/binding-linux-x64-gnu/-/binding-linux-x64-gnu-0.55.0.tgz
```

2. Edit `pkgs/oxfmt.nix`: update `version` and both `hash` values.

3. Verify the flake evaluates:

```bash
nix eval 'path:.#homeConfigurations.laptop.activationPackage.drvPath'
```

4. Switch as normal. Only the edited tool's derivation is rebuilt.

For claude-code and opencode (single platform tarball each), only two hashes are needed
(one per platform). The package names are listed at the top of each file in `pkgs/`.
