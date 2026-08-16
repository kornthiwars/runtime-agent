# Changelog

## 1.2.11 — 2026-08-16

Post-1.2.10 audit apply (confirmed):

- `skill-router` / `/plan`: “static HTML” not generic “static screen”; product screen in the app → `/make`
- `agent-ops`: `approve`/`appove` ≠ consent; pack always-on / REPORT / slash-rename is **MED** (not LOW)
- `/ship`: those pack surfaces need `/review` before ship (waivable); empty stage `READY` in USAGE
- `/review` Nice-to-have → `approve-with-nits`; make USAGE names `/feature` slice; skills/README gated pipeline

## 1.2.10 — 2026-08-16

Make vs feature + audit leftovers (confirmed apply):

- `skill-router`: `/feature` only for ≥2 slices or gated pipeline (migrate + review + ship as slices); one patch even MED/HIGH → `/make` then `/review`; unknown-cause wrong data → `/fix`
- `/make` / `/fix`: RISK do-not-under-label; MED/HIGH close-out `NEXT: /review` then `/ship`
- `/upgrades apply`: locked apply confirm covers write-budget override; audit=`VERDICT` · propose=`PLAN_READY`
- `/review` Suggestion tie-break; `/note` list/find no-edit in SKILL; `/ship` empty stage = `READY`; `/plan` screen/HTML not generic “flow”
- Fixtures lock router make-vs-feature + review Suggestion

## 1.2.9 — 2026-08-15

Always-on + REPORT + MED rubric (confirmed apply):

- `agent-ops`: `/feature list` + `/plan list` + plan chat-only + `/note list|find` no-edit; ship statuses; **MED** defined (no under-label); write-budget consent ≠ bare `ok`
- `skill-router`: same-message `/review`+`/ship` → review first; NL “review and commit”; code+commit MED/HIGH → review then ship
- `report.md` STATUS adds `AWAITING_REVIEW` | `AWAITING_SHIP_CONFIRM`; fixtures lock always-on + REPORT
- feature/make/plan/fix/review/note/ship USAGE·SKILL consent, secrets override, and handoff clarity

## 1.2.8 — 2026-08-15

Post-1.2.7 clarity apply:

- `/ship`: split `AWAITING_REVIEW` vs `AWAITING_SHIP_CONFIRM`; `/ship ยืนยัน` ≠ review waive (USAGE + template)
- `/plan`: chat-only / อย่าเซฟ does **not** write `.plan.md`; `ทำแผน` stays draft; run consent matches agent-ops
- `/feature`: reuse + `MODE: list` in USAGE/template; fixtures for list/reuse + plan chat/`ทำแผน`
- ENTERPRISE surface→enum map in `report.md` (no new tokens); fix USAGE enterprise; notes-daily Infer-Skill drops bare `ok`
- README `/ship` gate; note USAGE open-only

Deferred (needs `ยืนยัน` for always-on rules): ~~`agent-ops` `/feature list` no-edit; skill-router review+ship~~ → done in **1.2.9**.

## 1.2.7 — 2026-08-15

Deep-audit apply (gates + Windows pre-commit + fixtures):

- Windows pre-commit: `pre-commit.ps1` runners (avoid Store-stub `python3`); install-hooks warn overwrite / reject non-dir `.git`
- Consent: only `ยืนยัน|confirm|yes` (not `continue`/`ทำต่อ`); `/upgrades apply` confirms always-on `rules/*.mdc`
- `/ship` recommends `/review` before MED/HIGH app push (waivable); `/feature list` + reuse existing `.feature.md`
- `ทำแผน` → `/plan` **draft**; `/note` documents `project=` / `title=` + open-only list
- Fixtures lock `agent-ops` / `skill-router` / `enterprise-safety`; bash 3.2-safe (no `mapfile`); real-`python3` check in notes-daily.sh

## 1.2.6 — 2026-08-15

Wording nits:

- `/plan` feature trigger uses **or** (match skill-router / `/feature`)
- `/make` + `/fix` enterprise surface lists aligned (`schema/auth/payments/infra/data/prod`) across skills + response templates + feature/plan nest lines

## 1.2.5 — 2026-08-15

Confirm nesting + small skill clarity:

- `/feature` / `/plan`: slice/todo `ยืนยัน` does not satisfy enterprise before-write (nested stop)
- `/feature <name> ยืนยัน` documented; `/note resolve` + `/note update`; `/review` Critical tie-break
- `agent-ops` same-message + nested enterprise note; fixtures for the above

## 1.2.4 — 2026-08-15

Upgrades audit apply (pending + docs + smoke + gates):

- notes-daily fills **Result** on `afterAgentResponse` (stop remains backup)
- Refresh `MIGRATE.md` / `README.md` for post-1.0.0 reality; install messaging fixed
- `scripts/smoke-notes-daily.*` + pack-ci; `OUTCOME` fixtures; `cursor-hooks/README.md`
- `/fix` enterprise stop parity with `/make` (+ evals)
- pre-commit matches CI (behavior + smoke); hooks.json event fixtures
- `/ship` push default clarified (`/ship ยืนยัน` = commit+push; `commit only` opt-out)

## 1.2.3 — 2026-08-15

Notes daily remaining footguns:

- Filter markdown headings from Result last-N fallback; prefer last REPORT field match
- Complete pending on today **and** yesterday (midnight edge)
- Disable checks parent/hook/pack `notes-daily.off` paths
- Debug log writes under hook `state/` (not process cwd)
- Install merges `hooks.json` (keeps non-notes-daily hooks)
- Unix: file:// / drive-letter normalize; portable skill sed; summarize parity

## 1.2.2 — 2026-08-15

Notes daily hook fixes:

- Insert prompt entries under `## Prompts` (before Outcomes); repair older EOF-appended layout
- Fix Windows `Get-JsonStringField` JSON unescape (`\n` / `\"` / `\\`)
- Unix parity: disable JSON, non-completed stop status prefix, clear last-response on new prompt
- Unix `redact` no longer fail-opens to raw `cat` when python3 is missing

## 1.2.1 — 2026-08-15

Notes Result ↔ response templates contract:

- Daily **Result** prefers `OUTCOME:` then REPORT fields (`STATUS`/`OBJECTIVE`/`CHANGES`/`NEXT`/`VERIFY`), else last ≤6 lines
- `templates/response/report.md` documents `OUTCOME` for daily hooks
- `templates/workspace/daily.md` updated

## 1.2.0 — 2026-08-15

Notes daily hooks (all prompts → one file per day):

- `beforeSubmitPrompt` + `afterAgentResponse` + `stop` via `cursor-hooks/notes-daily.ps1` / `.sh`
- Writes `.cursor/notes/daily/YYYY-MM-DD.md` (redact secrets; Result ≤6 lines from last agent reply)
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

