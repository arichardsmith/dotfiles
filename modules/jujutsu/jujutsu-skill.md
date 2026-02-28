---
name: jujutsu
description: Jujutsu (jj) version control system commands and concepts. Use when working with version control, commits, branches, or any repository operations.
---

# Jujutsu Version Control

This machine uses **Jujutsu (jj)** instead of git. Your knowledge may be outdated - if a command isn't in this skill, search the current docs at https://docs.jj-vcs.dev/latest/ or ask the user for help output.

## Key Differences from Git

### Working Copy is a Commit
The working copy is an actual commit with its own ID. It gets automatically amended by the next `jj` command - no need for `git add` or explicit staging.

### Change IDs vs Commit IDs
- **Change ID**: Stable across rewrites (like Gerrit)
- **Commit ID**: Hash that changes with amendments (like Git)

### No Explicit Staging
File changes (new files, modifications, deletions) are automatically tracked. No `git add` needed.

### Non-blocking Conflicts
Rebases complete successfully even with conflicts. Conflicted commits can be resolved afterward.

### Bookmarks Instead of Branches
Uses "bookmarks" instead of Git branches. Commits reference exact parents, not branch pointers.

## Common Commands

### Basic Operations
- `jj status` or `jj st` - Show working copy state
- `jj diff` - View changes in working copy
- `jj log` - Display commit history
- `jj describe` - Add/edit commit message for current change
- `jj new` - Create new commit on top of working copy
- `jj squash` - Move changes from current commit to parent
- `jj edit <commit>` - Resume editing a previous commit
- `jj abandon <commit>` - Hide commit and rebase descendants

### History & Undo
- `jj op log` - View operation history
- `jj undo` - Undo last operation (doesn't lose history)
- `jj log --at-op=<hash>` - View repo state at specific operation

### Advanced
- `jj split` - Split a commit's changes into multiple commits
- `jj diffedit -r <commit>` - Edit specific commit without checking it out
- `jj rebase -s <commit> -d <destination>` - Rebase commits

## Revsets (Query Language)

- `@` - Working copy commit
- `root()` - Root commit
- `bookmarks()` - All bookmarked commits
- `foo-` - Parents of commit foo
- `foo+` - Children of commit foo
- `::foo` - Ancestors of foo
- `foo::` - Descendants of foo
- `main@origin` - Remote bookmark

## Important Notes

- Default `jj log` omits some commits; use `jj log -r ::` to see all
- When you get stuck or unsure, ask the user or search docs - jj is evolving rapidly
- Conflicts are stored in commits and can be resolved later
- Every action is logged in operations - you can always undo
