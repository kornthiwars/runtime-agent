# /feature response

Include shared [report.md](report.md). Before confirm: `STATUS: AWAITING_CONFIRM`.

```
POLICY PIPELINE: plan → make/fix → review → ship
SLICES:
  - slice-1 → /make ... | risk ...
IRREVERSIBLES: migrate | delete | ... | none
ENTERPRISE: db | auth | payments | infra | data | none
BLAST_RADIUS: ... | —
ROLLBACK: ... | BLOCKED | —
CONFIRM PROMPT: reply "ยืนยัน" to start — no code until confirmed
```
