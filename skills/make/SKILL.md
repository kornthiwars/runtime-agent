---
name: make
description: >-
  Implement a clear capability with Lite depth by default (minimal patch +
  verify). Use when the user invokes /make with a capability-id, or asks to
  build a single clear capability with known outcome. Do not use for
  unknown-cause bugs (/fix), multi-todo UI graphs (/plan), multi-slice or
  review-before-ship product delivery (/feature), or commit (/ship). Use
  --full or auto-full for schema, auth, shared modules, secrets, prod paths.
disable-model-invocation: true
---

# /make \<capability-id\>

Default **Lite**. `--full` or auto-full: schema, auth, SSoT, secrets/env, prod-facing.

**vs `/fix`:** clear build → **this**. Unknown cause → `/fix`.  
**vs `/feature`:** one capability / one patch shape → **this**. ≥2 slices or must `/review` before `/ship` → `/feature`.  
**Migration:** one-capability schema/migration → **this** (`--full` / auto-full + `enterprise-safety`). Multi-slice migrate or review-before-ship → `/feature`.  
May run from `/plan run` or `/feature` slice. Ops: `agent-ops` · enterprise: `enterprise-safety` · code clarity: `explicit-intent`.  
Verify: [verify-matrix](../../templates/ops/verify-matrix.md).

## Checklist

```
/make progress:
- [ ] capability-id + scope + non-goals
- [ ] Locate-before-read (`agent-ops` read budget) — open only purpose-matched files
- [ ] DEPTH Lite|Full (reason)
- [ ] RISK LOW|MED|HIGH
- [ ] If enterprise surface: STOP — BLAST_RADIUS + ROLLBACK + AWAITING_CONFIRM
      (no migrate/auth/payment writes until ยืนยัน; migrate run = second confirm + env by name)
- [ ] Write budget OK or override + user OK
- [ ] Minimal patch
- [ ] VERIFY per matrix: IDENTIFY → RUN → READ
- [ ] REPORT
```

Write budget ≤5 files / ≤120 lines only with explicit override + user OK.  
New/split modules: **purpose-named** (responsibility in the name). Do not equal-size split just to shrink line counts.

## Failure playbook

| Status | Do |
|--------|-----|
| Scope unclear | Ask once; do not invent capability-id sprawl |
| Cause goes unknown mid-make | Stop Lite; switch to `/fix` posture |
| Enterprise without confirm | `AWAITING_CONFIRM`; do not write or run (before writing migrate/auth/payment files) |
| Verify fails | Fix or `FAILED` with READ evidence; no “should work” |

## Never

Lite-patch unknown cause · silent scope/write-budget expand · dump monolith reads to locate edits · equal-size file chops without discoverable names · compress for line-count at expense of explicit intent (`explicit-intent`) · skip VERIFY READ · enterprise write/run without AWAITING_CONFIRM + BLAST_RADIUS+ROLLBACK

## Golden

In: `/make add-health-endpoint`  
Out: Lite · small route (+test if present) · VERIFY green · READY

In: `/make migrate-users --full`  
Out: `AWAITING_CONFIRM` + BLAST_RADIUS + ROLLBACK · no files written yet · wait `ยืนยัน` before writing

How to use: [USAGE.md](USAGE.md).

## Output

Follow [templates/response/make.md](../../templates/response/make.md). Shared [report.md](../../templates/response/report.md).
