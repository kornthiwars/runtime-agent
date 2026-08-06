---
name: upgrades
description: >-
  Audit, propose, or apply upgrades to this pack’s skills/rules/templates so
  agent behavior is clearer and stricter. Use when the user invokes /upgrades,
  or asks to tighten/refine pack skills. Do not use for app product work
  (/make|/feature), bugfixes (/fix), or publishing (/ship).
disable-model-invocation: true
---

# /upgrades

Improve **this pack**: clearer triggers, stricter gates, less ambiguity.  
Scope: `agent-skills/` only. App work → `/make` / `/feature`.

**Primary:** agent behavior quality. **Secondary:** skill ↔ template ↔ README ↔ install drift.

## Modes

| Invocation | Mode |
|------------|------|
| `/upgrades` · `/upgrades audit` | **audit** — gaps; no edits |
| `/upgrades propose …` | **propose** — plan; no edits |
| `/upgrades apply …` | **apply** — edit after gates |

## Quality lenses

1. **Trigger** — description/USAGE + NOT confused with other skills  
2. **Steps** — repeatable; no silent gate skips  
3. **Gates** — confirm / no-edit / enterprise / budget  
4. **Contracts** — REPORT / template / paths  
5. **Examples** — golden + USAGE  
6. **Drift** — README, `scripts/skill-names.txt`, junctions  

Prefer small precise upgrades. Do not invent slash commands unless asked.

## Steps

1. Scope (default: whole pack or named target).
2. Read `SKILL.md`, linked templates, `USAGE.md`, related rules / `reference.md`.
3. **audit / propose:** IMPROVEMENTS High/Med/Low; DRIFT/BREAKING; `CHANGES: none`. Status `PLAN_READY` or `VERDICT`.
4. **apply:** RISK + budget. Renaming slash or shared REPORT = confirm (`ยืนยัน`). Keep `disable-model-invocation: true` unless user asks otherwise.
5. Sync `scripts/skill-names.txt` + README; bump `VERSION`/`CHANGELOG` when meaningful; re-run install when links must refresh. Validate: `.\scripts\validate-skill-names.ps1` · `.\scripts\run-evals.ps1`.
6. Hand off publish to `/ship`. Optional: suggest `/note` for durable pack decisions — do not auto-write.

## Failure playbook

| Status | Do |
|--------|-----|
| Apply needs rename/REPORT change | `AWAITING_CONFIRM`; do not edit yet |
| validate-skill-names fails after apply | Fix drift before `/ship` |
| Scope is app product work | Redirect `/make`\|`/feature`; no pack edits |

Bump [VERSION](../../VERSION) + [CHANGELOG](../../CHANGELOG.md) on meaningful apply.

## Never

- Edit the user’s app under this skill  
- Ship/commit inside `/upgrades`  
- Apply renames/REPORT contract changes without confirm  

## Golden

In: `/upgrades audit`  
Out: ranked IMPROVEMENTS · `CHANGES: none` · `NEXT: propose|apply`

How to use: [USAGE.md](USAGE.md).

## Output

Follow [templates/response/upgrades.md](../../templates/response/upgrades.md). Shared REPORT **CONTRACT v2**.
