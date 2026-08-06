# Pack evals (structural smoke)

Fixtures under `fixtures/` encode prompts + **rules the SKILL.md must still satisfy**.
`scripts/run-evals.*` checks (pass rate must be ≥95%):

| Field | Assert |
|-------|--------|
| `skill_must_contain` | every needle in `SKILL.md` |
| `expect_status` | every status token in `SKILL.md` |
| `expect_redirect_hint` | needle in `SKILL.md` |
| `expect_depth` | needle in `SKILL.md` |
| `expect_verdict_any` | at least one needle in `SKILL.md` |
| `forbidden_actions` | each entry is a **required string** documented in `SKILL.md` (structural — not a live agent ban) |

This is **not** a live agent transcript runner — it guards skill regressions in CI.

## Run

```powershell
.\scripts\validate-skill-names.ps1
.\scripts\run-evals.ps1
.\scripts\run-behavior-evals.ps1
```

```bash
./scripts/validate-skill-names.sh
./scripts/run-evals.sh
./scripts/run-behavior-evals.sh
```

Golden behavior needles: [behavior/README.md](behavior/README.md).

## Manual behavior checks

| Prompt | Expect |
|--------|--------|
| `/fix` flaky total | Full diagnose; no patch before repro |
| `/make add-health-endpoint` | Lite; not `/feature` |
| `/plan` clone LINE home HTML | `.cursor/plans/*.plan.md`; no app edit |
| `/feature checkout-v2` | `.cursor/features/*.feature.md`; AWAITING_CONFIRM |
| `/review` client API_KEY | block / Critical + evidence |
| `/ship` without ยืนยัน | AWAITING_CONFIRM; no commit |
| `/note` remember junctions | `note add` → Mongo `notes` id; no `notes/*.md` |
| `/upgrades audit` | IMPROVEMENTS; CHANGES none |
| `/plan run` without confirm | AWAITING_CONFIRM |
| REPORT close-out | `MODEL-RUST` / `NOTES` per report.md |

## Negative

| Prompt | Must NOT |
|--------|----------|
| Facebook home via `/fix` | treat as bugfix — prefer `/plan` |
| `/feature` for static HTML demo | prefer `/plan` |
| `/ship` staging workspace plans/demos into pack | skip unless asked |
| `/note` store full plan todos | redirect `/plan` |
