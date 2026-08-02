---
name: note
description: >-
  Durable cross-session memory by project: write, list, or find notes.
  Use when the user invokes /note, /note list, /note find, or asks to remember
  something. Memory is not runtime state — no logs, stacks, or secrets.
disable-model-invocation: true
---

# /note

**Memory ≠ Runtime State.** Short durable recall only.  
Do **not** store task graphs or multi-step build plans here — use `/plan` (`.cursor/plans/`).

## Modes

Parse the user message:

| Invocation | Mode |
|------------|------|
| `/note list` · `/note list <project>` | **list** |
| `/note find <query>` | **find** |
| `/note` · `/note <project> …` · remember / จด … | **write** (default) |
| chat-only / อย่าเซฟ | **write** but skip file |

Do not invent other modes.

## Storage

- `NOTES_ROOT` = `<workspace-root>/notes` (create if missing).
- Never write under `USERPROFILE` or outside the current workspace unless the user gives an explicit path.
- File path: `notes/<PROJECT>/YYYY-MM-DD-<slug>.md`
- In the Skills hub workspace: many projects share one `notes/`; keep folders separate.
- In a single-app repo: `PROJECT` defaults to that repo folder name (still use `notes/<PROJECT>/` for one layout).

## Project

`PROJECT` slug: lowercase `[a-z0-9-]+`.

1. User names it (`/note <project>`, `project:<name>`, “for project X”, or list/find arg).
2. Else infer from git root / top app folder being edited.
3. Else if about this pack / install / skills → `agent-skills`.
4. Else ask once; do not write until known.

Never mix unrelated projects in one folder.

## Expiry

- Frontmatter `expires: YYYY-MM-DD` = last valid day; empty = no expiry.
- **Expired** = today > `expires`.
- **list / find:** show expired with `[expired]`; do not treat as active guidance.
- **write:** do not revive an expired file in place — add a new note if still needed.

## write

1. Infer content from the message and/or this thread. Bare `/note` → key durable decision/constraint from the thread.
2. KIND: `decision` | `constraint` | `exception` | `gotcha`.
3. TITLE + BODY (memorable). No secrets, tokens, real PII, logs, or stacks.
4. **Size cap:** one topic per file; TITLE one line; Detail about **3–7 bullets**; keep the whole note roughly ≤½ screen. If longer, split or cut — this is memory, not a transcript.
5. Set EXPIRES for temporary exceptions; else empty.
6. Write with [templates/memory/note-template.md](../../templates/memory/note-template.md):
   - Default path under `NOTES_ROOT` as above; user path wins when given.
   - Frontmatter must include `project: <PROJECT>`.
7. REPORT + write block. `PATH` = file written (or `—` if chat-only).

## list

1. Resolve optional `PROJECT`. If omitted, list project folders under `notes/` (name + file count). If given, list that folder’s `*.md`.
2. Sort by filename descending (newest date first). Cap at 20; say if truncated.
3. Per file: date, slug/title, kind (from frontmatter if present), `[expired]` when applicable.
4. No file writes. REPORT + list block.

## find

1. Require a non-empty `<query>` (substring, case-insensitive). Else ask.
2. Search `notes/**/*.md` (or `notes/<PROJECT>/**` if project scoped) in frontmatter + body.
3. Return up to 10 hits: path, title, one-line match context, `[expired]` if applicable.
4. No file writes. REPORT + find block.

How to use (examples): [USAGE.md](USAGE.md).

## Output

Follow [templates/response/note.md](../../templates/response/note.md).
