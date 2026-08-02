---
name: fix
description: >-
  Full-mode bug investigation before patching. Use when the user invokes /fix,
  or for unknown-cause bugs, test failures, flaky behavior, or wrong data where
  root cause is not yet proven. Prefer /fix over /make whenever cause is unclear.
disable-model-invocation: true
---

# /fix — Full

Iron law: no patch before repro → fail path → falsify → evidence.

**vs `/make`:** unknown cause, wrong/flaky behavior, or “it broke” → **this skill**.
Known new capability with clear outcome → `/make`. If mid-`/make` cause becomes
unclear → switch to this Full diagnose posture (do not Lite-guess).

## Steps

1. **Notes recall** (see `agent-ops`): read up to 3 newest non-expired notes for PROJECT.
2. Reproduce (or document impossibility). Status `BLOCKED` if no repro signal.
3. Locate fail path (boundary, log, working-vs-broken diff).
4. Rank 3–5 hypotheses; disprove one at a time. Keep attempt ledger in chat (`ATTEMPT: #n`).
5. State RISK (LOW/MED/HIGH). HIGH → stop for approval.
6. Minimal patch only after root cause ruled in. Note ROLLBACK one-liner.
7. Verify: IDENTIFY → RUN → READ.
8. Close with REPORT + fix block. Next attempt must differ if still broken.

## Stop

No repro / unclear multi-cause / low confidence → diagnose-only, no Lite-style guess patch.

How to use (examples): [USAGE.md](USAGE.md).

## Output

Follow [templates/response/fix.md](../../templates/response/fix.md). Keep mid-turn short.
