---
name: ship
description: >-
  Inspect repo state, propose commit/push, wait for confirm, then ship once.
  Use when the user invokes /ship, or asks to commit, push, or publish after work.
disable-model-invocation: true
---

# /ship

Slash alone ≠ consent. Inspect → propose → confirm → commit/push **once** → verify remote.

**Same-message confirm:** `/ship ยืนยัน` (or `/ship` + `confirm`/`yes` in the same
user message) is valid **after** steps 1–3 complete in that turn — then proceed
to step 5 in the same turn. `/ship` with no confirm word → stop at
`AWAITING_CONFIRM`.

## Steps

1. Parallel: `git status`, `git diff`, `git diff --staged`, `git log -5 --oneline`, branch tracking.
2. DIFF SUMMARY + SECRETS SCAN (flag `.env`, keys, tokens). Abort ship if secrets flagged until user overrides explicitly.
3. Propose COMMIT MSG. List IRREVERSIBLES (commit, push, force-push, …).
4. If no confirm yet: `AWAITING_CONFIRM` — do not commit/push.
5. After confirm: commit (and push if requested or clearly implied). Follow **git hygiene** in `agent-ops`.
6. Never force-push `main`/`master` unless the user explicitly confirms force (e.g. `ยืนยัน force push`).
7. POST-VERIFY: remote HEAD / upstream. HIGH risk: one-line ROLLBACK note.

How to use (examples): [USAGE.md](USAGE.md).

## Output

Follow [templates/response/ship.md](../../templates/response/ship.md).
