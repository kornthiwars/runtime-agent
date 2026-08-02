---
name: feature
description: >-
  Orchestrate a feature pipeline by policy with confirm before work. Use when
  the user invokes /feature with a name, or wants plan→make/fix→review→ship
  without implementing every slice in the first turn.
disable-model-invocation: true
---

# /feature \<name\>

Pipeline: **plan → make/fix → review → ship**.

## Turns

| Phase | What happens |
|-------|----------------|
| **Plan turn** (`/feature …`) | Draft SLICES only. **No app code.** `AWAITING_CONFIRM`. |
| **Slice turn** (after `ยืนยัน` / `continue` / `ทำต่อ`) | This agent runs **one** pending slice end-to-end (follow `/make` or `/fix` steps). Then stop. |
| **Review / ship** | User runs `/review` then `/ship` (required before ship when any slice was MED/HIGH). |

One confirm = **one slice**. Do not drain the whole pipeline on a single `ยืนยัน`.

## Steps

1. **Notes recall** (see `agent-ops`): read up to 3 newest non-expired notes for PROJECT.
2. Name feature; draft SLICES with suggested `/make` or `/fix` and RISK per slice.
3. List IRREVERSIBLES (migrate, delete, force, …). Elevate confirm if HIGH or migration. Schema/migration and other enterprise surfaces must follow `enterprise-safety` (BLAST_RADIUS + ROLLBACK).
4. Ownership callout if shared / infra / DS touched.
5. Status `AWAITING_CONFIRM`. Prompt: reply `ยืนยัน` to run **slice 1 only**.
6. After confirm: execute that slice yourself using `/make` or `/fix` skill rules — do **not** require the user to type `/make` unless they want to. One owner per slice.
7. End the slice turn with REPORT + `NEXT: ยืนยัน slice-N` (or `/review` / `/ship` when slices done). Wait for the next confirm before another slice.
8. Do not skip `/review` before `/ship` for MED/HIGH.

How to use (examples): [USAGE.md](USAGE.md).

## Output

Follow [templates/response/feature.md](../../templates/response/feature.md).
