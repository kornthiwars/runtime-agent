---
name: fix
description: >-
  Full-mode bug investigation before patching. Use when the user invokes /fix,
  or for unknown-cause bugs, test failures, flaky behavior, or wrong data where
  root cause is not yet proven.
disable-model-invocation: true
---

# /fix — Full

Iron law: no patch before repro → fail path → falsify → evidence.

## Steps

1. Reproduce (or document impossibility). Status `BLOCKED` if no repro signal.
2. Locate fail path (boundary, log, working-vs-broken diff).
3. Rank 3–5 hypotheses; disprove one at a time. Keep attempt ledger in chat (`ATTEMPT: #n`).
4. State RISK (LOW/MED/HIGH). HIGH → stop for approval.
5. Minimal patch only after root cause ruled in. Note ROLLBACK one-liner.
6. Verify: IDENTIFY → RUN → READ.
7. Close with REPORT + fix block. Next attempt must differ if still broken.

## Stop

No repro / unclear multi-cause / low confidence → diagnose-only, no Lite-style guess patch.

## Output

Follow [templates/response/fix.md](../../templates/response/fix.md). Keep mid-turn short.
