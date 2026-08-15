# Migrate → 1.0.0

## Breaking (from former pack lines)

1. **Removed `model-rust` entirely** — crate, Mongo CLI, workspace junction, and all `MODEL-RUST` / `NOTES` recall gates.
2. **Removed `/note`** — durable Mongo notes skill and related templates/evals.
3. **Removed auto memory hooks** — `model-rust-auto.*` scripts and `rules/model-rust-auto.mdc`. Cursor `hooks.json` ships with empty `hooks`.
4. Shared REPORT no longer includes `MODEL-RUST` / `NOTES` fields.
5. **`VERSION` is `1.0.0`** — fresh baseline; not semver-continuous with old `2.x`–`4.x` tags.

Mongo Atlas data (if any) is **not** deleted by this pack upgrade. Purge/drop the old DB yourself if you want it gone.

## Steps

```powershell
cd agent-skills
git pull
.\scripts\install-windows.ps1
```

```bash
cd agent-skills
git pull
./scripts/install-unix.sh
```

Validate:

```powershell
.\scripts\validate-skill-names.ps1
.\scripts\run-evals.ps1
.\scripts\run-behavior-evals.ps1
```

Restart Cursor once after install. Open the **parent** workspace (`Skills/`), not only `agent-skills/`.
Confirm Hooks tab shows no `model-rust-auto` entries.
Confirm `VERSION` reads current [VERSION](VERSION).

## 1.2.0 daily hooks

- Every Agent prompt is appended to `.cursor/notes/daily/YYYY-MM-DD.md`.
- Disable with `NOTES_DAILY_AUTO=0` or `.cursor/hooks/state/notes-daily.off`.
- Re-run install and restart Cursor so hooks.json + scripts refresh.
