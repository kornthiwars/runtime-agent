---
name: make
description: >-
  Implement a clear capability with Lite depth by default. Use when the user
  invokes /make with a capability-id, or asks to build/add a scoped feature with
  known outcome. Not for unknown-cause bugs — use /fix. Use --full or auto-full
  for schema, auth, shared modules, secrets, prod paths.
disable-model-invocation: true
---

# /make \<capability-id\>

Default **Lite**. Switch to **Full** if `--full` or auto-trigger (schema, auth, shared/SSoT, secrets/env, prod-facing).

**vs `/fix`:** clear build goal + known shape of change → **this skill**.
Unknown root cause, regressions, flaky tests, wrong data → `/fix` (do not Lite-patch).
If cause goes unclear while making → stop Lite guessing; continue as `/fix`.

May be invoked **directly** or as a step from `/plan run` / `/feature` slice (same rules).

## Steps

1. **Notes recall** (see `agent-ops`): read up to 3 newest non-expired notes for PROJECT.
2. Parse capability-id + scope. State non-goals.
3. DEPTH: Lite | Full (reason: user | --full | auto-trigger).
4. RISK before patch. HIGH → approval. Schema/migration and other enterprise surfaces follow `enterprise-safety` (BLAST_RADIUS + ROLLBACK); flag API breaks.
5. Respect budget ≤5 files / ≤120 lines unless override + user OK.
6. Implement minimal change matching repo conventions.
7. Verify: IDENTIFY → RUN → READ.
8. REPORT + make block.

How to use (examples): [USAGE.md](USAGE.md).

## Output

Follow [templates/response/make.md](../../templates/response/make.md).
