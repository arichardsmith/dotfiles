# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "questionary>=2.1",
#     "rich>=13",
#     "typed-argument-parser>=1.10",
# ]
# ///

import subprocess
import sys
from pathlib import Path
from typing import Literal, NoReturn, cast

import questionary
from rich.console import Console
from tap import Tap

console = Console()

POINTER_FILE = Path(".nvim.lua")
CONFIG_DIR = Path(".nvim")
CONFIG_FILE = CONFIG_DIR / "init.lua"
SNIPPETS_DIR = CONFIG_DIR / "snippets"
EXCLUDE_ENTRIES = [f"{POINTER_FILE}", f"{CONFIG_DIR}/"]

POINTER_LUA = """\
-- Pointer to the real per-project config. Sourced automatically because `exrc` is enabled.
dofile(".nvim/init.lua")
"""


class Args(Tap):
    """Scaffold per-project Neovim config."""

    format: Literal["auto", "manual"] | None = None  # auto enables format-on-save
    track: bool = False  # track .nvim/ and .nvim.lua in git instead of adding them to .git/info/exclude


def panic(msg: str) -> NoReturn:
    console.print(f"[red]✗[/red] {msg}")
    sys.exit(1)


def config_lua(format_choice: Literal["auto", "manual"]) -> str:
    format_on_save = "format_on_save = { timeout_ms = 500 },"
    if format_choice == "manual":
        format_on_save = f"-- {format_on_save}"
    return (
        "-- Per-project Neovim config, loaded via the `.nvim.lua` pointer (`exrc`).\n"
        "\n"
        "-- Extends the machine-wide conform config: override a filetype's formatters\n"
        '-- (e.g. javascript = { "prettier" }) or set one to {} to disable it here.\n'
        '-- Add lsp_format = "fallback" to format_on_save to fall back to LSP formatting.\n'
        'require("conform").setup({\n'
        f"  {format_on_save}\n"
        "  formatters_by_ft = {},\n"
        "})\n"
        "\n"
        "-- Project snippets (VSCode format) live in .nvim/snippets/<filetype>.json.\n"
        "-- This file is sourced after blink.cmp's setup(), so extend its config table\n"
        "-- directly; sources are constructed lazily on first completion.\n"
        'local snippets = require("blink.cmp.config").sources.providers.snippets\n'
        'snippets.opts = vim.tbl_deep_extend("force", snippets.opts or {}, {\n'
        '  search_paths = { vim.fn.getcwd() .. "/.nvim/snippets" },\n'
        "})\n"
    )


def resolve_format(args: Args) -> Literal["auto", "manual"]:
    if args.format is not None:
        return args.format
    choice = questionary.select(
        "Format on save?",
        choices=["auto", "manual"],
    ).ask()
    if choice is None:
        panic("Cancelled.")
    return cast(Literal["auto", "manual"], choice)


def resolve_track(args: Args) -> bool:
    if args.track:
        return True
    answer = questionary.confirm("Track config in git?", default=False).ask()
    if answer is None:
        panic("Cancelled.")
    return cast(bool, answer)


def git_common_dir() -> Path | None:
    result = subprocess.run(
        ["git", "rev-parse", "--git-common-dir"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return None
    return Path(result.stdout.strip()).resolve()


def update_exclude() -> None:
    git_dir = git_common_dir()
    if git_dir is None:
        console.print(
            "[yellow]not a git repository — skipped .git/info/exclude handling[/yellow]"
        )
        return

    exclude = git_dir / "info" / "exclude"
    content = exclude.read_text() if exclude.exists() else ""
    lines = content.splitlines()

    missing = [entry for entry in EXCLUDE_ENTRIES if entry not in lines]
    if missing:
        exclude.parent.mkdir(parents=True, exist_ok=True)
        if content and not content.endswith("\n"):
            content += "\n"
        content += "".join(f"{entry}\n" for entry in missing)
        exclude.write_text(content)


def main(args: Args) -> None:
    console.print("[bold]nvim project init[/bold]\n")

    # None means the config file already exists, so the answer would be unused.
    format_choice: Literal["auto", "manual"] | None = None
    if not CONFIG_FILE.exists():
        format_choice = resolve_format(args)
    track = resolve_track(args)

    created: list[str] = []
    skipped: list[str] = []

    if SNIPPETS_DIR.exists():
        skipped.append(f"{SNIPPETS_DIR}/")
    else:
        SNIPPETS_DIR.mkdir(parents=True)
        created.append(f"{SNIPPETS_DIR}/")

    if format_choice is None:
        skipped.append(str(CONFIG_FILE))
    else:
        CONFIG_FILE.write_text(config_lua(format_choice))
        created.append(str(CONFIG_FILE))

    if POINTER_FILE.exists():
        skipped.append(str(POINTER_FILE))
    else:
        POINTER_FILE.write_text(POINTER_LUA)
        created.append(str(POINTER_FILE))

    if not track:
        update_exclude()

    for path in created:
        console.print(f"[green]✓[/green] created {path}")
    for path in skipped:
        console.print(f"[yellow]•[/yellow] kept existing {path}")

    if not track:
        console.print("\n.nvim.lua and .nvim/ are ignored in .git/exclude/info")


if __name__ == "__main__":
    main(Args().parse_args())
