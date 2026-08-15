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

When enterprise surface (schema/auth/payments/PII/infra/prod):

```
ENTERPRISE: db | auth | payments | infra | data | none
BLAST_RADIUS: ...
ROLLBACK: ... | BLOCKED
STATUS: AWAITING_CONFIRM
```

Do not write or run until `ยืนยัน` (before writing migrate/auth/payment files).
