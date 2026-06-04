---
ready: true
---

# Tasks

## Resumption Notes

[Leave blank initially — filled in during implementation to record safe restart points and known blockers.]

## 1. Create the `ops_scripts` module skeleton

- [ ] Create `modules/ops_scripts/scripts/` directory (placeholder — can be empty until step 2)
- [ ] Create `modules/ops_scripts/default.nix` with the `scripts` attrset (empty initially), auto-generated options, and `lib.mkMerge` config block
- [ ] Import `./ops_scripts` from `modules/default.nix`
- [ ] Verify `nix eval 'path:.#homeConfigurations.laptop.activationPackage.drvPath'` succeeds

## 2. Add initial scripts

- [ ] Write `modules/ops_scripts/scripts/update.sh`
- [ ] Write `modules/ops_scripts/scripts/rebuild.sh`
- [ ] Add both to the `scripts` attrset in `default.nix` with `type = "shell"`
- [ ] Verify flake still evaluates cleanly

## 3. Enable scripts on a machine and validate

- [ ] Enable `my.opsScripts.update` and `my.opsScripts.rebuild` in at least one machine's `home.nix`
- [ ] Verify `nix eval 'path:.#homeConfigurations.<machine>.activationPackage.drvPath'` succeeds
- [ ] Run `home-manager switch` on that machine and confirm `~/ops/update` and `~/ops/rebuild` symlinks exist and are executable
- [ ] Manually invoke each script in a dry-run / no-op mode to verify they work end-to-end

## 4. Clean up and verify

- [ ] Confirm `~/ops` is not added to `PATH` anywhere (check `modules/shell/` and `modules/zsh/`)
- [ ] Run `nix flake check` and resolve any warnings
