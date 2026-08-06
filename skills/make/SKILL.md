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
May run from `/plan run` or `/feature` slice. Ops: `agent-ops` · enterprise: `enterprise-safety`.  
Verify: [verify-matrix](../../templates/ops/verify-matrix.md).

## Checklist

```
/make progress:
- [ ] Memory recall: `search` → `MODEL-RUST:` · `note list` → `NOTES:` (`agent-ops`)
- [ ] capability-id + scope + non-goals
- [ ] DEPTH Lite|Full (reason)
- [ ] RISK (+ enterprise if needed)
- [ ] Budget OK or override + user OK
- [ ] Minimal patch
- [ ] VERIFY per matrix: IDENTIFY → RUN → READ
- [ ] REPORT
```

Budget > ≤5 files / ≤120 lines only with explicit override + user OK.

## Failure playbook

| Status | Do |
|--------|-----|
| Scope unclear | Ask once; do not invent capability-id sprawl |
| Cause goes unknown mid-make | Stop Lite; switch to `/fix` posture |
| Verify fails | Fix or `FAILED` with READ evidence; no “should work” |

## Never

Lite-patch unknown cause · silent scope/budget expand · skip VERIFY READ · enterprise without BLAST_RADIUS+ROLLBACK

## Golden

In: `/make add-health-endpoint`  
Out: Lite · small route (+test if present) · VERIFY green · READY

How to use: [USAGE.md](USAGE.md).

## Output

Follow [templates/response/make.md](../../templates/response/make.md). Shared [report.md](../../templates/response/report.md).
