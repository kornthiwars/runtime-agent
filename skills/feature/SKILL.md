---
name: feature
description: >-
  Orchestrate a product feature pipeline (plan slices → make/fix → review →
  ship) with one confirm per slice; persist slices under workspace
  .cursor/features/*.feature.md. Use when the user invokes /feature with a
  name, /feature list, or wants gated product delivery (≥2 slices or
  migrate+review+ship as slices). Do not use for UI demos / HTML clones (/plan), a single
  clear capability (/make), unknown bugs (/fix), or pack edits (/upgrades).
disable-model-invocation: true
---

# /feature \<name\>

Pipeline: **plan → make/fix → review → ship**.  
Persist state: workspace `.cursor/features/<slug>_<8hex>.feature.md`  
(template: [feature-template](../../templates/workspace/feature-template.md)).  
Not part of pack git unless the user asks.

## vs `/plan` · `/make` (pick one)

| Signal | Use |
|--------|-----|
| UI demo / HTML clone / static HTML / saved todo graph | **`/plan`** |
| One clear capability (one patch; MED/HIGH still `/make` then `/review`) | **`/make`** |
| ≥2 slices **or** explicit pipeline (migrate + review + ship as slices) | **`/feature`** |

**Pair examples:** “LINE home HTML” → `/plan` · “add health endpoint” → `/make` · “Checkout v2 + migrate + review” → `/feature`

## Modes

| Invocation | Mode |
|------------|------|
| `/feature <name>` | **plan** — write/update `.feature.md`; no app edits |
| `/feature list` | **list** — workspace `*.feature.md` |
| `/feature <name> ยืนยัน` · follow-up `ยืนยัน`/`confirm`/`yes` | **slice** — one pending slice |

## Turns

| Phase | What happens |
|-------|----------------|
| **Plan turn** | Write/update `.feature.md` slices only. **No app code.** `AWAITING_CONFIRM`. |
| **Slice turn** | One pending slice → `/make` or `/fix` → mark `completed` in file. Stop. |
| **Review / ship** | `/review` then `/ship` (required if any slice MED/HIGH). |

One confirm = **one slice**. Notes/RISK/enterprise: `agent-ops` + `enterprise-safety`.

**Nested confirms:** Slice `ยืนยัน` only authorizes running that slice’s `/make`|`/fix`. It does **not** replace an enterprise before-write stop. If the slice hits schema/auth/payments/infra/data/prod, `/make`|`/fix` must still emit `AWAITING_CONFIRM` + BLAST_RADIUS + ROLLBACK and wait for a **separate** `ยืนยัน` before writing; migrate **run** needs yet another confirm + env by name.

## Steps

1. Resolve file: exact path, name substring, or **reuse** newest matching `<slug>_*.feature.md` if one exists; only create `<slug>_<8hex>.feature.md` when none match (do not fork a second file for the same feature).
2. Draft `slices[]` (`id`, `content` with `/make`|`/fix`, `risk`, `status: pending`) + irreversibles + enterprise.
3. Ownership callout if shared/infra/DS. Write file. Report `PATH`.
4. `AWAITING_CONFIRM` — consent word `ยืนยัน`/`confirm`/`yes` for **next pending slice only** (not `continue`/`ทำต่อ`/`ทำเลย`/`ok` alone).
5. After confirm: set `in_progress` → execute → `completed`. Update file only for that slice status.
6. `NEXT: ยืนยัน slice-N` or `/review` / `/ship` when no pending left.
7. Do not skip `/review` before `/ship` for MED/HIGH.

## list

Newest first, cap 20: file, name, pending/completed counts. No edits.

## Failure playbook

| Status | Do |
|--------|-----|
| BLOCKED mid-slice | Leave slice `in_progress` or revert to `pending`; ask **one** question; do not start next slice |
| User abandons | Leave file; do not delete unless asked |
| Wrong skill (UI demo) | Stop; tell user to use `/plan`; do not invent slices for HTML clones |

## Never

- Implement on the plan turn · drain all slices on one confirm · skip `/review` after MED/HIGH · rely on chat memory instead of the `.feature.md` file

## Golden

In: `/feature checkout-v2`  
Out: `.cursor/features/checkout_v2_<8hex>.feature.md` · SLICES pending · `AWAITING_CONFIRM` · no app edits.

How to use: [USAGE.md](USAGE.md).

## Output

Follow [templates/response/feature.md](../../templates/response/feature.md). Shared [report.md](../../templates/response/report.md).
