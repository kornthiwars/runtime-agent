# Migrate / upgrade notes

## Current baseline

See [VERSION](VERSION) and [CHANGELOG](CHANGELOG.md). Re-run install after pull; open the **parent** workspace; restart Cursor once.

```powershell
cd agent-skills
git pull
.\scripts\install-windows.ps1
.\scripts\validate-skill-names.ps1
.\scripts\run-evals.ps1
.\scripts\run-behavior-evals.ps1
.\scripts\smoke-notes-daily.ps1
```

```bash
cd agent-skills
git pull
./scripts/install-unix.sh
./scripts/validate-skill-names.sh
./scripts/run-evals.sh
./scripts/run-behavior-evals.sh
./scripts/smoke-notes-daily.sh
```

Install writes hooks into **both** parent `.cursor/` and pack `.cursor/` (Cursor often binds the nested git root). Reinstall **merges** pack `notes-daily` into existing `hooks.json` and keeps other custom hook commands.

## History: break from old Mongo / model-rust packs (1.0.0)

These removals happened at the 1.0.0 reset (not the current tip):

1. Removed `model-rust` (crate, Mongo CLI, recall gates).
2. Removed the old Mongo-backed `/note` and auto memory hooks (`model-rust-auto.*`).
3. Shared REPORT dropped `MODEL-RUST` / `NOTES` fields.
4. `VERSION` restarted at `1.0.0` (not continuous with old `2.x`–`4.x` tags).

Mongo Atlas data (if any) was **not** deleted by the pack. Purge the old DB yourself if needed.

## Since 1.0.0 (restored / added)

| Version | What |
|---------|------|
| 1.1.0 | `/note` returns as **file-based** project problems under `.cursor/notes/projects/…/problems/` |
| 1.2.0+ | **notes-daily** hooks: every prompt → `.cursor/notes/daily/YYYY-MM-DD.md` |
| 1.2.1 | Daily Result prefers `OUTCOME:` then REPORT fields |
| 1.2.2–1.2.3 | Layout insert, JSON unescape, Unix parity, midnight/off/debug, install merge |
| 1.2.7 | Windows pre-commit PS1; consent vocab; upgrades rules confirm; ship review gate; feature list; no mapfile |
| 1.2.6 | Plan/feature “or” wording; make/fix enterprise surface list aligned |
| 1.2.5 | Nested enterprise confirms under feature/plan; note resolve/update; review Critical tie-break |
| 1.2.4 | Result on `afterAgentResponse`; docs/smoke; `/fix` enterprise parity; pre-commit=CI; ship push default clarified |

## Daily hooks (operators)

- Events: `beforeSubmitPrompt` → `afterAgentResponse` (fills **Result**) → `stop` (status prefix / cleanup if still pending).
- Opt-out: `NOTES_DAILY_AUTO=0` or `.cursor/hooks/state/notes-daily.off` (checked on notes root, pack root, and hook `state/`).
- Debug: `.cursor/hooks/state/notes-daily.debug.log`.
- If a turn still shows `<!-- notes-daily:pending -->`, the next prompt closes it as `continued`, or a reply/`stop` should fill it.
