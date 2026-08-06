---
name: note
description: >-
  Durable cross-session memory by project in MongoDB (model-rust notes
  collection): write, list, or find short notes (decision/constraint/exception/gotcha).
  Use when the user invokes /note, /note list, /note find, or asks to remember
  something. Do not store task graphs (/plan), runtime logs/stacks/secrets, or
  use this to implement code. Not file-based — never write notes/*.md.
disable-model-invocation: true
---

# /note

**Memory ≠ Runtime State.** Short durable recall only — stored in Mongo `notes`.  
Task graphs / multi-step builds → `/plan` (`.cursor/plans/`).  
Auto chat/ops history → `model-rust-auto` hooks (`turns` source=`chat`) — do not duplicate here.  
CLI + fields: [reference.md](reference.md).

## Modes

| Invocation | Mode |
|------------|------|
| `/note list` · `/note list <project>` | **list** |
| `/note find <query>` | **find** |
| `/note` · `/note <project> …` · remember / จด … | **write** (default) |
| chat-only / อย่าเซฟ | **write** but skip DB |

## write (hot path)

1. Infer durable content from message/thread. Bare `/note` → key decision/constraint from thread.
2. KIND: `decision` | `constraint` | `exception` | `gotcha`.
3. TITLE + BODY. No secrets, tokens, real PII, logs, or stacks.
4. **Size:** one topic; TITLE one line; Detail **3–7 bullets**; ≤½ screen. Split if longer.
5. EXPIRES for temporary exceptions; else omit.
6. Persist with `model-rust note add` (JSON stub or flags). Never create `notes/*.md`.
7. REPORT. `ID` = Mongo ObjectId or `—` if chat-only.

Resolve `PROJECT` per [reference.md](reference.md).

## list / find

- **list:** `model-rust note list [--project …] --limit 20`; mark `[expired]`.
- **find:** `model-rust note find -q …`; require non-empty query; up to 10 hits. No writes.

## Failure playbook

| Status | Do |
|--------|-----|
| PROJECT unknown | Ask once; do not write |
| User pastes secrets/logs | Refuse body; rewrite as constraint without secrets or abort |
| find with empty query | Ask for query; no scan |
| Mongo / binary missing | `BLOCKED`; point to `model-rust` `.env` + `cargo build` |

## Never

- Store plans, transcripts, logs, stacks, secrets  
- Write markdown under workspace `notes/`  
- Revive an expired note in place — insert a new document  
- Mix unrelated projects in one document  

## Golden

In: `/note agent-skills junctions target parent Skills workspace`.  
Out: `model-rust note add` → `id` · kind `decision` · short bullets · no files.

How to use: [USAGE.md](USAGE.md).

## Output

Follow [templates/response/note.md](../../templates/response/note.md).
