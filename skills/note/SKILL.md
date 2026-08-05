---
name: note
description: >-
  Durable cross-session memory by project: write, list, or find short notes
  (decision/constraint/exception/gotcha). Use when the user invokes /note,
  /note list, /note find, or asks to remember something. Do not store task
  graphs (/plan), runtime logs/stacks/secrets, or use this to implement code.
disable-model-invocation: true
---

# /note

**Memory ≠ Runtime State.** Short durable recall only.  
Task graphs / multi-step builds → `/plan` (`.cursor/plans/`).  
Storage, expiry, path rules: [reference.md](reference.md).

## Modes

| Invocation | Mode |
|------------|------|
| `/note list` · `/note list <project>` | **list** |
| `/note find <query>` | **find** |
| `/note` · `/note <project> …` · remember / จด … | **write** (default) |
| chat-only / อย่าเซฟ | **write** but skip file |

## write (hot path)

1. Infer durable content from message/thread. Bare `/note` → key decision/constraint from thread.
2. KIND: `decision` | `constraint` | `exception` | `gotcha`.
3. TITLE + BODY. No secrets, tokens, real PII, logs, or stacks.
4. **Size:** one topic; TITLE one line; Detail **3–7 bullets**; ≤½ screen. Split if longer.
5. EXPIRES for temporary exceptions; else empty.
6. Write via [note-template](../../templates/memory/note-template.md); frontmatter `project: <PROJECT>`.
7. REPORT. `PATH` = file or `—` if chat-only.

Resolve `PROJECT` per [reference.md](reference.md).

## list / find

- **list:** folders or `*.md` (newest first, cap 20); mark `[expired]`.
- **find:** require non-empty query; up to 10 hits with context. No writes.

## Never

- Store plans, transcripts, logs, stacks, secrets  
- Revive an expired note in place — write a new file  
- Mix unrelated projects in one folder

## Golden

In: `/note agent-skills junctions target parent Skills workspace`.  
Out: `notes/agent-skills/YYYY-MM-DD-junctions-parent.md` · kind `decision` · short bullets.

How to use: [USAGE.md](USAGE.md).

## Output

Follow [templates/response/note.md](../../templates/response/note.md).
