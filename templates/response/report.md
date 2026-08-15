# Shared REPORT

Use on skill close-out, BLOCKED, or AWAITING_CONFIRM. Mid-turn: `STATUS` + `OBJECTIVE` + `EVIDENCE` or `NEXT` only.

```
REPORT
STATUS: READY | BLOCKED | IN_PROGRESS | FAILED | AWAITING_CONFIRM | PLAN_READY | VERDICT
MODE: Full | Lite | n/a
RISK: LOW | MED | HIGH
OBJECTIVE: ...
EVIDENCE: ...
CHANGES: ... | none (no-edit)
VERIFY: IDENTIFY | RUN | READ | skip
NEXT: ...
ENTERPRISE: db | auth | payments | infra | data | none
BLAST_RADIUS: ... | —
ROLLBACK: ... | BLOCKED | —
```

## Field rules

- Empty narrative fields → `—`. Keep short. Expand only when BLOCKED, HIGH risk, or user asks.
- When `enterprise-safety` applies: `ENTERPRISE` + `BLAST_RADIUS` + `ROLLBACK` required **before** acting. Otherwise `ENTERPRISE: none` (or omit only on mid-turn short form).
