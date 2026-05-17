---
name: jujutsu
description: Jujutsu (jj) version control system basics and repository navigation. Use when working with version control, commits, bookmarks, or local repository operations. The agent should avoid history-rewriting operations like rebasing, splitting, squashing, or merging unless explicitly directed by a human.
---

# Jujutsu (jj)

This machine uses **Jujutsu (`jj`)** instead of Git. `jj` is Git-compatible but has a different model: there is no staging area, the working copy is itself a commit, and changes are tracked automatically.

> ⚠️ The agent’s knowledge of `jj` may be outdated. If a command is missing, behaves differently than expected, or seems uncertain, check the current docs or ask the user for command help output.

https://docs.jj-vcs.dev/latest/

## Important Constraints

> ⚠️ Never use `git` for mutations inside a `jj` repository.  
> Allowed Git commands: `git log`, `git diff`, `git show`, `git blame`, `git grep`.

The agent does **not** need to perform:
- rebasing
- merging
- splitting commits
- squashing commits
- pushing/pulling

Those should generally be left to a human unless explicitly requested.

The agent *should* understand:
- working copies
- commits and change IDs
- bookmarks
- viewing history
- editing descriptions
- moving around history safely

Prefix any commits / descriptions with `WIP(check): ` to flag they need human review.

## Core Concepts

### Working Copy is a Commit

The working copy is an actual mutable commit. File changes are automatically tracked.

There is:
* no `git add`
* no staging area
* no explicit commit-amend cycle

The next `jj` command updates the working-copy commit automatically.

### Change IDs vs Commit IDs

Each revision has:
* a **change ID** — stable across rewrites
* a **commit ID** — changes whenever the commit changes

Change IDs are usually what humans refer to.

### Bookmarks Instead of Branches

`jj` uses **bookmarks** rather than Git branches.

Bookmarks are movable references to commits, similar to lightweight branch pointers.

## Common Commands

### Repository State

```bash
jj status
jj st
```

Show working-copy state.

```bash
jj diff
```

Show current changes.

```bash
jj log
```

Show history.

By default, `jj log` hides some revisions. To see everything:

```bash
jj log -r ::
```

### Working With Changes

```bash
jj new
```

Create a new working-copy commit on top of the current one.

```bash
jj describe
jj desc
```

Edit the current change description.

```bash
jj desc -m "Add login"
```

Set description directly.

```bash
jj edit <change-id>
```

Switch to editing another change.

### Navigation

```bash
jj edit @-
```

Move to the parent change.

```bash
jj next --edit
```

Move to a child change.

```bash
jj new --before @
```

Insert a new change before the current one.

### Bookmarks

```bash
jj bookmark create main -r @
```

Create bookmark at current revision.

```bash
jj bookmark list
```

List bookmarks.

```bash
jj bookmark track main@origin
```

Track remote bookmark.

## Revsets

`jj` uses a query language called **revsets**.

Common revsets:

```text
@           current working-copy commit
root()      repository root
foo-        parent of foo
foo+        child of foo
::foo       ancestors of foo
foo::       descendants of foo
bookmarks() all bookmarked commits
main@origin remote bookmark
```

Important differences from Git-style syntax:

```text
❌ @~1
✅ @-
```

```text
❌ a,b,c
✅ a | b | c
```

## History & Recovery

Every operation is recorded and recoverable.

```bash
jj op log
```

View operation history.

```bash
jj undo
```

Undo the last `jj` operation safely.

```bash
jj log --at-op=<operation-id>
```

Inspect repository state at a previous operation.

## Conflict Model

Conflicts are non-blocking in `jj`.

Operations like rebases can complete even if conflicts exist. Conflicted states are stored in commits and resolved later.

Typical resolution flow:

```bash
jj resolve
```

## Useful Patterns

Get Git commit hash from current revision:

```bash
jj log -T 'commit_id.short()\n' -r @
```

Or:

```bash
git rev-parse @
```

View a concise history graph:

```bash
jj log
```

View full repository graph:

```bash
jj log -r ::
```

## Common Pitfalls

- Do not expect a staging area.
- Do not use Git mutation commands.
- Do not assume commit hashes are stable.
- Prefer change IDs when referring to revisions.
- `jj log` is the primary history/navigation command.
