---
name: ship
description: >-
  Inspect repo state, propose commit/push, wait for confirm, then ship once.
  Use when the user invokes /ship, or asks to commit, push, or publish after work.
disable-model-invocation: true
---

# /ship

Slash alone ≠ consent. Inspect → propose → `AWAITING_CONFIRM` → after `ยืนยัน` commit/push once → verify remote.

## Steps

1. Parallel: `git status`, `git diff`, `git diff --staged`, `git log -5 --oneline`, branch tracking.
2. DIFF SUMMARY + SECRETS SCAN (flag `.env`, keys, tokens).
3. Propose COMMIT MSG. List IRREVERSIBLES (commit, push, …).
4. Stop for confirm. Do not commit/push yet.
5. After confirm: commit (and push if requested). Never force-push main/master unless explicitly asked.
6. POST-VERIFY: remote HEAD / upstream. HIGH risk: one-line ROLLBACK note.

## Output

Follow [templates/response/ship.md](../../templates/response/ship.md).
