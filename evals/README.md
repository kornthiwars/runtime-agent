# Pack evals (structural smoke)

Fixtures under `fixtures/` encode prompts + **contracts the SKILL.md must still satisfy**.
`scripts/run-evals.*` checks schema + `skill_must_contain` (pass rate must be ≥95%).

This is **not** a live agent transcript runner — it guards skill regressions in CI.

## Run

```powershell
.\scripts\validate-skill-names.ps1
.\scripts\run-evals.ps1
```

```bash
./scripts/validate-skill-names.sh
./scripts/run-evals.sh
```

## Manual behavior checks

| Prompt | Expect |
|--------|--------|
| `/fix` flaky total | Full diagnose; no patch before repro |
| `/make add-health-endpoint` | Lite; not `/feature` |
| `/plan` clone LINE home HTML | `.cursor/plans/*.plan.md`; no app edit |
| `/feature checkout-v2` | `.cursor/features/*.feature.md`; AWAITING_CONFIRM |
| `/review` client API_KEY | block / Critical + evidence |
| `/ship` without ยืนยัน | AWAITING_CONFIRM; no commit |
| `/note` remember junctions | short decision under `notes/` |
| `/upgrades audit` | IMPROVEMENTS; CHANGES none |

## Negative

| Prompt | Must NOT |
|--------|----------|
| Facebook home via `/fix` | treat as bugfix — prefer `/plan` |
| `/feature` for static HTML demo | prefer `/plan` |
| `/ship` staging `notes/` into pack | skip unless asked |
| `/note` store full plan todos | redirect `/plan` |
