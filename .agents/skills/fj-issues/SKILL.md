---
name: fj-issues
description: Use fj to manage issues in this repository's Forgejo tracker. Apply this skill when creating, searching, viewing, editing, commenting on, assigning, or closing issues; prefer fj over GitHub tooling.
---

# Forgejo Issues With `fj`

This repository uses Forgejo as its canonical upstream and issue tracker. The
local `origin` remote points to Forgejo. Use `fj` with `-R origin` for issue
operations rather than `gh` or another GitHub client.

## Repository Selection

Always make the remote explicit when operating on issues:

```bash
fj issue search -R origin "search terms"
fj issue view -R origin 2
```

Useful diagnostics:

```bash
fj auth list
fj repo view -R origin
fj issue templates -R origin
```

If the remote cannot be resolved, specify the Forgejo host with `-H` and
authenticate with `fj auth login` before retrying.

## Issue Workflow

1. Search for an existing issue before creating a new one:

   ```bash
   fj issue search -R origin "keyword"
   fj issue search -R origin --state all "keyword"
   ```

2. Read the complete issue before extending or duplicating it:

   ```bash
   fj issue view -R origin ISSUE
   fj issue view -R origin ISSUE comments
   ```

3. Create a focused issue with a specific title and actionable body:

   ```bash
   fj issue create -R origin --no-template \
     "Short, specific issue title" \
     --body $'## Context\n\nDescribe the current behaviour.\n\n## Acceptance criteria\n\n- [ ] Describe the expected result.'
   ```

   Use `--body-file PATH` for longer issue bodies. Check the repository's
   templates first when templates are enabled; use `--no-template` only when a
   blank issue is appropriate.

4. Verify newly created or changed issues:

   ```bash
   fj issue view -R origin ISSUE
   ```

## Common Operations

```bash
# Edit an issue body or title.
fj issue edit -R origin ISSUE body "Updated body"
fj issue edit -R origin ISSUE title "Updated title"

# Add or inspect discussion.
fj issue comment -R origin ISSUE "A useful progress update"
fj issue view -R origin ISSUE comments

# Assign or unassign users.
fj issue assign -R origin ISSUE USERNAME
fj issue unassign -R origin ISSUE USERNAME

# Close an issue, optionally leaving a final comment.
fj issue close -R origin ISSUE --with-msg "Implemented in ..."

# Open the issue in a browser when visual review is useful.
fj issue browse -R origin ISSUE
```

Use issue IDs, not titles, for `view`, `edit`, `comment`, `assign`,
`unassign`, `close`, and `browse`.

## Issue Quality

- Search first and avoid duplicate issues.
- Use a title that names the requested outcome, not just the symptom.
- Record current behaviour, desired behaviour, scope boundaries, and
  acceptance criteria.
- Keep implementation details out unless they constrain the solution.
- Verify the final issue text after creating or editing it.
