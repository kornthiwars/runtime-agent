---
name: make
description: >-
  Implement a clear capability with Lite depth by default. Use when the user
  invokes /make with a capability-id, or asks to build/add a scoped feature with
  known outcome. Use --full or auto-full for schema, auth, shared modules, secrets, prod paths.
disable-model-invocation: true
---

# /make \<capability-id\>

Default **Lite**. Switch to **Full** if `--full` or auto-trigger (schema, auth, shared/SSoT, secrets/env, prod-facing).

## Steps

1. Parse capability-id + scope. State non-goals.
2. DEPTH: Lite | Full (reason: user | --full | auto-trigger).
3. RISK before patch. HIGH → approval. Schema/migration and other enterprise surfaces follow `enterprise-safety` (BLAST_RADIUS + ROLLBACK); flag API breaks.
4. Respect budget ≤5 files / ≤120 lines unless override + user OK.
5. Implement minimal change matching repo conventions.
6. Verify: IDENTIFY → RUN → READ.
7. REPORT + make block.

How to use (examples): [USAGE.md](USAGE.md).

## Output

Follow [templates/response/make.md](../../templates/response/make.md).
