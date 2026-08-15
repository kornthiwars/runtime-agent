---
name: fix
description: >-
  Full-mode bug investigation before any patch: repro, fail path, falsify,
  evidence, then minimal fix. Use when the user invokes /fix, or for
  unknown-cause bugs, test failures, flaky behavior, or wrong data. Do not use
  for clear new builds (/make), UI/multi-step demos (/plan), gated product
  features (/feature), pack edits (/upgrades), or commit (/ship).
disable-model-invocation: true
---

# /fix — Full

Iron law: no patch before repro → fail path → falsify → evidence.

**vs `/make`:** unknown cause → **this**. Known build → `/make`. Mid-make ambiguity → here.  
**vs `/plan`:** UI demos / multi-step screens → `/plan`, not `/fix`.

Notes/RISK/budget: `agent-ops`. Enterprise surfaces: `enterprise-safety` (same stop as `/make`). Verify pick: [verify-matrix](../../templates/ops/verify-matrix.md).

## Checklist

```
/fix progress:
- [ ] Repro (or impossibility → BLOCKED)
- [ ] Fail path located via locate-before-read (search/symbol first; no default full-file dump)
- [ ] Hypotheses 3–5; disprove (ATTEMPT: #n)
- [ ] RISK LOW|MED|HIGH (per `agent-ops` table — do not under-label)
- [ ] If enterprise surface: STOP — BLAST_RADIUS + ROLLBACK + AWAITING_CONFIRM
      (no schema/auth/payments/infra/data/prod writes until ยืนยัน; migrate run = second confirm + env by name)
- [ ] Write budget ≤5 files / ≤120 lines or override + `ยืนยัน`/`confirm`/`yes` (bare `ok` ≠ consent)
- [ ] Minimal patch + ROLLBACK one-liner
- [ ] VERIFY per matrix: IDENTIFY → RUN → READ
- [ ] REPORT
```

Fail path: Grep/path/symbol → open hits only. Very long files (~1–2k+ lines): offset/symbol/range reads (`agent-ops` read budget).

## Failure playbook

| Status | Do |
|--------|-----|
| No repro | `BLOCKED`; ask **one** question (error text / steps / env / last good) |
| All hypotheses falsified | New ledger line; do not repeat same attempt; ask for new signal once |
| Enterprise without confirm | `AWAITING_CONFIRM`; do not write or run (before writing schema/auth/payments/infra/data/prod files) |
| Verify command missing | `BLOCKED` on verify; ask how they usually test this area |

## Never

Patch before evidence · repeat identical attempt · dump whole monolith to find fail path · greenfield UI under `/fix` · compress for line-count at expense of explicit intent (`explicit-intent`) · quiet write-budget overrun · enterprise write/run without AWAITING_CONFIRM + BLAST_RADIUS+ROLLBACK

## Golden

In: `/fix` “checkout total wrong sometimes”  
Out: repro → cause ruled in → minimal patch → VERIFY READ pass

In: `/fix` auth bypass / migrate breakage on shared DB  
Out: `AWAITING_CONFIRM` + BLAST_RADIUS + ROLLBACK · no files written yet · wait `ยืนยัน` before writing

How to use: [USAGE.md](USAGE.md).

## Output

Follow [templates/response/fix.md](../../templates/response/fix.md). Shared [report.md](../../templates/response/report.md). Keep mid-turn short.
