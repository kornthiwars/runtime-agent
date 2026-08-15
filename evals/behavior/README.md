# Behavior evals (golden gates)

Not a live agent runner. Each fixture locks **Golden In/Out needles** that must remain in `SKILL.md` so behavior contracts do not silently regress.

## Run

```powershell
.\scripts\run-behavior-evals.ps1
```

```bash
./scripts/run-behavior-evals.sh
```

`run-evals.*` (structural), `run-behavior-evals.*`, and `smoke-notes-daily.*` are required in CI / pre-commit (≥95% for eval runners).

## Fixture schema

| Field | Meaning |
|-------|---------|
| `id` | unique |
| `skill` | folder under `skills/` |
| `prompt` | golden-style user prompt |
| `expect_out_any` | at least one needle must appear in `SKILL.md` (usually Golden Out) |
| `must_gate` | every needle must appear (iron laws / Never lines) |

## Manual spot checks

Still useful for **live Agent** turns: see [evals/README.md](../README.md) section **Still manual (live Cursor agent)**.
