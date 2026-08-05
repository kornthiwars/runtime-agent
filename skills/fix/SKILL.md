---
name: fix
description: >-
  Full-mode bug investigation before any patch: repro, fail path, falsify,
  evidence, then minimal fix. Use when the user invokes /fix, or for
  unknown-cause bugs, test failures, flaky behavior, or wrong data. Do not use
  for clear new builds (/make), UI/multi-step demos (/plan), or commit (/ship).
disable-model-invocation: true
---

# /fix — Full

Iron law: no patch before repro → fail path → falsify → evidence.

**vs `/make`:** unknown cause / wrong or flaky behavior → **this skill**.  
Known new capability → `/make`. Mid-make ambiguity → switch here (no Lite-guess).

**vs `/plan`:** do **not** use `/fix` for UI demos or multi-step screens — `/plan` then `/plan run`.

Notes recall, RISK, budget, verify: `agent-ops` (do not restate).

## Checklist (copy progress)

```
/fix progress:
- [ ] Notes recall (≤3)
- [ ] Repro (or impossibility → BLOCKED)
- [ ] Fail path located
- [ ] Hypotheses 3–5; disprove one-by-one (ATTEMPT: #n)
- [ ] RISK stated (HIGH → stop)
- [ ] Minimal patch + ROLLBACK one-liner
- [ ] VERIFY: IDENTIFY → RUN → READ
- [ ] REPORT + fix block
```

## BLOCKED — ask once

If stuck, ask **one** clarifying question covering the missing signal, e.g. exact error text, repro steps, last good commit, or environment — then wait.

## Never

- Patch before repro/evidence  
- Repeat the same attempt  
- Build greenfield UI under `/fix`  
- Quietly exceed budget without user OK

## Golden

In: `/fix` “checkout total wrong sometimes”.  
Out: repro → fail path → ruled-in cause → minimal patch → VERIFY READ pass · not a drive-by refactor.

How to use: [USAGE.md](USAGE.md).

## Output

Follow [templates/response/fix.md](../../templates/response/fix.md). Keep mid-turn short.
