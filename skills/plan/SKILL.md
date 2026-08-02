---
name: plan
description: >-
  Draft or run Cursor-style plan files under workspace .cursor/plans/*.plan.md
  (YAML todos). Draft does not edit app code. Run completes one pending todo via
  /make or /fix after confirm. Use when the user invokes /plan or /plan run.
disable-model-invocation: true
---

# /plan

Store plans in **Cursor Plan file format** under the **workspace**  
`.cursor/plans/*.plan.md`. Same shape as native Plan mode files — different
entry (`/plan` skill vs Cursor Plan UI). Do **not** use legacy `plans/<project>/`.

## vs `/feature`

| Use `/plan` when… | Use `/feature` when… |
|-------------------|----------------------|
| Task graph / UI build / multi-todo saved as `.plan.md` | Product feature pipeline with required `/review` before `/ship` |
| You want `/plan run` one todo at a time from a file | Named feature slices + irreversibles up front |

If unsure and work is “build this screen/flow” → `/plan`. If “ship a product feature with gates” → `/feature`.

## Modes

| Invocation | Mode |
|------------|------|
| `/plan` · `/plan …` | **draft** — write `.plan.md`; no app edits |
| `/plan list` | **list** — list workspace `.cursor/plans/*.plan.md` |
| `/plan run` · `/plan run <file\|name>` · `ทำแผน` | **run** — next pending todo |
| chat-only / อย่าเซฟ | **draft** without file |

## Storage

- `PLANS_DIR` = `<workspace-root>/.cursor/plans` (create if missing)
- Filename: `<slug>_<8hex>.plan.md`
  - `slug`: lowercase `[a-z0-9_]+` from title
  - `8hex`: eight hex chars (e.g. from random / timestamp hash). If file exists, regenerate hex
- **Workspace only** — plans are local to this workspace. They are **not** part of the `agent-skills` git pack; do not `/ship` them into the pack unless the user asks
- Never write under `USERPROFILE` / `~/.cursor/plans` unless the user asks
- Template: [templates/memory/plan-template.md](../../templates/memory/plan-template.md)

Frontmatter **must** match Cursor plan shape:

```yaml
---
name: Short title
overview: One-line summary
todos:
  - id: step-id
    content: "`/make id` — …"   # or `/fix` — …
    status: pending | in_progress | completed | cancelled
isProject: false
---
```

Body: markdown (goal, approach, non-goals, links). During `run`, change **only** todo `status` in frontmatter (not the body).

## draft

1. Notes recall (`agent-ops`).
2. `name` + `overview` + markdown body.
3. `todos[]`: stable `id`; every `content` **should** start with `/make …` or `/fix` (required when possible). All `pending`.
4. Write file unless chat-only.
5. `PLAN_READY`. Do **not** implement.
6. In REPORT: full `PATH` (workspace-relative), `NAME`, todo count. Tell the user this is a **Plan-mode-format** file under `.cursor/plans/` (openable like other `.plan.md`).
7. `NEXT: /plan run <filename>`. Same-message “ทำเลย” on draft still does **not** run.

## list

List `*.plan.md` in `PLANS_DIR` (newest first, cap 20): file, name, pending/completed counts.

## run

1. Resolve file: path, name substring, or newest plan with pending todos (else ask).
2. Read frontmatter. Skip if no `pending`/`in_progress` unless user forces.
3. Select first `pending` todo (or resume `in_progress`).
4. **Skill tag:** if `content` has `/make` or `/fix`, use that. Else **infer** (`/fix` if bug/regression language; else `/make`) and state the inference in REPORT — or ask once if still ambiguous. Do not guess enterprise/migrate as Lite `/make` without gates.
5. RISK / `enterprise-safety` as usual.
6. Confirm (`ยืนยัน` / `/plan run … ยืนยัน` same message after inspect). **One confirm = one todo.**
7. Set `in_progress` → execute with that skill’s rules → set `completed`.
8. If no pending left → REPORT plan complete; suggest `/review` then `/ship` when MED/HIGH.
9. `NEXT: /plan run` · `ยืนยัน` · `/review` · `/ship`.

Do not drain all todos on one confirm.

## Output

Follow [templates/response/plan.md](../../templates/response/plan.md).

How to use (examples): [USAGE.md](USAGE.md).
