---
name: change-tasks
description: Generate tasks.md for a change plan from its proposal and design documents. Use when the user wants to create or regenerate the implementation checklist for a change. design.md is optional for trivial changes.
---

# Generate tasks.md

Reads `proposal.md` and `design.md` for a change and synthesises an executable `tasks.md`.

Tasks should only be created when implementation is imminent. Do not generate them speculatively — stale decomposition is worse than no decomposition.

## Steps

1. **Determine the slug.** Use the argument passed to `/change-tasks` if provided. Otherwise list available changes with `ls .changes/` and ask the user which one to target.

2. **Check prerequisites.** Read `.changes/[slug]/proposal.md`. If it is missing or nearly empty, warn the user that planning looks incomplete and ask whether to proceed anyway. Also read `.changes/[slug]/design.md` if it exists — it is optional for trivial changes, so its absence is not itself a warning.

3. **Check for an existing tasks.md.** If `.changes/[slug]/tasks.md` already exists, read it and ask the user whether to regenerate from scratch or extend/update the existing file.

4. **Analyse the documents.** Identify the concrete, implementable work implied by the proposal and design. Look for:
   - Schema or data model changes
   - New or modified interfaces
   - Integration points and their sequencing
   - Dependencies between components
   - Testing requirements

5. **Group into sections.** Organise tasks into cohesive sections that can be completed independently, ordered by natural dependency. Each section should represent a coherent unit of work that could be paused and resumed.

6. **Write tasks.md** using this structure:

```markdown
---
ready: false
---

# Tasks

## Resumption Notes

[Leave blank initially — this is filled in during implementation to record safe restart points and known blockers.]

## 1. [Section Name]

- [ ] Task
- [ ] Task

## 2. [Section Name]

- [ ] Task
- [ ] Task
```

   Keep tasks concrete and specific enough to be unambiguous. Avoid tasks that are too large to complete in a single sitting.

7. **Confirm with the user.** After writing the file, tell the user:
   - `ready` is set to `false` — change it to `true` when planning is complete and implementation is ready to begin.
   - The checklist is expected to evolve during implementation.
   - Run `/change-status [slug]` to update the TOML status when the status changes.

## Resumption Notes section

This section is for notes written *during* implementation, not during planning. Leave it blank when generating. It should be updated manually to record things like:
- Which tasks are currently blocked and why
- The safest point to resume after an interruption
- Temporary state that needs cleaning up
