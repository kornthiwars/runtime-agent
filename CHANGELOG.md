# Changelog

## 1.0.1 — 2026-08-15

`/make` enterprise stop gate:

- Checklist + Never: enterprise surfaces require `AWAITING_CONFIRM` + BLAST_RADIUS/ROLLBACK **before writing** (migrate run = second confirm + env by name)
- `templates/response/make.md` enterprise REPORT block
- Fixtures/behavior: `make-enterprise-blast` · `make-enterprise-stop`

## 1.0.0 — 2026-08-15

Fresh pack:

- Skills: `/fix` · `/make` · `/plan` · `/feature` · `/review` · `/ship` · `/upgrades`
- Rules: `skill-router` · `agent-ops` · `enterprise-safety` · `explicit-intent`
- No `model-rust`, `/note`, or auto memory hooks
- `VERSION` = `1.0.0`
- Evals + install scripts for parent-workspace `.cursor` junctions
- Plan/feature templates live under `templates/workspace/` (not `templates/memory/`)
- Removed empty orphan `skills/memory/`; eval fixture guards `templates/workspace/`

