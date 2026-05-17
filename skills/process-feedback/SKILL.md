---
name: process-feedback
description: Find and process FEEDBACK comments left in source files. Use this skill whenever the user mentions feedback comments, asks to process feedback, review feedback, check feedback, or says anything about FEEDBACK tags in their code.
---

# FEEDBACK Comments

## What they are

The user leaves inline feedback comments in source files using the format:

```
FEEDBACK(tag) feedback text
```

These are written inside the file's native comment syntax. Examples:

- `// FEEDBACK(api) this endpoint needs pagination`
- `# FEEDBACK(auth) handle token refresh here`
- `<!-- FEEDBACK(redesign) component should use the new layout -->`
- `/* FEEDBACK(perf) this loop is O(n²) */`

Feedback may span multiple lines. The FEEDBACK marker is only on the first line; subsequent comment lines are a continuation of the same feedback. For example:

```
// FEEDBACK(api) this endpoint needs pagination
// it currently returns all results which will be a problem
// once we have more than a few hundred records
```

```
# FEEDBACK(auth) handle token refresh here
# the current implementation silently fails when the token
# expires, which causes confusing 401 errors downstream
```

The tag is a project or context label (e.g. `api`, `auth`, `redesign`, `perf`). It is used to filter feedback by context so that unrelated feedback is ignored.

## How to find them

Use ripgrep to locate FEEDBACK comments. Only use it to get file names and line numbers — read the files yourself to extract the full comment.

All tags:

```
rg -n "FEEDBACK\(\w+\)" --no-heading
```

Filtered by tag:

```
rg -n "FEEDBACK\(api\)" --no-heading
```

## How to process them

When the user asks you to process feedback:

1. Ask which tag to filter by, unless the user already specified one. If the user says "all", omit the tag filter.
2. Run the appropriate `rg` command to find all matching FEEDBACK comments. Note the file path and line number for each match.
3. For each match, open the file and read from the matched line onward to extract the full feedback comment, including any continuation lines. A continuation line is any immediately following line that is a comment in the same style but does NOT contain a new FEEDBACK marker.
4. Read the surrounding code for context, then act on the feedback.
5. After you have addressed a comment, remove all lines belonging to that feedback comment (the FEEDBACK line and its continuations). Do this as you go, not in a batch at the end.
6. If a FEEDBACK comment is unclear, ask the user for clarification before acting on it.

## Important

- Do not modify or remove FEEDBACK comments that don't match the current tag filter.
- Always read the surrounding code context before acting on a comment — the feedback may reference nearby code.
- Treat the feedback text as an instruction from the user.
