# Pack regression prompts (manual or agent eval)

Use these as `/upgrades` / skill smoke checks. Expected behavior is brief.

## Triggers

| Prompt | Expect |
|--------|--------|
| `/fix` flaky total on checkout | Full diagnose; no patch before repro |
| `/make add-health-endpoint` | Lite make; not `/feature` |
| `/plan` clone LINE home HTML | Writes `.cursor/plans/*.plan.md`; no app edit |
| `/feature checkout-v2` | Slices + AWAITING_CONFIRM; no app edit |
| `/review` with client API_KEY in diff | `block` or Critical with evidence |
| `/ship` without ยืนยัน | AWAITING_CONFIRM; no commit |
| `/note` remember junctions → parent workspace | Short decision note under `notes/…` |
| `/upgrades audit` | IMPROVEMENTS; CHANGES none |

## Negative

| Prompt | Must NOT |
|--------|----------|
| Build Facebook home via `/fix` | Treat as bugfix — redirect `/plan` |
| `/feature` for static HTML demo | Prefer `/plan` |
| `/ship` staging `notes/` into pack | Skip unless user asks |
| `/note` store full plan todos | Redirect `/plan` |

## Scripts

```powershell
.\scripts\validate-skill-names.ps1
```
