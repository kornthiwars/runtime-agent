---
name: feature
description: >-
  Orchestrate a feature pipeline by policy with confirm before work. Use when
  the user invokes /feature with a name, or wants plan→make/fix→review→ship
  without the agent implementing in the orchestrator turn.
disable-model-invocation: true
---

# /feature \<name\>

Pipeline: **plan → make/fix → review → ship**. Orchestrator does **not** implement in this turn.

## Steps

1. Name feature; draft SLICES with suggested `/make` or `/fix` and RISK per slice.
2. List IRREVERSIBLES (migrate, delete, force, …). Elevate confirm if HIGH or migration. Schema/migration and other enterprise surfaces must follow `enterprise-safety` (BLAST_RADIUS + ROLLBACK).
3. Ownership callout if shared / infra / DS touched.
4. Status `AWAITING_CONFIRM`. Prompt: reply `ยืนยัน` to start.
5. After confirm only: hand off first slice to `/make` or `/fix` — one owner per slice.
6. Do not skip `/review` before `/ship` for MED/HIGH.

How to use (examples): [USAGE.md](USAGE.md).

## Output

Follow [templates/response/feature.md](../../templates/response/feature.md).
