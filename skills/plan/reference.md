# /plan — reference

## Storage

- `PLANS_DIR` = `<workspace-root>/.cursor/plans` (create if missing)
- Filename: `<slug>_<8hex>.plan.md`
  - `slug`: lowercase `[a-z0-9_]+` from title
  - `8hex`: eight hex chars; if file exists, regenerate hex
- **Workspace only** — not part of the `agent-skills` git pack unless the user asks
- Never write under `USERPROFILE` / `~/.cursor/plans` unless the user asks
- Template: [templates/memory/plan-template.md](../../templates/memory/plan-template.md)

## Frontmatter (must match Cursor plan shape)

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

Body: markdown (goal, approach, non-goals, links).  
During `run`, change **only** todo `status` in frontmatter (not the body).

## Validate

From pack root:

```powershell
.\scripts\validate-plan.ps1 -Path "..\..\.cursor\plans\your_plan.plan.md"
```

```bash
./scripts/validate-plan.sh ../../.cursor/plans/your_plan.plan.md
```
