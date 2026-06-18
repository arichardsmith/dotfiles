#!/usr/bin/env -S uv run --script
import json
import subprocess
import sys
import urllib.error
import urllib.request
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

TOOL_FILES = {
    "oxfmt": "pkgs/oxfmt.nix",
    "claude-code": "pkgs/claude-code.nix",
    "opencode": "pkgs/opencode.nix",
}


def run(cmd, **kwargs):
    return subprocess.run(cmd, capture_output=True, text=True, **kwargs)


def get_tool_meta():
    result = run(["nix", "eval", "--json", "path:./pkgs#lib.toolMeta"], cwd=REPO_ROOT)
    if result.returncode != 0:
        print(f"nix eval failed: {result.stderr}", file=sys.stderr)
        sys.exit(1)
    return json.loads(result.stdout)


def get_npm_latest(name):
    try:
        resp = urllib.request.urlopen(
            f"https://registry.npmjs.org/{name}/latest", timeout=30
        )
        return json.loads(resp.read()).get("version")
    except (urllib.error.URLError, json.JSONDecodeError):
        return None


def prefetch_hash(url):
    result = run(
        [
            "nix",
            "store",
            "prefetch-file",
            "--hash-type",
            "sha256",
            "--json",
            url,
        ],
        timeout=300,
    )
    if result.returncode != 0:
        print(f"  prefetch failed for {url}: {result.stderr}", file=sys.stderr)
        return None
    try:
        return json.loads(result.stdout).get("hash")
    except json.JSONDecodeError:
        return None


def update_nix_file(filepath, main_updates, dep_updates):
    path = REPO_ROOT / filepath
    with open(path) as f:
        content = f.read()

    changed = False

    for old_ver, new_ver, hash_pairs in main_updates:
        old_line = f'version = "{old_ver}"'
        new_line = f'version = "{new_ver}"'
        if old_line in content:
            content = content.replace(old_line, new_line)
            changed = True

        for old_hash, new_hash in hash_pairs:
            content = content.replace(old_hash, new_hash)
            changed = True

    for _dep_name, old_ver, new_ver, hash_pairs in dep_updates:
        old_line = f'version = "{old_ver}"'
        new_line = f'version = "{new_ver}"'
        if old_line in content:
            content = content.replace(old_line, new_line)
            changed = True

        for old_hash, new_hash in hash_pairs:
            content = content.replace(old_hash, new_hash)
            changed = True

    if changed:
        with open(path, "w") as f:
            f.write(content)

    return changed


def yesno(prompt):
    while True:
        response = input(f"{prompt} [y/N] ").strip().lower()
        if response in ("y", "yes"):
            return True
        if response in ("n", "no", ""):
            return False
        print("Please answer y or n.")


def main():
    meta = get_tool_meta()
    updates_by_file = {}

    for tool_key, tool_data in meta.items():
        filepath = TOOL_FILES.get(tool_key)
        if not filepath:
            print(f"  Unknown tool key: {tool_key}, skipping")
            continue

        name = tool_data["name"]
        version = tool_data["version"]
        tarballs = tool_data.get("tarballs", {})
        deps = tool_data.get("deps", {})

        print(f"\n\033[1m{name}\033[0m ({tool_key})")
        latest = get_npm_latest(name)
        if latest is None:
            print("  \u2716 Could not check npm")
            continue

        if version != latest:
            print(f"  {version} \u2192 {latest}")
            if yesno(f"  Update to {latest}?"):
                hash_pairs = []
                for tarball_key, tarball in tarballs.items():
                    old_url = tarball["url"]
                    old_hash = tarball["hash"]
                    new_url = old_url.replace(version, latest)
                    print(f"  \u21b3 Prefetching {tarball_key}...", end=" ", flush=True)
                    new_hash = prefetch_hash(new_url)
                    if new_hash is None:
                        print("\u2716")
                        continue
                    print("\u2713")
                    hash_pairs.append((old_hash, new_hash))

                if filepath not in updates_by_file:
                    updates_by_file[filepath] = {"main": [], "deps": []}
                updates_by_file[filepath]["main"].append((version, latest, hash_pairs))
        else:
            print(f"  {version} (\u2713 up to date)")

        for dep_key, dep_data in deps.items():
            dep_name = dep_data["name"]
            dep_version = dep_data["version"]
            dep_tarballs = dep_data.get("tarballs", {})

            print(f"  \u2514 \033[1m{dep_name}\033[0m (dep)")
            dep_latest = get_npm_latest(dep_name)
            if dep_latest is None:
                print("    \u2716 Could not check npm")
                continue

            if dep_version != dep_latest:
                print(f"    {dep_version} \u2192 {dep_latest}")
                if not yesno(f"    Update to {dep_latest}?"):
                    continue

                hash_pairs = []
                for dt_key, dt in dep_tarballs.items():
                    old_url = dt["url"]
                    old_hash = dt["hash"]
                    new_url = old_url.replace(dep_version, dep_latest)
                    print(
                        f"    \u21b3 Prefetching {dep_key}/{dt_key}...",
                        end=" ",
                        flush=True,
                    )
                    new_hash = prefetch_hash(new_url)
                    if new_hash is None:
                        print("\u2716")
                        continue
                    print("\u2713")
                    hash_pairs.append((old_hash, new_hash))

                if filepath not in updates_by_file:
                    updates_by_file[filepath] = {"main": [], "deps": []}
                updates_by_file[filepath]["deps"].append(
                    (dep_key, dep_version, dep_latest, hash_pairs)
                )
            else:
                print(f"    {dep_version} (\u2713 up to date)")

    print()
    print("=" * 50)
    if not updates_by_file:
        print("All tools up to date.")
        return

    print("Applying file updates...")
    for filepath, changes in updates_by_file.items():
        if update_nix_file(filepath, changes["main"], changes["deps"]):
            print(f"  \u2713 {filepath}")

    print("\nVerifying flake evaluation...")
    result = run(["nix", "eval", "path:./pkgs#lib.toolMeta", "--json"], cwd=REPO_ROOT)
    if result.returncode == 0:
        print("  \u2713 OK")
    else:
        print(f"  \u2716 FAILED: {result.stderr}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
