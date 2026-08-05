---
name: feature
description: >-
  Orchestrate a product feature pipeline (plan slices → make/fix → review →
  ship) with one confirm per slice. Use when the user invokes /feature with a
  name, or wants gated product delivery without implementing every slice in the
  first turn. Do not use for UI demos / HTML clones / static screens (/plan),
  single clear builds (/make), unknown bugs (/fix), or pack edits (/upgrades).
disable-model-invocation: true
---

# /feature \<name\>

Pipeline: **plan → make/fix → review → ship**.

## vs `/plan` (pick one)

| Signal | Use |
|--------|-----|
| UI demo / HTML clone / static screen / saved todo graph | **`/plan`** |
| Product feature + slice confirms + **`/review` before `/ship`** | **`/feature`** |

**Pair examples**

- “LINE home HTML mock” → `/plan`  
- “Checkout v2 with payment + migration, review before ship” → `/feature`

## Turns

| Phase | What happens |
|-------|----------------|
| **Plan turn** (`/feature …`) | Draft SLICES only. **No app code.** `AWAITING_CONFIRM`. |
| **Slice turn** (after `ยืนยัน` / `continue` / `ทำต่อ`) | Run **one** pending slice end-to-end (`/make` or `/fix` rules). Then stop. |
| **Review / ship** | User runs `/review` then `/ship` (required before ship when any slice was MED/HIGH). |

One confirm = **one slice**. Do not drain the pipeline on a single `ยืนยัน`.

Notes recall, RISK, enterprise: `agent-ops` + `enterprise-safety`.

## Steps

1. Notes recall (`agent-ops`).
2. Name feature; draft SLICES with suggested `/make` or `/fix` and RISK per slice.
3. List IRREVERSIBLES; elevate confirm if HIGH or migration.
4. Ownership callout if shared / infra / DS touched.
5. `AWAITING_CONFIRM` — reply `ยืนยัน` for **slice 1 only**.
6. After confirm: execute that slice yourself — user need not type `/make` unless they want to.
7. End with REPORT + `NEXT: ยืนยัน slice-N` (or `/review` / `/ship` when done).
8. Do not skip `/review` before `/ship` for MED/HIGH.

## Never

- Implement on the plan turn  
- Run all slices on one confirm  
- Route UI demos through `/feature`  
- Skip `/review` after MED/HIGH slices

## Golden

In: `/feature checkout-v2`.  
Out: SLICES + IRREVERSIBLES · `AWAITING_CONFIRM` · no app edits until `ยืนยัน`.

How to use: [USAGE.md](USAGE.md).

## Output

Follow [templates/response/feature.md](../../templates/response/feature.md).
