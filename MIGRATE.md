# Migrate → 1.0.0

## Breaking (from former pack lines)

1. **Removed `model-rust` entirely** — crate, Mongo CLI, workspace junction, and all `MODEL-RUST` / `NOTES` recall gates.
2. **Removed `/note`** — durable Mongo notes skill and related templates/evals.
3. **Removed auto memory hooks** — `model-rust-auto.*` scripts and `rules/model-rust-auto.mdc`. Cursor `hooks.json` ships with empty `hooks`.
4. Shared REPORT no longer includes `MODEL-RUST` / `NOTES` fields.
5. **No `VERSION` file** — release notes live only in [CHANGELOG.md](CHANGELOG.md) (`1.0.0` baseline).

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
