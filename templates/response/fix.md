# /fix response

Include shared [report.md](report.md), then prefer `OUTCOME:` for daily notes Result.


```
ATTEMPT: #n
REPRO: yes | no | blocked — <one line>
FAIL PATH: <where it breaks>
HYPOTHESES:
  1. ... | ruled in/out | evidence
  2. ...
ROOT CAUSE: <proven> | unknown — diagnose-only
PATCH: <summary> | none yet
ROLLBACK: <one line>
```

When enterprise surface (schema/auth/payments/infra/data/prod) — map to REPORT `ENTERPRISE` via [report.md](report.md) (`schema`→`db`, `prod`→`infra`; never invent `ENTERPRISE: schema|prod`):

```
ENTERPRISE: db | auth | payments | infra | data | none
BLAST_RADIUS: ...
ROLLBACK: ... | BLOCKED
STATUS: AWAITING_CONFIRM
```

Do not write or run until `ยืนยัน` / `confirm` / `yes` (before writing schema/auth/payments/infra/data/prod files).

MED/HIGH app: `NEXT: /review` then `/ship` (do not under-label RISK to skip).
