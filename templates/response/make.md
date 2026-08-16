# /make response

Include shared [report.md](report.md), then prefer `OUTCOME:` for daily notes Result.


```
CAPABILITY: <id>
DEPTH: Lite | Full (reason: user|--full|auto-trigger)
SCOPE: in | out (non-goals)
BUDGET: write files≤N lines≤M | OVERRIDE asked
READ: locate-before-read | purpose-matched files only
```

When enterprise surface (schema/auth/payments/infra/data/prod) — map to REPORT `ENTERPRISE` via [report.md](report.md) (`schema`→`db`, `prod`→`infra`; never invent `ENTERPRISE: schema|prod`):

```
ENTERPRISE: db | auth | payments | infra | data | none
BLAST_RADIUS: ...
ROLLBACK: ... | BLOCKED
STATUS: AWAITING_CONFIRM
```

Do **not** write or run until `ยืนยัน` / `confirm` / `yes`. Migrate **run** needs a second confirm naming the env.

MED/HIGH app: `NEXT: /review` then `/ship` (do not under-label RISK to skip).
