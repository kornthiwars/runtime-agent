---
name: plan
description: >-
  Draft or run Cursor-format plan files at workspace .cursor/plans/*.plan.md
  (YAML todos). Draft does not edit app code; run completes one pending todo via
  /make or /fix after confirm. Use when the user invokes /plan or /plan run,
  or for UI/multi-step task graphs. Do not use for product feature pipelines that
  require /review before /ship (/feature), durable memory (/note), or pack
  upgrades (/upgrades).
disable-model-invocation: true
---

# /plan

Cursor Plan **file format** under workspace `.cursor/plans/*.plan.md`.  
Details (filename, frontmatter, storage): [reference.md](reference.md).

## vs `/feature` (pick one)

| Signal | Use |
|--------|-----|
| UI demo / HTML clone / static screen / multi-todo build graph | **`/plan`** |
| Product feature needing **≥2 slices** + **`/review` before `/ship`** | **`/feature`** |
| One clear capability (no graph) | **`/make`** — not `/plan` |
| Unsure + “build this screen/flow” | **`/plan`** |
| Unsure + “ship a gated product feature” | **`/feature`** |

**Pair examples**

- “Clone LINE home in HTML” → `/plan` → `/plan run`…  
- “Add billing portal + migrate + review before ship” → `/feature`

## Modes

| Invocation | Mode |
|------------|------|
| `/plan` · `/plan …` | **draft** — write `.plan.md`; no app edits |
| `/plan list` | **list** — workspace `*.plan.md` |
| `/plan run` · `/plan run <file\|name>` · `ทำแผน` | **run** — next pending todo |
| chat-only / อย่าเซฟ | **draft** without file |

## draft (hot path)

1. Notes recall (`agent-ops`).
2. Write plan per [reference.md](reference.md) + [plan-template](../../templates/memory/plan-template.md).
3. Every todo `content` should start with `/make` or `/fix` when possible.
4. `PLAN_READY`. Do **not** implement. Same-message “ทำเลย” on draft still does **not** run.
5. `NEXT: /plan run <filename>`.

## list

Newest first, cap 20: file, name, pending/completed counts. No edits.

## run

1. Resolve file (path, name substring, or newest with pending).
2. First `pending` (or resume `in_progress`).
3. Skill tag from `content` (`/make` or `/fix`); else infer and state in REPORT — or ask once.
4. Confirm (`ยืนยัน`). **One confirm = one todo.** Update only that todo’s `status` in frontmatter.
5. Execute with that skill’s rules. Do not drain all todos on one confirm.
6. When done: suggest `/review` then `/ship` for MED/HIGH.

## Failure playbook

| Status | Do |
|--------|-----|
| No plan file / ambiguous name | List candidates or ask once |
| Todo has no `/make`\|`/fix` and ambiguous | Infer once in REPORT or ask; never silent enterprise Lite |
| Slice/todo fails verify | Leave todo `in_progress` or back to `pending`; do not mark `completed` |

## Never

- Edit app code on draft/list  
- Run without confirm  
- Store plans in `/note` or legacy `plans/<project>/`  
- `/ship` workspace plans into the pack repo unless asked

## Golden

In: `/plan` “Facebook home static HTML”.  
Out: `.cursor/plans/facebook_home_html_<8hex>.plan.md` · todos with `/make` · `PLAN_READY` · no app files yet.

How to use: [USAGE.md](USAGE.md).

## Output

Follow [templates/response/plan.md](../../templates/response/plan.md).
