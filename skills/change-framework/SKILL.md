---
name: change-framework
description: Reference for the Dot Changes framework. Use whenever working with files in a .changes/ directory, or when the user asks about the framework — what belongs in which document, TOML fields, status values, or overall structure.
user-invocable: false
---

# Dot Changes Framework

All planning documents for a change live under `.changes/[slug]/` in the repo root.

## Directory Layout

```
.changes/
    [slug]/
        [slug].toml
        proposal.md
        design.md       ← optional; needed for non-trivial changes
        tasks.md        ← only created shortly before implementation begins
        changeset.md    ← optional
```

## `[slug].toml`

```toml
name = "[slug]"
description = "A brief description of the change"
status = "planning" | "implementing" | "finished" | "merged"
```

## Document Role Boundaries

| Document | One-line rule | Must NOT contain |
|----------|--------------|-----------------|
| `proposal.md` | *Why* the change exists and *what* system behaviour is changing | Implementation detail, architectural decisions |
| `design.md` | *How* the system architecture will change | Behavioural specification, task lists |
| `tasks.md` | Executable implementation checklist | Design rationale, architectural decisions |

## Status Lifecycle

| Status | Meaning |
|--------|---------|
| `planning` | Proposal and/or design are still being written |
| `implementing` | Active development work is under way |
| `finished` | Implementation complete, pending merge/release |
| `merged` | Change has landed on the main branch |

Progression: `planning` → `implementing` → `finished` → `merged`

Status inference hints (not rules — user decides):
- No `tasks.md` or `ready: false` → `planning`
- `tasks.md` with `ready: true`, tasks incomplete → `implementing`
- All tasks checked off → `finished`
