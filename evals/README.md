# Pack evals

## CI-covered (automated)

| Runner | What it guards |
|--------|----------------|
| `scripts/run-evals.*` | Structural needles in `SKILL.md` / templates / rules (`evals/fixtures/`) |
| `scripts/run-behavior-evals.*` | Golden In/Out + gate needles (`evals/behavior/`) |
| `scripts/smoke-notes-daily.*` | notes-daily fills **Result** on `afterAgentResponse` without `stop` (CI uses `.sh`; Windows local: `.ps1`) |

```powershell
.\scripts\validate-skill-names.ps1
.\scripts\run-evals.ps1
.\scripts\run-behavior-evals.ps1
.\scripts\smoke-notes-daily.ps1
```

```bash
./scripts/validate-skill-names.sh
./scripts/run-evals.sh
./scripts/run-behavior-evals.sh
./scripts/smoke-notes-daily.sh
```

Structural fixture fields: `skill`, optional `path`, `skill_must_contain`, `expect_status`, `expect_redirect_hint`, `expect_depth`, `expect_verdict_any`, `forbidden_actions` (required documented strings — not a live agent ban).

Behavior fixtures: [behavior/README.md](behavior/README.md).

## Still manual (live Cursor agent)

These need a real Agent turn; CI only locks related needles in SKILL.md:

| Prompt | Expect live |
|--------|-------------|
| `/plan` clone UI | writes `.cursor/plans/*.plan.md`; no app edit until `/plan run` + confirm |
| `/feature checkout-v2` | writes `.cursor/features/*.feature.md`; `AWAITING_CONFIRM` before slices |
| `/note` remember … | creates `.cursor/notes/projects/…/problems/` file |
| `/ship` without confirm | no commit · `AWAITING_SHIP_CONFIRM` |
| `/ship` MED/HIGH app or pack always-on without `/review` | `AWAITING_REVIEW` (unless waive) |
| End-to-end notes-daily in Cursor Hooks tab | entry appears in today’s daily after a real chat |

## Negative (router / skill choice)

| Prompt | Must NOT |
|--------|----------|
| Facebook home via `/fix` | treat as bug fix — prefer `/plan` |
| `/feature` for static HTML demo | prefer `/plan` |
| Product React “settings screen” | start `/plan` — use `/make` (or `/feature` if ≥2 slices) |
| MED/HIGH one-patch “add settings toggle” | start `/feature` — use `/make` then `/review` |
| `/ship` staging workspace plans/demos into pack | skip unless asked |
