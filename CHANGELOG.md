# Changelog

## 1.2.0 — 2026-08-15

Notes daily hooks (all prompts → one file per day):

- `beforeSubmitPrompt` + `afterAgentResponse` + `stop` via `cursor-hooks/notes-daily.ps1` / `.sh`
- Writes `.cursor/notes/daily/YYYY-MM-DD.md` (redact secrets; Result ≤3 lines from last agent reply)
- Opt-out: `NOTES_DAILY_AUTO=0` or `.cursor/hooks/state/notes-daily.off`
- Install copies hooks into parent workspace **and** pack `.cursor/` (Cursor binds nested git roots)
- Windows hardenings: normalize `/c:/...` roots, UTF-8 stdin (no CP874 mojibake), ASCII-safe `.ps1` literals
- Template `templates/workspace/daily.md`

## 1.1.0 — 2026-08-15

`/note` project problems (phase 1 — no daily hooks yet):

- Skill `/note` add|list|find → `.cursor/notes/projects/<slug>/problems/`
- Templates: `note-problem.md` · response `note.md`
- Router + skill-names; install creates `notes/daily` + `notes/projects`
- Evals: note-write-problem · note-not-plan · note-problem-path
- Daily-all-prompts added in 1.2.0

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

