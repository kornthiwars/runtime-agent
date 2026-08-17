---
name: note
description: >-
  Durable project problem notes under workspace .cursor/notes/projects/<slug>/problems.
  Use when the user invokes /note, or wants to remember a problem+fix or list/find
  project knowledge. Do not use for multi-todo plans (/plan), chat transcript dumps,
  or daily auto prompts (hooks — separate). No secrets/PII.
disable-model-invocation: true
---

# /note

Durable **project problems** (and related knowledge) as markdown files.  
Path: `<workspace>/.cursor/notes/projects/<project>/problems/`.  
Not chat logs. Daily-all-prompts are written by **hooks** to `.cursor/notes/daily/` (not this skill).

## Commands

| Invoke | Do |
|--------|-----|
| `/note add` | Create one problem note from template |
| `/note list` | List recent notes for a project (no-edit; default: all statuses; open-only if user asks) |
| `/note find <q>` | Grep title/tags/body under that project’s `problems/` (no-edit) |
| `/note resolve <path-or-title>` | Set frontmatter `status: resolved` + `resolved: YYYY-MM-DD` on an existing note |
| `/note update <path-or-title>` | Patch Problem/Cause/Fix (or other sections) the user names — no secrets |

## Checklist

```
/note progress:
- [ ] Resolve project slug `[a-z0-9-]+` (ask once if unclear)
- [ ] kind=problem (default) · status · title
- [ ] Path under `.cursor/notes/projects/<project>/problems/`
- [ ] No secrets/PII in body
- [ ] REPORT with path
```

## Steps — add

1. Resolve `project` (accept `project=<slug>` or free text), `title` (accept `title=…`), optional `tags`, `status` (`open` default).
2. Ensure dirs exist: `.cursor/notes/projects/<project>/problems/`.
3. Write `YYYY-MM-DD-<title-slug>.md` from [note-problem template](../../templates/workspace/note-problem.md).
4. Fill Problem / Cause / Fix (and optional sections) from user; leave unknown sections as `-`.
5. REPORT: path + `READY`.

## Steps — list / find

1. Resolve `project`. **No edits.** `CHANGES: none (no-edit)`.
2. `list`: show newest ~10 files (title + status from frontmatter). Default includes all statuses; if user asks **open only**, skip `resolved`.
3. `find`: search `<q>` in that project’s `problems/` (filenames + content); show ≤10 hits.

## Steps — resolve / update

1. Resolve `project` + target note (path under `problems/`, or unique title match).
2. `resolve`: set `status: resolved` and `resolved: <today>` in frontmatter; do not invent a Fix if empty — leave `-` or ask once.
3. `update`: edit only sections the user named (Problem / Cause / Fix / …); keep no secrets/PII.
4. REPORT with path.

## Failure playbook

| Status | Do |
|--------|-----|
| Project unclear | Ask once |
| Would store secret/PII | `BLOCKED`; refuse |
| User wants multi-step build plan | Redirect `/plan` |
| User wants every chat prompt logged | Already handled by notes-daily hooks → `.cursor/notes/daily/` |

## Never

Write under `runtime-agent/` pack git · dump stacks/logs into notes · store secrets/URI · treat `/note` as `/plan` · auto-append every prompt here · invent Cause/Fix without evidence · edit notes on list/find

## Golden

In: `/note add` project=checkout-app title=“checkout total flaky”  
Out: `.cursor/notes/projects/checkout-app/problems/YYYY-MM-DD-checkout-total-flaky.md` · READY

How to use: [USAGE.md](USAGE.md).

## Output

Follow [templates/response/note.md](../../templates/response/note.md). Shared [report.md](../../templates/response/report.md).
