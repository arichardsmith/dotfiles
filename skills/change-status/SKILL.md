---
name: change-status
description: Update the status field in a change's TOML metadata. Use when the user wants to advance or correct the status of a change plan.
---

# Update Change Status

Reads a change's current state and updates the `status` field in its TOML file.

Valid statuses: `planning` → `implementing` → `finished` → `merged`

## Steps

1. **Determine the slug.** Use the argument passed to `/change-status` if provided. Otherwise list changes with `ls .changes/` and ask the user which one to update.

2. **Read the current state.** Read:
   - `.changes/[slug]/[slug].toml` — current status
   - `.changes/[slug]/tasks.md` if it exists — front matter and checklist state

3. **Infer the appropriate status** using these signals:

   | Signal | Suggested status |
   |--------|-----------------|
   | No `tasks.md`, or `ready: false` in tasks.md | `planning` |
   | `tasks.md` exists with `ready: true`, tasks not all checked | `implementing` |
   | All tasks checked off in `tasks.md` | `finished` |

   These are hints, not rules. The user decides the actual status.

4. **Present the recommendation.** Show the current status, the inferred status, and your reasoning. Ask the user to confirm or choose a different status.

5. **Update the TOML.** Write the new status value to the `status` field in `.changes/[slug]/[slug].toml`. Change only the `status` line; leave all other content intact.

6. **Confirm.** Report the old and new status values.

## Status meanings

- `planning` — proposal and/or design are still being written
- `implementing` — active development work is under way
- `finished` — implementation is complete, pending merge/release
- `merged` — the change has landed on the main branch
