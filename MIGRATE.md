# Migrate 2.x → 3.0.0

## Breaking

1. **`model-rust add`** rejects legacy JSON fields `problem`, `solutionSummary`, `solution`. Use `summary` only. CLI flag `--solution-summary` removed.
2. Shared REPORT no longer uses versioned branding labels — fields `MODEL-RUST` / `NOTES` remain required on substantive close-out.

## Steps

```powershell
cd agent-skills
git pull
.\scripts\install-windows.ps1
cd model-rust
# ensure .env has MONGODB_URI
cargo build
cargo run -- ping
```

```bash
cd agent-skills
git pull
./scripts/install-unix.sh
cd model-rust
cargo build
cargo run -- ping
```

Optional housekeeping:

```powershell
cargo run -- note purge --dry-run
cargo run -- turns-purge --older-than-days 90 --dry-run
# then --yes when ready
```

Validate:

```powershell
.\scripts\validate-skill-names.ps1
.\scripts\run-evals.ps1
.\scripts\run-behavior-evals.ps1
```

Restart Cursor once after install. Open the **parent** workspace (`Skills/`), not only `agent-skills/`.
