---
name: make
description: >-
  Implement a clear capability with Lite depth by default (minimal patch +
  verify). Use when the user invokes /make with a capability-id, or asks to
  build a scoped feature with known outcome. Do not use for unknown-cause bugs
  (/fix), multi-todo UI graphs (/plan), full feature pipelines (/feature), or
  commit (/ship). Use --full or auto-full for schema, auth, shared modules,
  secrets, prod paths.
disable-model-invocation: true
---

# /make \<capability-id\>

Default **Lite**. Switch to **Full** if `--full` or auto-trigger (schema, auth, shared/SSoT, secrets/env, prod-facing).

**vs `/fix`:** clear build goal → **this skill**. Unknown cause → `/fix`.  
May run directly or as a `/plan run` / `/feature` slice step (same rules).

Notes recall, RISK, budget (≤5 files / ≤120 lines), verify: `agent-ops`.  
Schema/migration and enterprise surfaces: `enterprise-safety`.

## Checklist (copy progress)

```
/make progress:
- [ ] Notes recall (≤3)
- [ ] capability-id + scope + non-goals
- [ ] DEPTH: Lite | Full (reason)
- [ ] RISK (HIGH → approval); enterprise if needed
- [ ] Budget OK or override + user OK
- [ ] Minimal patch (repo conventions)
- [ ] VERIFY: IDENTIFY → RUN → READ
- [ ] REPORT + make block
```

## Budget override

Over ≤5 files / ≤120 lines only with **explicit override + user OK** in-thread. State the overrun in REPORT.

## Never

- Lite-patch unknown root cause  
- Expand scope beyond capability-id  
- Skip VERIFY READ  
- Touch enterprise surfaces without BLAST_RADIUS + ROLLBACK

## Golden

In: `/make add-health-endpoint`.  
Out: DEPTH Lite · small route + test · VERIFY green · REPORT READY.

How to use: [USAGE.md](USAGE.md).

## Output

Follow [templates/response/make.md](../../templates/response/make.md).
