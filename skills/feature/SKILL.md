---
name: feature
description: >-
  Orchestrate a product feature pipeline (plan slices → make/fix → review →
  ship) with one confirm per slice; persist slices under workspace
  .cursor/features/*.feature.md. Use when the user invokes /feature with a
  name, or wants gated product delivery (≥2 slices or review-before-ship).
  Do not use for UI demos / HTML clones (/plan), a single clear capability
  (/make), unknown bugs (/fix), or pack edits (/upgrades).
disable-model-invocation: true
---

# /feature \<name\>

Pipeline: **plan → make/fix → review → ship**.  
Persist state: workspace `.cursor/features/<slug>_<8hex>.feature.md`  
(template: [feature-template](../../templates/memory/feature-template.md)).  
Not part of pack git unless the user asks.

## vs `/plan` · `/make` (pick one)

| Signal | Use |
|--------|-----|
| UI demo / HTML clone / static screen / saved todo graph | **`/plan`** |
| One clear capability, no review-before-ship gate | **`/make`** |
| ≥2 slices **or** must `/review` before `/ship` | **`/feature`** |

**Pair examples:** “LINE home HTML” → `/plan` · “add health endpoint” → `/make` · “Checkout v2 + migrate + review” → `/feature`

## Turns

| Phase | What happens |
|-------|----------------|
| **Plan turn** | Write/update `.feature.md` slices only. **No app code.** `AWAITING_CONFIRM`. |
| **Slice turn** | One pending slice → `/make` or `/fix` → mark `completed` in file. Stop. |
| **Review / ship** | `/review` then `/ship` (required if any slice MED/HIGH). |

One confirm = **one slice**. Notes/RISK/enterprise: `agent-ops` + `enterprise-safety`.

## Steps

1. Memory recall (`agent-ops`): RUN `model-rust search` + `note list`; cite `MODEL-RUST:` / `NOTES:`.
2. Resolve file: path, name substring, or create `<slug>_<8hex>.feature.md`.
3. Draft `slices[]` (`id`, `content` with `/make`|`/fix`, `risk`, `status: pending`) + irreversibles + enterprise.
4. Ownership callout if shared/infra/DS. Write file. Report `PATH`.
5. `AWAITING_CONFIRM` — `ยืนยัน` for **next pending slice only**.
6. After confirm: set `in_progress` → execute → `completed`. Update file only for that slice status.
7. `NEXT: ยืนยัน slice-N` or `/review` / `/ship` when no pending left.
8. Do not skip `/review` before `/ship` for MED/HIGH.
9. Emit `MODEL-RUST-PROJECT: <slug>` on substantive replies.

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

Follow [templates/response/feature.md](../../templates/response/feature.md).
